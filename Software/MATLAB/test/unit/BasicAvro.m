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
            'single', ...
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
        function testScalar(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.DOUBLE);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            D1 = 42;
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testEmptyNumericMatrixWithExplicitNullSchema(testCase,Compression)
            D1 = [];

            testCase.schema = testCase.schema.create(matlabavro.SchemaType.NULL);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testScalarString(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.STRING);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            D1 = "b";
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testEmptyStringWithExplicitStringSchema(testCase,Compression)
            D1 = "";

            testCase.schema = testCase.schema.create(matlabavro.SchemaType.STRING);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testScalarChar(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.STRING);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            D1 = 'b';
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = string(testCase.dfr.next());

            % Data symmetry not maintained for char -> read as string
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = char(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after char conversion on read.');
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
            testCase.verifyEqual(D5, D2, 'The values read should be as written.');
            testCase.verifyEqual(D6, D3, 'The values read should be as written.');
            testCase.verifyEqual(D7, D4, 'The values read should be as written.');
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
                D2{i} = testCase.dfr.next(); %#ok<AGROW> 
                i = i + 1;
            end
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCharacter(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.STRING);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            D1 = 'testing avro read write.';
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for char -> read as string
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = char(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after char conversion on read.');

        end

        function testString(testCase,Compression)
            testCase.schema = testCase.schema.create(matlabavro.SchemaType.STRING);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            D1 = "testing avro read write.";
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testEnumeration(testCase,Compression)
            tmpSchema = matlabavro.Schema.createEnum('Weekdays');
            D1 = Weekdays.Friday;
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(tmpSchema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(string(D2), string(D1), 'The values read should be as written.');
        end

        function testRowVector(testCase,Compression)
            D1 = [1,2,3];
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testColumnVector1(testCase,Compression)
            D1 = [1; 2; 3];
            testCase.schema = testCase.schema.createSchemaForData(D1);
            
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testStructWith2ColumnVectorFields(testCase,Compression)
            D1.x = linspace(0,6)';
            D1.y = sin(D1.x);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testStringRowVector(testCase,Compression)
            D1 = ["a" "b" "c"];

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCharColumnVector(testCase,Compression)
            D1 = ['a'; 'b'; 'c'];

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            % Data symmetry not maintained for char column -> read as string row
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = char(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after char conversion on read.');
        end

        function testNumericMatrix(testCase,Compression)
            D1 = reshape(1:10e3, 1e3, 10);
            
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testStringMatrix(testCase, Compression)
            D1 = "Testing " + (1:4)';

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testCharacterMatrix(testCase, Compression)
            D1 = char("Testing " + (1:4)');

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            % Data symmetry not maintained for char column -> read as string row
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = char(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after char conversion on read.');
        end

        function testCellStrColumn(testCase, Compression)
            charMatrix = char("Testing " + (1:4)');
            D1 = cellstr(charMatrix);

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            % Data symmetry not maintained for char column -> read as string row
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for cellstr.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = cellstr(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after cellstr conversion on read.');
        end

        function testCellStrChar(testCase, Compression)
            D1 = {'a'};

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            % Data symmetry not maintained for char column -> read as string row
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for cellstr.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = cellstr(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after cellstr conversion on read.');
        end

        function testCellStrRow(testCase, Compression)
            testStrings = cellstr("Testing " + (1:4)');
            D1 = testStrings';

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            % Data symmetry not maintained for char column -> read as string row
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for cellstr.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = cellstr(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after cellstr conversion on read.');
        end
        
        function testStruct(testCase,Compression)
            D1 = getStruct(5e3);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testStructWithCharacterData(testCase,Compression)
            fieldName = 'aFieldName';
            D1 = struct(fieldName,'aCharVal');
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for char array in a struct.
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2.(fieldName)), 'string');

            %convert to char and verifyequal
            D3 = D2;
            D3.(fieldName) = char(D3.(fieldName));
            testCase.verifyEqual(D3, D1, 'The values read not be as written for char.');
        end
        
        function testStructWithSingleString(testCase,Compression)
            D1 = struct('aFieldName',"aStringVal");
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
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

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testStructWithEmptyCell(testCase,Compression)
            D1.anEmptyCellField = {};

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testStructWithSclararCell(testCase,Compression)
            D1.aScalarCellField = {pi};

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testTable(testCase,Compression)
            % Create test table
            LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
            Age = [38;43;38;40;49];
            Smoker = [1;0;1;0;1];
            Height = [71;69;64;67;64];
            Weight = [176;163;131;133;119];

            D1 = table(LastName,Age,Smoker, Height,Weight);
            
            % Write to Avro
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isTable', 1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            % Read from Avro
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Verify
            testCase.verifyEqual(D2.Age, D1.Age, 'The values read should be as written.');
            testCase.verifyEqual(D2.Smoker, D1.Smoker, 'The values read should be as written.');
            testCase.verifyEqual(D2.Height, D1.Height, 'The values read should be as written.');
            testCase.verifyEqual(D2.Weight, D1.Weight, 'The values read should be as written.');
            
            % Data symmetry not maintained for char array in a struct.
            charFieldName = 'LastName';
            testCase.verifyNotEqual(D2.LastName, D1.LastName, 'The values should not be as written for char.');
            testCase.verifyEqual(class(D2.(charFieldName)), 'string');

            %convert to char and verifyequal
            D3 = string(D1.(charFieldName));
            testCase.verifyEqual(D2.(charFieldName), D3, 'The values read should be as written after converting source char to String.');

        end
        
        function testCellWithScalarDouble(testCase,Compression)
            D1 = {5};
            
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isCell', 1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCellWithScalarTyped(testCase,Compression, DType)
            aVal = cast(42, DType);
            D1 = {aVal};
            
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isCell', 1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCellWithMixedTyped(testCase,Compression)
            aVal = 42.0;
            bVal = cast(aVal, 'single');
            cVal = cast(aVal, 'int32');
            D1 = {aVal bVal cVal};
            
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testStructWithMixedTyped(testCase,Compression)
            D1.doubleVal = 42.0;
            D1.singleVal = cast(D1.doubleVal, 'single');
            D1.uint16Val = cast(D1.doubleVal, 'int32');
            
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCellWithNumericMatrix(testCase,Compression)
            inputMatrix = reshape(1:20,5,4)';
            D1 = num2cell(inputMatrix);
            
            testCase.schema = testCase.schema.createSchemaForData(D1);
            
            testCase.dfw.compressionType = Compression;
%             testCase.dfw.setMeta('isCell', 1);
            
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCellWithEmptyValue(testCase,Compression)
            D1 = {};
            
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
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testSimpleCharStruct(testCase,Compression)
            D1 = getStructName(500);
            % Convert String to Char for desired test
            D1.NameFromChar = char(D1.Name);

            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for char array in a struct.
            testCase.verifyNotEqual(D2, D1, 'The values read should be different.');
            testCase.verifyEqual(class(D2.NameFromChar), 'string', 'The values read should be a string');

            %convert source char to string and verifyequal
            D3 = string(D1.NameFromChar);
            testCase.verifyEqual(D2.NameFromChar, D3, 'The values read should be the same if source char converted to String.');

        end

        function testStructTable(testCase,Compression)
            structData = getStructName(500);
            D1 = struct2table(structData);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isTable', 1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Verify
            testCase.verifyEqual(D2.Time, D1.Time, 'The values read should be as written.');
            testCase.verifyEqual(D2.Sin, D1.Sin, 'The values read should be as written.');
            testCase.verifyEqual(D2.Cos, D1.Cos, 'The values read should be as written.');
            testCase.verifyEqual(D2.Name, D1.Name, 'The values read should be as written.');
            
            % convert read table to struct and compare
            D3 = table2struct(D2, "ToScalar", true);
            testCase.verifyEqual(D3, structData, 'The values read should be as written after converting read table to struct.');
        end

        function testScalarTrue(testCase,Compression)
            D1 = true;
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testScalarFalse(testCase,Compression)
            D1 = false;
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testBooleanRowVector(testCase,Compression)
            D1 = logical([0,1,1,0,1,3,99,0]);
            testCase.schema = testCase.schema.createSchemaForData(D1);

            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testColumnVector(testCase,Compression)
            D1 = logical([0,1,1,0,1,3,99,0])';
            testCase.schema = testCase.schema.createSchemaForData(D1);

            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testScalarTyped(testCase,Compression, DType)
            D1 = feval(DType, 42);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testStructWithScalarTyped(testCase, Compression, DType)
            D1.a = cast(42, DType);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testRowVectorTyped(testCase,Compression, DType)
            D1 = feval(DType, [1,2,3]);
            testCase.schema = testCase.schema.createSchemaForData(D1);

            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testColumnVectorTyped(testCase,Compression, DType)
            D1 = feval(DType, [1,2,3]');
            testCase.schema = testCase.schema.createSchemaForData(D1);

            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testMatrixTyped(testCase,Compression, DType)
            D1 = feval(DType, reshape(1:10e3, 1e3, 10));
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testStructTyped(testCase,Compression, DType)
            D1 = getStructTyped(5e3, DType);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testEmptyStruct(testCase, Compression)
            D1 = struct();
            testCase.schema = testCase.schema.createSchemaForData(D1);

            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        %         function testTableTyped(testCase,Compression, DType)
        %             D1 = struct2table(getStructTyped(6e3, DType));
        %             testCase.schema = testCase.schema.createSchemaForData(D1);
        %             testCase.dfw.compressionType = Compression;
        %             testCase.dfw.setMeta('isTable', 1);
        %             testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
        %             testCase.dfw.append(D1);
        %             testCase.dfr = matlabavro.DataFileReader(testCase.fn);
        %             D2 = testCase.dfr.next();
        %             if(isequal(DType,'int32'))
        %                 D2.Time = int32(D2.Time);
        %                 D2.Sin = int32(D2.Sin);
        %                 D2.Cos = int32( D2.Cos);
        %             elseif (isequal(DType, 'int64'))
        %                 D2.Time = int64(D2.Time);
        %                 D2.Sin = int64(D2.Sin);
        %                 D2.Cos = int64( D2.Cos);
        %             elseif (isequal(DType, 'logical'))
        %                 D2.Time = logical(D2.Time);
        %                 D2.Sin = logical(D2.Sin);
        %                 D2.Cos = logical( D2.Cos);
        %             end
        %             testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        %         end

        function testInt8TypeStruct(testCase,Compression)
            % create test data
            testFieldName = 'a';
            D1 = struct(testFieldName,'testChar','b',int8(120), 'c', "TestString");

            % Write to avro file
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            % read
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for char array in a struct.
            testCase.verifyNotEqual(D2, D1, 'The values read should be different.');
            testCase.verifyEqual(class(D2.(testFieldName)), 'string', 'The values read should be a string');

            %convert to char and verifyequal
            D3 = D2;
            D3.(testFieldName) = char(D3.(testFieldName));
            testCase.verifyEqual(D3, D1, 'The values read should be the same after converted to char.');
        end

        function testNestedStruct(testCase,Compression)
            D1 = struct('a1',struct('a2',2),'b1',1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testNestedStructWithEmptySubField(testCase,Compression)
            D1 = struct('a1',struct('a2',[]),'b1',1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testStructWithScalarFieldAndVectorField(testCase,Compression)
            D1 = struct('a',1:5,'b',42);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testMultiNestedStruct(testCase,Compression)
            D1 = struct('a',struct('a',struct('a',1)),'b',1);
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
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
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testint8(testCase,Compression)
            D1 = int8([134 2 3]') ;
            testCase.schema = matlabavro.Schema.parse('{"type": "bytes"}');
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
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

