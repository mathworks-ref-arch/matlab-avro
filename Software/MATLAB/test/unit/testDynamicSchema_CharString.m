classdef testDynamicSchema_CharString < matlab.unittest.TestCase
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
       
        function testScalarChar(testCase,Compression)
            D1 = 'a';
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);            
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for char -> read as string
            testCase.verifyNotEqual(D1, D2, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = char(D2);
            testCase.verifyEqual(D1, D3, 'The values read should be the same as written after char conversion on read.');

        end
        
        function testRowVectorChar(testCase,Compression)
            D1 = 'abcdefg';

            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);            
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for char -> read as string
            testCase.verifyNotEqual(D1, D2, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = char(D2);
            testCase.verifyEqual(D1, D3, 'The values read should be the same as written after char conversion on read.');

        end
        
        function testColVectorChar(testCase,Compression)
            D1 = 'abcdefg';
            D1 = D1';

            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);            
        
            testCase.dfw.append(D1);
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();

            % Data symmetry not maintained for char -> read as string
            testCase.verifyNotEqual(D1, D2, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = char(D2);
            testCase.verifyEqual(D1, D3, 'The values read should be the same as written after char conversion on read.');

        end

        function testArrayChar(testCase,Compression)
            D1 = ['abcdefg'; 'hijklmn'; 'opqrstu'];

            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;            
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);            
            testCase.dfw.append(string(D1));
            
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            
            % Data symmetry not maintained for char -> read as string
            testCase.verifyNotEqual(D1, D2, 'The values read not be as written for char.');
            testCase.verifyEqual(class(D2), 'string', 'The class should be read as string');

            %convert to char and verifyequal
            D3 = char(D2);
            testCase.verifyEqual(D1, D3, 'The values read should be the same as written after char conversion on read.');

        end
        
        function testString(testCase,Compression)
            D1 = "testing avro read write.";
            
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);            
            testCase.dfw.append(D1);

            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = string(testCase.dfr.next());
            
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
      
    end
end
