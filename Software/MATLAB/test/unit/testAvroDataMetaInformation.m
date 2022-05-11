classdef testAvroDataMetaInformation < matlab.unittest.TestCase
    
    % Copyright (c) 2022, MathWorks, Inc.

    properties
    end

    methods(Test)
       
        function shouldConstructWarningFreeUsingDefaultConstructor(testCase)
            defaultConstructor = @() matlabavro.AvroDataMetaInformation();

            testCase.verifyWarningFree(defaultConstructor, ...
                'AvroDataMetaInformation should construct warning free when using default constructor.');
        end

        function shouldConstructWarningFreeUsingMatlabAvroSchema(testCase)
            sampleData = pi;
            mSchemaObj = matlabavro.Schema.createSchemaForData(sampleData);

            mSchemaConstructor = @() matlabavro.AvroDataMetaInformation(mSchemaObj);

            testCase.verifyWarningFree(mSchemaConstructor, ...
                'AvroDataMetaInformation should construct warning free when using matlabavro Schema object.');
        end

        function shouldConstructWarningFreeUsingJavaSchema(testCase)
            sampleData = pi;
            mSchemaObj = matlabavro.Schema.createSchemaForData(sampleData);
            jSchemaObj = mSchemaObj.jSchemaObj;

            jSchemaConstructor = @() matlabavro.AvroDataMetaInformation(jSchemaObj);


            testCase.verifyWarningFree(jSchemaConstructor, ...
                'AvroDataMetaInformation should construct warning free when using java schema object.');
        end

        function shouldSetSchemaOnConstructionWithMATLABAvroSchema(testCase)
            sampleData = rand(4, 3, 'single');
            expectedSchema = matlabavro.Schema.createSchemaForData(sampleData);

            testMetaDataInformation = matlabavro.AvroDataMetaInformation(expectedSchema);

            testSchema = testMetaDataInformation.schema;

            testCase.verifyEqual(testSchema, expectedSchema, ...
                'AvroDataMetaInformation should set schema property to matlabavro.Schema object on construction with matlabavro.Schema object.');
        end

        function shouldSetSchemaOnConstructionWithJavaSchema(testCase)
            sampleData = rand(4, 3, 'single');
            actualMATLABSchema = matlabavro.Schema.createSchemaForData(sampleData);
            actualJavaSchema = actualMATLABSchema.jSchemaObj;

            testMetaDataInformation = matlabavro.AvroDataMetaInformation(actualJavaSchema);

            testMATLABSchema = testMetaDataInformation.schema;
            testJavaSchema = testMATLABSchema.jSchemaObj;

            % Verify schema was constructed
            testCase.verifyClass(testMATLABSchema, 'matlabavro.Schema', ...
                'AvroDataMetaInformation should construct a matlabavro.Schema when constructed with Java avro schema object.')

            % Verify schema type correct
            testCase.verifyEqual(testMATLABSchema.Type, actualMATLABSchema.Type, ...
                'AvroDataMetaInformation should set schema property to matlabavro.Schema object on construction with matlabavro.Schema object');

            % verify underlying java object same
            testCase.verifyEqual(testJavaSchema, actualJavaSchema, ...
                'AvroDataMetaInformation matlabavro.Schema should have identical underlying Java avro schema when created from Java avro schema');
        end

        function shouldSetIsCellTrueIsTableFalseOnConstructionWithCellData(testCase)
            sampleCellArray = {pi};
            testMetaDataInformation = matlabavro.AvroDataMetaInformation(sampleCellArray);

            testCase.verifyTrue(testMetaDataInformation.isCell, ...
                'AvroDataMetaInformation should set isCell to true when constructed with cell array data.')

            testCase.verifyFalse(testMetaDataInformation.isTable, ...
                'AvroDataMetaInformation should set isTable to false when constructed with cell array data.')

        end

        function shouldSetIsCellFalseIsTableFalseOnConstructionWithDoubleData(testCase)
            sampleDoubleArray = pi;
            testMetaDataInformation = matlabavro.AvroDataMetaInformation(sampleDoubleArray);

            testCase.verifyFalse(testMetaDataInformation.isCell, ...
                'AvroDataMetaInformation should set isCell to false when constructed with numeric data.')

            testCase.verifyFalse(testMetaDataInformation.isTable, ...
                'AvroDataMetaInformation should set isTable to false when constructed with numeric data.')
        end

        function shouldSetIsCellTrueOnConstructionWithUnionMATLABAvroSchema(testCase)
            sampleCellArray = {pi};
            actualMATLABSchema = matlabavro.Schema.createSchemaForData(sampleCellArray);

            testMetaDataInformation = matlabavro.AvroDataMetaInformation(actualMATLABSchema);

            testSchemaType = testMetaDataInformation.schema.Type;
            actualType = matlabavro.SchemaType.UNION;

            % Verify Actual MATLAB Schema was Union type
            testCase.verifyEqual(actualMATLABSchema.Type, actualType, ...
                'matlabavro Schema Type should be Union for cell array.');

            % Verify test schema has Union type
            testCase.verifyEqual(testSchemaType, actualType, ...
                'matlabavro Schema Type should be Union for cell array.');
            
            % Verify iscell set correctly
            testCase.verifyTrue(testMetaDataInformation.isCell, ...
                'AvroDataMetaInformation should set isCell to true when constructed from union matlabavro schema.')
        end

        function shouldSetIsCellTrueOnConstructionWithUnionJavaAvroSchema(testCase)
            sampleSchemaString = "[""double""]";
            actualMATLABSchema = matlabavro.Schema.parse(sampleSchemaString);
            actualJavaSchema = actualMATLABSchema.jSchemaObj;

            testMetaDataInformation = matlabavro.AvroDataMetaInformation(actualJavaSchema);

            testSchemaType = testMetaDataInformation.schema.Type;
            actualType = matlabavro.SchemaType.UNION;

            % Verify Actual MATLAB Schema was Union type
            testCase.verifyEqual(actualMATLABSchema.Type, actualType, ...
                'matlabavro Schema Type should be Union for cell array.');

            % Verify test schema has Union type
            testCase.verifyEqual(testSchemaType, actualType, ...
                'matlabavro Schema Type should be Union for cell array.');
            
            % Verify iscell set correctly
            testCase.verifyTrue(testMetaDataInformation.isCell, ...
                'AvroDataMetaInformation should set isCell to true when constructed from union java schema.')
        end

        function shouldSetIsTableTrueIsCellFalseOnConstructionWithTableData(testCase)
            sampleTable = table(["Hello"; "World"], [1; 2], 'VariableNames', {'testString', 'testNum'});

            testMetaDataInformation = matlabavro.AvroDataMetaInformation(sampleTable);

            testCase.verifyTrue(testMetaDataInformation.isTable, ...
                'AvroDataMetaInformation should set isTable to true when constructed with table data.')

            testCase.verifyFalse(testMetaDataInformation.isCell, ...
                'AvroDataMetaInformation should set isCell to false when constructed with table data.')
        end

    end
end

