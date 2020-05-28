classdef testDataFileReader < matlab.unittest.TestCase
    % TESTDATAFILEREADER This is a test stub for a unit testing
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
        reader
    end
    methods (TestMethodSetup)
        function testSetup(testCase)           
            testCase.reader = matlabavro.DataFileReader(fullfile(fileparts(mfilename('fullpath')),'data','myData.avro'));            
        end
    end
    
    methods (TestMethodTeardown)
        function testTearDown(testCase)
            testCase.reader.close();
        end
    end
    
    methods (Test)
        function testGetSchema(testCase)
            D1 = matlabavro.Schema.createRecord ('testschema','Test messages','com.mathworks.avro',false);
            D2 = testCase.reader.getSchema();
            testCase.verifyEqual(class(D1),class(D2));
            testCase.verifyEqual(D1.Type,D2.Type);
        end
        function testGetMetaKeys(testCase)
            D1 = ["avro.schema"];
            D2 = testCase.reader.getMetaKeys();
            testCase.verifyEqual(D1,D2);
        end
        function testGetMetaString(testCase)
            D2 = testCase.reader.getMetaString('avro.schema');
            testCase.assertNotEmpty(D2);
        end
        function testNext(testCase)
            D1.Age = 38;
            D1.Smoker = true;
            D1.Height = 71;
            D1.Weight = 176;
            D1.BloodPressure = 124;
            D2 = testCase.reader.next();
            testCase.verifyEqual(D1,D2);
        end
    end
    
end

