classdef testDynamicSchema_Struct < matlab.unittest.TestCase
    %
    % Copyright (c) 2020, The MathWorks, Inc.
    properties
        schema
        dfr
        dfw
        fn = 'test.avro'
    end
    properties(TestParameter)
        DType = { ...
            'double', ...
            'logical', ...
            'int32', ...
            'int64' ...
            }
        Compression = {...
            matlabavro.CompressionType.SNAPPY, ...
            matlabavro.CompressionType.BZIP2, ...
            matlabavro.CompressionType.NULL, ...
            matlabavro.CompressionType.DEFLATE
            }
    end

    methods(TestMethodSetup)
        function addHelpers(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            import matlab.unittest.fixtures.CurrentFolderFixture;

            % Create a temporary folder and make it the current working
            % folder.
            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
            testCase.schema = matlabavro.Schema();
            testCase.dfw = matlabavro.DataFileWriter();
        end
    end
    methods(TestMethodTeardown)
        function closeAvroHandles(testCase)
            testCase.dfw.close();
            testCase.dfr.close();
        end
    end

    methods(Test)

        function testColumnVector2(testCase,Compression)
            D1.x = linspace(0,6)';
            D1.y = sin(D1.x);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end


        function testStruct(testCase,Compression)
            D1 = getStruct(5e3);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end

        function testStructWithSingleChar(testCase,Compression)
            D1 = struct('aFieldName','aValue');
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for char array in a struct.
            testCase.verifyNotEqual(D2, D1, 'The values read should be different.');
            testCase.verifyEqual(class(D2.aFieldName), 'string', 'The values read should be a string');

            %convert source char to string and verifyequal
            D3 = string(D1.aFieldName);
            testCase.verifyEqual(D2.aFieldName, D3, 'The values read should be the same if source char converted to String.');
        end

        function testArrayInStruct(testCase,Compression)
            B = [1,2,3]';
            A.B  = B;
            D1 = A;
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function test1xnCellInStruct(testCase,Compression)
            B = {int8(1),2,3};
            A.B  = B;
            D1 = A;
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testnx1CellInStruct(testCase,Compression)
            B = {1;2;3};
            A.B = B;
            D1 = A;
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testSimpleStringStruct(testCase,Compression)
            D1 = getStructName(500);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            %Data symmetry not maintained for string array in a struct.
            %convert and verifyequal
            D2.Name = string(D2.Name);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end

        function testStructTyped(testCase,Compression, DType)
            D1 = getStructTyped(5e3, DType);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            if(isequal(DType,'int32'))
                D2.Time = int32(D2.Time);
                D2.Sin = int32(D2.Sin);
                D2.Cos = int32( D2.Cos);
            elseif (isequal(DType, 'int64'))
                D2.Time = int64(D2.Time);
                D2.Sin = int64(D2.Sin);
                D2.Cos = int64( D2.Cos);
            elseif (isequal(DType, 'logical'))
                D2.Time = logical(D2.Time);
                D2.Sin = logical(D2.Sin);
                D2.Cos = logical( D2.Cos);
            end
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end

        function testSimpleTypeStruct(testCase,Compression)
            % NOTE: Data symmetry not implemented for structure arrays.
            D1 = struct('b',{1,2});
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(1,isStructEqual(D1,D2))
        end

        function testMixedTypeStruct(testCase,Compression)
            D1 = struct('aField',"test",'bField',1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end

        function testInt8TypeStruct(testCase,Compression)
            D1 = struct('aField', "test", 'bField', int8(120));
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end

        function testNestedStruct(testCase,Compression)
            D1 = struct('a',struct('a',1),'b',1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testMultiNestedStruct(testCase,Compression)
            D1 = struct('a',struct('a',struct('a',1)),'b',1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
    end
end

function S = getStruct(N)
x = linspace(0,10,N+1)';
x(end) = [];
S = struct('Time', x, ...
    'Sin', sin(x), ...
    'Cos', cos(x));
end
function S = getStructName(N)
x = linspace(0,10,N+1)';
x(end) = [];
xs = arrayfun(@(x) string(sprintf('Name_%05d', x)), (1:N)');
S = struct('Time', x, ...
    'Sin', sin(x), ...
    'Cos', cos(x), ...
    'Name', {xs});
end
function S = getStructTyped(N, DType)
x = linspace(0,10,N+1)';
x(end) = [];
S = struct('Time', feval(DType, x), ...
    'Sin', feval(DType, sin(x)), ...
    'Cos', feval(DType, cos(x)));
end

