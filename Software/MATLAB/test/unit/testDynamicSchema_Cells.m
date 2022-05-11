classdef testDynamicSchema_Cells < matlab.unittest.TestCase
    %s
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
        function testCell_Empty(testCase,Compression)
            D1 = {};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isCell', 1);

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.assertTrue(isempty(D2), 'The values read should be as written.');
        end
        
        function testCellRow_Int(testCase,Compression)
            D1 = {2,3,4};
            testCase.schema = testCase.schema.createSchemaForData(D1);

            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testCellRow_IntAndEmpty(testCase,Compression)
            D1 = {2,3,{}};
            testCase.schema = testCase.schema.createSchemaForData(D1);

            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCellColumn_Int(testCase,Compression)
            D1 = {2;3;4};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCellArray_Int(testCase,Compression)
            D1 = {2,3,4;5,6,7};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('isCell', 1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCell_MixedEmpty(testCase,Compression)
            D1 = {{1,2},{}};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;

            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end

        function testCellRow_Char(testCase,Compression)
            D1 = {'a','b','b'};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);             
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for cellstr -> read/written as strings
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for cellstr.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = cellstr(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after cellstr conversion on read.');
        end
        
        function testCellColumn_Char(testCase,Compression)
            D1 = {'a';'b';'b'};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);             
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for cellstr -> read/written as strings
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for cellstr.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = cellstr(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after cellstr conversion on read.');
        end
        
        function testCell_String(testCase,Compression)
            D1 = {'testing avro string in a cell'};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);             
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for cellstr -> read/written as strings
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for cellstr.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = cellstr(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after cellstr conversion on read.');
        end

        function testCell_MultipleStrings(testCase,Compression)
            D1 = {'testing avro string in a cell', 'second string'};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);             
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            % Data symmetry not maintained for cellstr -> read/written as strings
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for cellstr.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = cellstr(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after cellstr conversion on read.');
        end

        function testCell_MultipleColumnStrings(testCase,Compression)
            D1 = {'testing avro string in a cell'; 'second string'};
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);             
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for cellstr -> read/written as strings
            testCase.verifyNotEqual(D2, D1, 'The values read not be as written for cellstr.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = cellstr(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be the same as written after cellstr conversion on read.');
        end
    end
end
