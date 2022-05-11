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
    % Copyright (c) 2020 MathWorks, Inc.
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

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema, bytes);
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testStringBinary(testCase)
            D1 = "testing string serializing";
            tmpSchema = matlabavro.Schema.create(matlabavro.SchemaType.STRING);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1); 

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema,bytes);

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testRowVectorBinary(testCase)
            D1 = [1,2,3];
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);

            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);

            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = tmpSchema;

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(tmpSchema, bytes);

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testColumnVectorBinary1(testCase)
            D1 = [1; 2; 3];
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);

            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);

            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = tmpSchema;

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(metaInformation.schema, bytes);

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testColumnVectorBinary2(testCase)
            D1.x = linspace(0,6)';
            D1.y = sin(D1.x);
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);

            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = tmpSchema;

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(metaInformation.schema, bytes);
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testMatrixBinary(testCase)
            D1 = reshape(1:10e3, 1e3, 10);
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);
            
            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = tmpSchema;

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(metaInformation.schema,bytes);
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testStructBinary(testCase)
            D1 = getStruct(5e3);
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);

            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = tmpSchema;

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(metaInformation.schema,bytes);
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testArrayInStructBinary(testCase)
            B = [1,2,3]';
            A.B  = B;
            D1 = A;
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);

            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = tmpSchema;

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(metaInformation.schema,bytes);
            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testSimpleCellArrayBinary(testCase)
            D1 = {1, 2, 3; 4, 5, 6};
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);

            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.isCell = true;
            metaInformation.schema = tmpSchema;

            % Avro schema doesn't know about a cell array
            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(metaInformation.schema, bytes);
            testCase.verifyEqual(D2, D1, 'The values read should not be as written.');

            D3 = matlabavro.AvroHelper.convertToMATLAB(metaInformation, D2);
            testCase.verifyEqual(D3, D1, 'The values read and transposed should be as written.');
        end
        
        function testTableBinary(testCase)
            LastName = ["Sanchez"; "Johnson"; "Li"; "Diaz"; "Brown"];
            Age = [38;43;38;40;49];
            Smoker = [1;0;1;0;1];
            Height = [71;69;64;67;64];
            Weight = [176;163;131;133;119];
            D1 = table(LastName,Age,Smoker, Height,Weight);
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);

            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = tmpSchema;
            metaInformation.isTable = true;

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(metaInformation.schema, bytes);
            D2 = matlabavro.AvroHelper.convertToMATLAB(metaInformation, D2);

            testCase.verifyEqual(D2.Age, D1.Age, 'The values read should be as written.');
            testCase.verifyEqual(D2.Smoker, D1.Smoker, 'The values read should be as written.');
            testCase.verifyEqual(D2.Height, D1.Height, 'The values read should be as written.');
            testCase.verifyEqual(D2.Weight, D1.Weight, 'The values read should be as written.');
            testCase.verifyEqual(D2.LastName, D1.LastName, 'The values read should be as written .');
        end
        
        function testComplexCellArrayBinary(testCase)
            D1 = reshape(1:20,5,4)';
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            bytes = matlabavro.AvroSerializer.serializeToBinary(tmpSchema,D1);

            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = tmpSchema;

            D2 = matlabavro.AvroDeSerializer.deserializeFromBinary(metaInformation.schema, bytes);

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testScalarJSON(testCase)
            D1 = 42;
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);

            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testStringJSON(testCase)
            D1 = 'testing string serializing';
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);

            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);

            testCase.verifyEqual(D2, D1, 'The values read should be as written.');
        end
        
        function testRowVectorJSON(testCase)
            D1 = [1,2,3];
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);

            testCase.verifyNotEqual(D2, D1, ['The values read should not ' ...
                'be as written. MATLAB does not guarantee that the shape ' ...
                'of an array is preserved. For example, a 1-by-N numeric ' ...
                'vector is encoded as an array. If you call jsondecode, ' ...
                'then MATLAB decodes the array as an N-by-1 vector.']);

            D3 = D2';
            testCase.verifyEqual(D3, D1, 'The values read and transposed should be as written.');
        end
        
        function testColumnVectorJSON1(testCase)
            D1 = [1; 2; 3];
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);

            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testColumnVectorJSON2(testCase)
            D1.x = linspace(0,6)';
            D1.y = sin(D1.x);
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);

            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testMatrixJSON(testCase)
            D1 = reshape(1:10e3, 1e3, 10);            

            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            
            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testStructJSON(testCase)
            D1 = getStruct(5e3);            
            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);

            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        function testArrayInStructJSON(testCase)
            B = [1,2,3]';
            A.B  = B;
            D1 = A;            

            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);

            testCase.verifyEqual(D1, D2, 'The values read should be as written.');
        end
        
        function testSimpleCellArrayJSON(testCase)
            D1 = {1, 2, 3; 4,5,6};            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
            
            testCase.verifyNotEqual(D1, D2, 'The values read should be as written.');
            
            % create metainformation for reading/conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = matlabavro.Schema.create(matlabavro.SchemaType.DOUBLE);
            metaInformation.isCell = true;
            % Do we need the next two rows?
            metaInformation.rows = 2;
            metaInformation.cols = 3;

            D3 = matlabavro.AvroHelper.convertToMATLAB(metaInformation, D2);
            
            testCase.verifyEqual(D3, D1, 'The values read should be as written after converted to cell.');
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

            testCase.verifyNotEqual(D2, D1, 'The values read should not be as written for Table over JSON.');
            
            D3 = struct2table(D2);
            testCase.verifyEqual(D3, D1, 'The values read should be as written after calling struct2table.');
        end
        
        function testComplexCellArrayJSON(testCase)
            D1 = reshape(1:20,5,4)';            
            bytes = matlabavro.AvroSerializer.serializeToJSON(D1);
            D2 = matlabavro.AvroDeSerializer.deserializeFromJSON(bytes);
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

