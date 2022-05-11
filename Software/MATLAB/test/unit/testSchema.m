classdef testSchema < matlab.unittest.TestCase
    % TESTSCHEMA This is a test stub for a unit testing
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
        className
    end
    
    methods (TestMethodSetup)

        function testSetup(testCase)
            testCase.schema = matlabavro.Schema;
            testCase.className = 'matlabavro.Schema';
        end
    end

    methods (Test)

        function testParse(testCase)
            schemaString = '{"type":"double"}';
            D1 = matlabavro.SchemaType.DOUBLE;
            D2 = testCase.schema.parse(schemaString);
            testCase.verifyEqual(testCase.className, class(D2));
            testCase.verifyEqual(D1, matlabavro.SchemaType.(char(D2.Type)));

        end

        function testCreate(testCase)
            D1 = matlabavro.SchemaType.BYTES;
            D2 = testCase.schema.create(D1);
            testCase.verifyEqual(testCase.className, class(D2));
            testCase.verifyEqual(D1, matlabavro.SchemaType.(char(D2.Type)));
        end
        
        function testCreateArray(testCase)
            stype = matlabavro.SchemaType.INT;
            D1 =  matlabavro.SchemaType.ARRAY;
            D2 = testCase.schema.createArray(stype);
            testCase.verifyEqual(testCase.className, class(D2));
            testCase.verifyEqual(D1, matlabavro.SchemaType.(char(D2.Type)));
        end
        
        function testCreateMap(testCase)
            stype = matlabavro.SchemaType.INT;
            D1 =  matlabavro.SchemaType.MAP;
            D2 = testCase.schema.createMap(stype);
            testCase.verifyEqual(testCase.className, class(D2));
            testCase.verifyEqual(D1, matlabavro.SchemaType.(char(D2.Type)));
        end
        
        function testCreateFixed(testCase)
            D1 =  matlabavro.SchemaType.FIXED;
            D2 = testCase.schema.createFixed('fixedName','','',3);
            testCase.verifyEqual(testCase.className, class(D2));
            testCase.verifyEqual(D1, matlabavro.SchemaType.(char(D2.Type)));
        end
        
        function testCreateRecord(testCase)
            D1 =  matlabavro.SchemaType.RECORD;
            D2 = testCase.schema.createRecord('recName','','com.mathworks.avro',false);
            testCase.verifyEqual(testCase.className, class(D2));
            testCase.verifyEqual(D1, matlabavro.SchemaType.(char(D2.Type)));
        end
        
        function testCreateSchemaForEnum(testCase)
            D1 = matlabavro.SchemaType.ENUM;
            D2 =  testCase.schema.createEnum('Weekdays');
            testCase.verifyEqual(D1, D2.Type);
        end
        
        function testCreateUnion(testCase)
            tmpSchema1 = matlabavro.Schema.create(matlabavro.SchemaType.INT);
            tmpSchema2 = matlabavro.Schema.create(matlabavro.SchemaType.DOUBLE);
            tmpSchema3 = matlabavro.Schema.create(matlabavro.SchemaType.FLOAT);
            D1 = matlabavro.SchemaType.UNION;
            D2 = testCase.schema.createUnion({tmpSchema1, tmpSchema2, tmpSchema3});
            testCase.verifyEqual(testCase.className, class(D2));
            testCase.verifyEqual(D1, matlabavro.SchemaType.(char(D2.Type)));
        end
       
        function testGetElementType(testCase)
            D1 = matlabavro.SchemaType.INT;
            D2 = testCase.schema.createArray(D1);
            elementType = D2.getElementType();
            testCase.verifyEqual(testCase.className, class(elementType));
            testCase.verifyEqual(D1, matlabavro.SchemaType.(char(elementType.Type)));
        end
        
        function testGetName(testCase)
            D1 = matlabavro.SchemaType.INT;
            D2 = testCase.schema.create(D1);
            elementName = D2.getName();
            testCase.verifyEqual(D1, elementName);
        end
        
        function testToString(testCase)
            D1 = """int""";
            D2 = testCase.schema.create(matlabavro.SchemaType.INT).toString();                       
            testCase.verifyEqual(D1, D2);
        end
        
        function testGetFullName(testCase)
            D1 = "int";
            D2 = testCase.schema.create(matlabavro.SchemaType.INT);
            elementFullName = D2.getFullName();
            testCase.verifyEqual(D1, elementFullName);
        end
        
        function testSetGetFields(testCase)
            tmpSchema = testCase.schema.createRecord('recName','','com.mathworks.avro',false);
            tmpSchema2 = testCase.schema.create(matlabavro.SchemaType.INT);
            intVal = int32(20);
            f1 = matlabavro.Field("new1", tmpSchema2,'',intVal);
            f2 = matlabavro.Field("new2", tmpSchema2,'',intVal);
            D1 = {f1, f2};
            tmpSchema.setFields(D1);
            D2 = tmpSchema.getFields();
            testCase.verifyEqual(D1{1}.name, D2{1}.name);
            testCase.verifyEqual(D1{2}.name, D2{2}.name);
            testCase.verifyEqual(D1{1}.schema, D2{1}.schema);
            testCase.verifyEqual(D1{2}.schema, D2{2}.schema);
        end
        
       
        
        function testCreateSchemaForDouble(testCase)
            D1 = matlabavro.SchemaType.DOUBLE;
            D2 =  testCase.schema.createSchemaForData(42);
            testCase.verifyEqual(D1, D2.Type);
        end  
        
        function testCreateSchemaForString(testCase)
            D1 = matlabavro.SchemaType.STRING;
            D2 =  testCase.schema.createSchemaForData('test data');
            testCase.verifyEqual(D1, D2.Type);           
        end
        
        function testCreateSchemaForRowVector(testCase)
            % row becomes 2D matrix in column major world
            D1 = matlabavro.SchemaType.ARRAY; 
            D1InnerType = matlabavro.SchemaType.DOUBLE;

            input = [1,2,3];
            D2 =  testCase.schema.createSchemaForData(input);
            
            testCase.verifyEqual(D2.Type, D1);

            D3 = D2.getElementType;
            testCase.verifyEqual(D3.Type, D1);

            D4 = D3.getElementType;
            testCase.verifyEqual(D4.Type, D1InnerType);
        end
        
        function testCreateSchemaForColumnVector(testCase)
            D1 = matlabavro.SchemaType.ARRAY; 
            D1ElementType = matlabavro.SchemaType.DOUBLE;
            input = [1,2,3]';
            D2 =  testCase.schema.createSchemaForData(input);
            testCase.verifyEqual(D1, D2.Type);           
            testCase.verifyEqual(D1ElementType, D2.getElementType.Type);           
        end
        
        function testCreateSchemaForMatrix(testCase)
            D1 = matlabavro.SchemaType.ARRAY; 
            D1ElementType = matlabavro.SchemaType.ARRAY;
            input = reshape(1:10e3, 1e3, 10);
            D2 =  testCase.schema.createSchemaForData(input);
            testCase.verifyEqual(D1, D2.Type);           
            testCase.verifyEqual(D1ElementType, D2.getElementType.Type);           
        end  
        
        function testCreateSchemaForStruct(testCase)
            input = getStruct(5e3);  
            D1 = matlabavro.SchemaType.RECORD;                    
            D2 =  testCase.schema.createSchemaForData(input);
            testCase.verifyEqual(D1, D2.Type);                       
        end
        
        function testCreateSchemaForArrayStruct(testCase)
            tmpArr = [1,2,3]';
            tmpStruct.B  = tmpArr;             
            innerSchemaType = matlabavro.SchemaType.DOUBLE;
            D1 = matlabavro.SchemaType.RECORD;                    
            D2 =  testCase.schema.createSchemaForData(tmpStruct);
            D2Fields = D2.getFields();            
            D2FieldInnerType = D2Fields{1}.schema.getElementType.Type;
            testCase.verifyEqual(D1, D2.Type);                       
            testCase.verifyEqual(innerSchemaType, D2FieldInnerType);                       
        end 
        
        function testCreateSchemaForSimpleCellArray(testCase)
            input = {1, 2, 3; 4,5,6};
            
            % Expected types
            expectedArrayType = matlabavro.SchemaType.ARRAY;
            expectedDoubleType = matlabavro.SchemaType.DOUBLE;
            expectedUnionType = matlabavro.SchemaType.UNION;
            
            % Test creation of schema
            D2 =  testCase.schema.createSchemaForData(input);

            % Cell should be represented as an Avro UNION
            testCase.verifyEqual(D2.Type, expectedUnionType);

            firstType = D2.getTypes{1};
            D3 = firstType.Type;
            D4 = firstType.getElementType().Type;
            D5 = firstType.getElementType().getElementType().Type;

            testCase.verifyEqual(D3, expectedArrayType);
            testCase.verifyEqual(D4, expectedArrayType);
            testCase.verifyEqual(D5, expectedDoubleType);
        end
        
        function testCreateSchemaForTable(testCase)
            LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
            Age = [38;43;38;40;49];
            Smoker = [1;0;1;0;1];
            Height = [71;69;64;67;64];
            Weight = [176;163;131;133;119];            
            input = table(LastName, Age, Smoker, Height, Weight);           
            D2 = testCase.schema.createSchemaForData(input);

            D2Fields = D2.getFields();

            expectedRecordType = matlabavro.SchemaType.RECORD;
            expectedArrayType = matlabavro.SchemaType.ARRAY;
            expectedStringType = matlabavro.SchemaType.STRING;
            expectedDoubleType = matlabavro.SchemaType.DOUBLE;

            % MATLAB Table will be an Avro record
            testCase.verifyEqual(D2.Type, expectedRecordType);

            % First field should be string
            nameField = D2Fields{1};
            nameSchema = nameField.schema;
            elementType = nameSchema.Type;
            innerType = nameSchema.getElementType().Type;

            testCase.verifyEqual(elementType, expectedArrayType);
            testCase.verifyEqual(innerType, expectedStringType);

            % remaining fields should be arrays of doubles
            numVariables = width(input);
            for colIdx = 2:numVariables
                thisField = D2.getFields{colIdx};
                thisSchema = thisField.schema;
                elementType = thisSchema.Type;
                innerType = thisSchema.getElementType().Type;

                testCase.verifyEqual(elementType, expectedArrayType);
                testCase.verifyEqual(innerType, expectedDoubleType);
            end
        end
        
        function testCreateSchemaForMatrixFromData(testCase)
            input = reshape(1:20,5,4)';
            D1 = matlabavro.SchemaType.ARRAY;
            D2 = testCase.schema.createSchemaForData(input);
            testCase.verifyEqual(D1,D2.Type);
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

