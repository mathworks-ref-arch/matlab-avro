classdef testAvroSerializeDeSerialize < matlab.unittest.TestCase
    % TESTAVROSERIALIZER This is a test stub for a unit testing
    % The assertions that you can use in your test cases:
    %
    %    assertTrue
    %    assertFalse
    %    assertEqual
    %    assertFilesEqual
    %    assertElementsAlmostEqual
    %    assertVectorsAlmostEqual
    %    assertExceptionThrown
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Please add your test cases below
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (c) 2020 MathWorks, Inc.
    methods (TestMethodSetup)
        function testSetup(testCase)
            
        end
    end
    
    methods (TestMethodTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        function testScalarBinary(testCase)
            D1 = 42;
            tmpSchema = matlabavro.Schema.create(matlabavro.SchemaType.DOUBLE);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testStringBinary(testCase)
            D1 = 'testing string serializing';
            tmpSchema = matlabavro.Schema.create(matlabavro.SchemaType.STRING);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);            
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testRowVectorBinary(testCase)
            D1 = [1,2,3];
            tmpSchema = matlabavro.Schema.createArray(matlabavro.SchemaType.DOUBLE);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,1,3,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorBinary1(testCase)
            D1 = [1,2,3]';
            tmpSchema = matlabavro.Schema.createArray(matlabavro.SchemaType.DOUBLE);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,3,1,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorBinary2(testCase)
            D1.x = linspace(0,6)';
            D1.y = sin(D1.x);
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testMatrixBinary(testCase)
            D1 = reshape(1:10e3, 1e3, 10);
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testStructBinary(testCase)
            D1 = getStruct(5e3);
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testArrayInStructBinary(testCase)
            B = [1,2,3]';
            A.B  = B;
            D1 = A;
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testSimpleCellArrayBinary(testCase)
            D1 = {1, 2, 3; 4,5,6};
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,1,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testTableBinary(testCase)
            LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
            Age = [38;43;38;40;49];
            Smoker = [1;0;1;0;1];
            Height = [71;69;64;67;64];
            Weight = [176;163;131;133;119];
            D1 = table(LastName,Age,Smoker, Height,Weight);
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(1,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testComplexCellArrayBinary(testCase)
            D1 = reshape(1:20,5,4)';
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testScalarJSON(testCase)
            D1 = 42;
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);            
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testStringJSON(testCase)
            D1 = 'testing string serializing';
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);            
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testRowVectorJSON(testCase)
            D1 = [1,2,3];
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,1,3,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorJSON1(testCase)
            D1 = [1,2,3]';
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,3,1,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorJSON2(testCase)
            D1.x = linspace(0,6)';
            D1.y = sin(D1.x);
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testMatrixJSON(testCase)
            D1 = reshape(1:10e3, 1e3, 10);            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testStructJSON(testCase)
            D1 = getStruct(5e3);            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testArrayInStructJSON(testCase)
            B = [1,2,3]';
            A.B  = B;
            D1 = A;            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testSimpleCellArrayJSON(testCase)
            D1 = {1, 2, 3; 4,5,6};            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,1,2,3,D2);
            D2 = num2cell(D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testTableJSON(testCase)
            LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
            Age = [38;43;38;40;49];
            Smoker = [1;0;1;0;1];
            Height = [71;69;64;67;64];
            Weight = [176;163;131;133;119];
            D1 = table(LastName,Age,Smoker, Height,Weight);            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(1,0,0,0,D2);
            D2 = struct2table(D2);
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testComplexCellArrayJSON(testCase)
            D1 = reshape(1:20,5,4)';            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(0,0,0,0,D2);
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

