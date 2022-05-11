classdef testDynamicSchema_Logical < matlab.unittest.TestCase
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
            D1 = false;
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
        
        function testBooleanColumnVector(testCase,Compression)
            D1 = logical([0,1,1,0,1,0,1,0])';
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
        
         function testBooleanMatrix(testCase,Compression)
            D1 = logical([0,1,1;0,1,0;1,1,0])';
            testCase.schema = testCase.schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
    end
end