classdef BasicAvro < matlab.unittest.TestCase
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
    properties(MethodSetupParameter)
        %          Compression = {...
        %             'snappy', ...
        %             'none', ...
        %             'deflate'
        %             };
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
        function testScalar(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.DOUBLE);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            D1 = 42;
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testScalarSeekSync(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.DOUBLE);
            testCase.dfw.compressionType = Compression;
            testCase.dfw = testCase.dfw.createAvroFile(testCase.schema,testCase.fn);  
            D1 = 100;
            D2 = 200;
            D3 = 300;
            D4 = 400;
            testCase.dfw.append(D1);
            D2Pos = testCase.dfw.sync();
            testCase.dfw.append(D2);
            D3Pos = testCase.dfw.sync();
            testCase.dfw.append(D3);
            D4Pos = testCase.dfw.sync();            
            testCase.dfw.append(D4);                        
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            testCase.dfr.seek(D4Pos);
            D7 = testCase.dfr.next();
            testCase.dfr.seek(D3Pos);
            D6 = testCase.dfr.next();
            testCase.dfr.seek(D2Pos);
            D5 = testCase.dfr.next();
            testCase.verifyEqual(D2, D5, 'The values read should be as written.');
            testCase.verifyEqual(D3, D6, 'The values read should be as written.');
            testCase.verifyEqual(D4, D7, 'The values read should be as written.');
        end
        function testScalarMultiple(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.DOUBLE);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            D1 = {42,43,55};
            testCase.dfw.append(D1{1});
            testCase.dfw.append(D1{2});
            testCase.dfw.append(D1{3});
            D2 = {};
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            i=1;
            while(testCase.dfr.hasNext())
                D2{i} = testCase.dfr.next();
                i = i + 1;
            end
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end        
        
        function testString(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.STRING);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            D1 = 'testing avro read write.';
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testEnumeration(testCase,Compression)            
            tmpSchema = matlabavro.Schema.createEnum('Weekdays');                        
            D1 = Weekdays.Friday;
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(tmpSchema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(string(D1), string(D2), 'The values read should be as written.');
        end
        
        function testRowVector(testCase,Compression)
            D1 = [1,2,3];
            testCase.schema = testCase.schema.createArray(matlabavro.SchemaType.DOUBLE);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',1);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVector1(testCase,Compression)
            D1 = [1,2,3]';
            testCase.schema = testCase.schema.createArray(matlabavro.SchemaType.DOUBLE);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
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
        
        function testMatrix(testCase,Compression)
            D1 = reshape(1:10e3, 1e3, 10);
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
        function testSimpleCellArray(testCase,Compression)
            D1 = {1, 2, 3; 4,5,6};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isCell',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testTable(testCase,Compression)
            LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
            Age = [38;43;38;40;49];
            Smoker = [1;0;1;0;1];
            Height = [71;69;64;67;64];
            Weight = [176;163;131;133;119];
            D1 = table(LastName,Age,Smoker, Height,Weight);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isTable', 1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        %TODO
        function testComplexCellArray(testCase,Compression)
            D1 = reshape(1:20,5,4)';
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
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
        
        function testStructTable(testCase,Compression)
            D1 = struct2table(getStructName(500));
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isTable', 1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            %Data symmetry not maintained for string array in a struct.
            %convert and verifyequal
            D2.Name = string(D2.Name);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testScalarTrue(testCase,Compression)
            D1 = true;
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testScalarFalse(testCase,Compression)
            D1 = true;
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testBooleanRowVector(testCase,Compression)
            D1 = logical([0,1,1,0,1,3,99,0]);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',1);
            testCase.dfw.setMeta('columns',8);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVector(testCase,Compression)
            D1 = logical([0,1,1,0,1,3,99,0])';
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',8);
            testCase.dfw.setMeta('columns',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testScalarTyped(testCase,Compression, DType)
            D1 = feval(DType, 42);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            if(isequal(class(D1),'int32'))
                D2 = int32(D2);
            elseif (isequal(class(D1), 'int64'))
                D2 = int64(D2);
            elseif (isequal(class(D1), 'logical'))
                D2 = logical(D2);
            end
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testRowVectorTyped(testCase,Compression, DType)
            D1 = feval(DType, [1,2,3]);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',1);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            if(isequal(class(D1),'int32'))
                D2 = int32(D2);
            elseif (isequal(class(D1), 'int64'))
                D2 = int64(D2);
            elseif (isequal(class(D1), 'logical'))
                D2 = logical(D2);
            end
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testColumnVectorTyped(testCase,Compression, DType)
            D1 = feval(DType, [1,2,3]');
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            if(isequal(class(D1),'int32'))
                D2 = int32(D2);
            elseif (isequal(class(D1), 'int64'))
                D2 = int64(D2);
            elseif (isequal(class(D1), 'logical'))
                D2 = logical(D2);
            end
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testMatrixTyped(testCase,Compression, DType)
            D1 = feval(DType, reshape(1:10e3, 1e3, 10));
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            if(isequal(class(D1),'int32'))
                D2 = int32(D2);
            elseif (isequal(class(D1), 'int64'))
                D2 = int64(D2);
            elseif (isequal(class(D1), 'logical'))
                D2 = logical(D2);
            end
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
        function testTableTyped(testCase,Compression, DType)
            D1 = struct2table(getStructTyped(6e3, DType));
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isTable', 1);
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
            D1 = struct('a','test','b',1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
         function testInt8TypeStruct(testCase,Compression)
            D1 = struct('a','test','b',int8(120));
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        %
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
        
      function testMATLABObject(testCase,Compression)
          D1 = user();
          D1.name ='test';
          D1.age = 42;
          D1.weight = 155;
          testCase.schema = testCase.schema.createSchemaForData(D1);
          testCase.dfw.compressionType = Compression;
          testCase.dfw.setMeta('isObject',1);
          testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
          testCase.dfw.append(D1);
          testCase.dfr = matlabavro.DataFileReader(testCase.fn);
          D2 = testCase.dfr.next();
          testCase.verifyEqual(D1, D2, 'The values read should be as written.');
      end
         function testint8(testCase,Compression)
          D1 = int8([234 2 3]') ;            
          testCase.schema = matlabavro.Schema.parse('{"type": "bytes"}');
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

