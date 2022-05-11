classdef testDynamicSchema_Numeric < matlab.unittest.TestCase
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
            'signle', ...
            'logical', ...
            'int8', ...
            'int16', ...
            'int32', ...
            'int64' ...
            'uint8', ...
            'uint16', ...
            'uint32', ...
            'uint64' ...
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
        function testIntScalar(testCase,Compression)
            D1 = 42;
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testInt8Scalar(testCase,Compression)
            D1 = int8(32);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testInt16Scalar(testCase,Compression)
            D1 = int16(32);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int16(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testInt32Scalar(testCase,Compression)
            D1 = int32(323323);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int32(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testInt64Scalar(testCase,Compression)
            D1 = int64(9223372036854775807);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int64(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testRowVectorInt(testCase,Compression)
            D1 = [1,2,3];
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',1);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testRowVectorInt8(testCase,Compression)
            D1 = int8([-127,68,127]);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            %transpose manually
            D2 = testCase.dfr.next()';
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testRowVectorInt16(testCase,Compression)
            D1 = int16([1,2,3]);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',1);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int16(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testRowVectorInt32(testCase,Compression)
            D1 = int32([-30000,2,300000]);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',1);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int32(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testRowVectorInt64(testCase,Compression)
            D1 = int64([-30000,2,300000]);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',1);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int64(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorInt(testCase,Compression)
            D1 = [1,2,3]';
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorInt8(testCase,Compression)
            D1 = int8([1,2,3]');
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorInt16(testCase,Compression)
            D1 = int16([1,2,3]');
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int16(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorInt32(testCase,Compression)
            D1 = int32([1,2,3])';
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int32(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorInt64(testCase,Compression)
            D1 = int64([1,2,3])';
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',1);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int64(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testMatrixInt(testCase,Compression)
            D1 = [1,2,3;4,5,6;7,8,9];
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testMatrixInt8(testCase,Compression)
            D1 = int8([1,2,3;4,5,6;7,8,9]);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testMatrixInt16(testCase,Compression)
            D1 = int16([1,2,3;4,5,6;7,8,9]);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int16(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testMatrixInt32(testCase,Compression)
            D1 = int32([1,2,3;4,5,6;7,8,9]);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int32(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testMatrixInt64(testCase,Compression)
            D1 = int64([1,2,3;4,5,6;7,8,9]);
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.setMeta('rows',3);
            testCase.dfw.setMeta('columns',3);
            testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = int64(testCase.dfr.next());
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testScalarSeekSync(testCase,Compression)
            D1 = 100;
            D2 = 200;
            D3 = 300;
            D4 = 400;
            testCase.schema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw = testCase.dfw.createAvroFile(testCase.schema,testCase.fn);
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
    end
end