classdef testGenericData < matlab.unittest.TestCase
    % TESTGENERICDATA This is a test stub for a unit testing
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
        gData
    end
    methods (TestMethodSetup)
        function testSetup(testCase)
            testCase.gData = matlabavro.GenericData();
        end
    end
    
    methods (TestMethodTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        function testGet(testCase)
            D1 = 'matlabavro.GenericData';
            D2 = testCase.gData.get();
            testCase.verifyEqual(D1,class(D2));
        end       
    end
    
end

