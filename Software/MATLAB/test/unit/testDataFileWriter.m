classdef testDataFileWriter < matlab.unittest.TestCase
    % TESTDATAFILEWRITER This is a test stub for a unit testing
    % The assertions that you can use in your test cases:
    %
    %    assertTrue
    %    assertFalse
    %    assertEqual
    %    assertFilesEqual
    %    assertElementsAlmostEqual
    %    assertVectorsAlmostEqual
    %    assertExceptionThrown   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Please add your test cases below
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (c) 2020 MathWorks, Inc.
    properties
        writer
    end
    methods (TestMethodSetup)
        function testSetup(testCase)
            testCase.writer = matlabavro.DataFileWriter();
        end
    end
    
    methods (TestMethodTeardown)
        function testTearDown(testCase)
            testCase.writer.close();
        end
    end
    
    methods (Test)
        function testSetCompressionType(testCase)
            D1 = matlabavro.CompressionType.DEFLATE;
            testCase.writer.compressionType = D1;
            D2 = testCase.writer.compressionType;
            testCase.verifyEqual(D1, D2);
        end
        
        function testSetCompressionLevel(testCase)
            D1 = 2;
            testCase.writer.compressionLevel = D1;
            D2 = testCase.writer.compressionLevel;
            testCase.verifyEqual(D1, D2);
        end
        
        function testCreateAvroFile(testCase)
            tmpSchema = matlabavro.Schema.parse('{"type":"array","items":"int"}');
            fn = 'test.avro';
            D2 = testCase.writer.createAvroFile( tmpSchema,fn);
            testCase.verifyEqual(tmpSchema, D2.schema);
        end
        function testCreateAvroStream(testCase)
            tmpSchema = matlabavro.Schema.parse('{"type":"array","items":"int"}');
            D2 = testCase.writer.createAvroStream( tmpSchema);
            testCase.verifyEqual(tmpSchema, D2.schema);
        end
       
    end
    
end

