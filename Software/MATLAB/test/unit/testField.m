classdef testField < matlab.unittest.TestCase
    % TESTFIELD This is a test stub for a unit testing
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
    % Copyright (c) 2020 MathWorks, Inc.
    properties
        schema
        field
    end
    
    methods (TestMethodSetup)
        function testSetup(testCase)
            tmp = matlabavro.Schema();
            testCase.schema = tmp.create(matlabavro.SchemaType.INT);
            intVal = int32(20);
            testCase.field = matlabavro.Field('new',testCase.schema,'',intVal);
        end
    end
    
    methods (TestMethodTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        
        function testName(testCase)
            D1 = "new";
            D2 = testCase.field.name();
            testCase.verifyEqual(D1,D2);
        end
        
        function testSchema(testCase)
            D1 = testCase.schema;
            D2 = testCase.field.schema();
            testCase.verifyEqual(D1,D2);
        end
        
    end
    
end

