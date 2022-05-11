classdef AvroHelper
    %% AVROHELPER Helper class to create data structure complying with avro schema
    
    % Copyright (c) 2020-2022 MathWorks, Inc.
    
    methods(Static)
        
        function outRecord = createDataToAppend(schema, data)
            %% Create data structure conforming to schema from MATLAB structures and tables, and data types like int8 which map to bytebuffer.
            % INPUT
            %   schema - matlabavro.schema for the data
            %   data - MATLAB data to append

            validateattributes(schema,{'matlabavro.Schema'},{});

            import org.apache.avro.generic.*;
            import java.util.ArrayList;
            import java.util.Collection;
            try

                if matlabavro.AvroHelper.isTabular(data) % builtin in R2021b
                    data = table2struct(data,'ToScalar',true);
                    outRecord = matlabavro.AvroHelper.prepareStructDataForAppending(schema, data);

                elseif matlabavro.AvroHelper.isCellAndNotCellStr(data) % Treat cellstr as text below
                    outRecord = matlabavro.AvroHelper.prepareCellDataForApending(schema, data);

                elseif matlabavro.AvroHelper.isText(data)
                    outRecord = matlabavro.AvroHelper.prepareTextDataForApending(schema, data);

                elseif isstruct(data) || isobject(data)
                    outRecord = matlabavro.AvroHelper.prepareStructDataForAppending(schema, data);

                elseif isa(data,'int8')
                    bytesBuffer = java.nio.ByteBuffer.allocate(numel(data));
                    % Dump all elements irresective of scalar/array/matrix. Use
                    % meta info to reshape in case of array/matrix
                    bytesBuffer.put(data(:));
                    bytesBuffer.rewind();
                    outRecord = bytesBuffer;

                elseif matlabavro.AvroHelper.isCastableData(data)
                    outRecord = matlabavro.AvroHelper.prepareNumericDataForApending(schema, data);
                else
                    outRecord = data;
                end

            catch ME
                newException = MException('matlabavro:AvroHelper:createDataToAppend', ...
                    "Unable to prepare MATLAB data for Avro.");

                newException = newException.addCause(ME);
                throw(newException)
            end
        end

%         function innerRecord = getInnerRecord()
%             
%         end

        function bytesBuffer = getBytesBuffer(data)
            bytesBuffer = java.nio.ByteBuffer.allocate(numel(data));
                % Dump all elements irresective of scalar/array/matrix. Use
                % meta info to reshape in case of array/matrix
            [a,b] = size(data);
            for i=1:a
                for j=1:b
                    if(iscell(data{i,j}))
                         bytesBuffer.put(getBytesBuffer(data{i,j}));
                    else
                         bytesBuffer.put(java.lang.String(data{i,j}).getBytes());
                    end
                end
            end
            bytesBuffer.rewind();                
        end
        
        function outputArg = convertToMATLABObject(inputData)
            %% Pass in data read from an avro file and convert to MATLAB object
            % inputData - data read from an avro file.
            
            outputArg = jsondecode(char(inputData.toString));
            className = inputData.getSchema.getName;
            
            % Construct the MATLAB object
            mlObj = feval(char(className)); %#ok<*AGROW>
            
            % Populate MATLAB object properties
            pNames = fieldnames(mlObj);
            
            for pCount = 1:numel(pNames)
                mlObj.(pNames{pCount})=outputArg.(pNames{pCount});
            end
            outputArg = mlObj;
        end
        
        function outputArg = convertToMATLAB(metaInformation, inputData)
            %% Pass in data read from an avro file and convert to MATLAB type based on flags/metadata
            % isTable - convert to table
            % isCell - convert to cell
            % rows - number of rows to use for reshape
            % columns - number of columns to use for reshape

            if isempty(inputData)
                outputArg = matlabavro.AvroHelper.getEmtpyValueForSchema(metaInformation);
                return;
            end

            isRecord = isa(inputData,'org.apache.avro.generic.GenericData$Record');
            isArray = isa(inputData,'org.apache.avro.generic.GenericData$Array');
            isUnion = metaInformation.schema.Type == matlabavro.SchemaType.UNION;

            if isUnion
                % Unpack types and recurse
                innerTypes = metaInformation.schema.jSchemaObj.getTypes().toArray();
                innerSchemaString = string(innerTypes(1).toString());

                % Update MATLAB schema object to inner type schema
                innerSchema = matlabavro.Schema.parse(innerSchemaString);
                innerMetaInformation = metaInformation;
                innerMetaInformation.schema = innerSchema;
                innerMetaInformation.isCell = true;

                outputArg = matlabavro.AvroHelper.convertToMATLAB(innerMetaInformation, inputData);

            elseif isRecord
                outputArg = matlabavro.AvroHelper.convertAvroGenericDataRecordToMATLAB(metaInformation, inputData);

            elseif isArray
                outputArg = matlabavro.AvroHelper.convertAvroGenericDataArrayToMATLAB(metaInformation, inputData);

            elseif isa(inputData,'org.apache.avro.util.Utf8')
                outputArg = char(inputData);
                outputArg = matlabavro.AvroHelper.convertAvroTextToMATLABString(metaInformation.schema, outputArg);

            elseif isa(inputData,'java.nio.HeapByteBuffer')
                outputArg = inputData.array();

                outputArg = matlabavro.AvroHelper.metaReshapeData(outputArg, metaInformation); 

            else
                outputArg = inputData;

                outputArg = matlabavro.AvroHelper.metaReshapeData(outputArg, metaInformation); 

                % convert Types
                outputArg = matlabavro.AvroHelper.convertTypes(metaInformation, outputArg);
            end
        end



    end

    methods(Static, Access = private)   

        function TF = isTabular(data)
            % Returns true if data istable or istimetable
            %
            % became a shipping function in MATLAB R2021b, v9.12
            if verLessThan('matlab', '9.12')
                TF = istable(data) || isa(data,'timetable');
            else
                TF = istabular(data);
            end
        end

        function TF = isText(data)
            % Returns true if data ischar is isstring
            TF = ischar(data) || isstring(data) || iscellstr(data);
        end
        
        function TF = isCellAndNotCellStr(data)
            % Returns true if data is cell array and not a cellstr
            if isempty(data) && iscell(data)
                TF = true;
            else
                TF = iscell(data) && ~matlabavro.AvroHelper.isText(data); 
            end
        end

        function outputArg = metaReshapeData(outputArg, metaInformation)
            curRows = size(outputArg, 1);

            metaRowsSpecified = metaInformation.rows > 0;

            metaRowsAndCurRowsMisMatch = curRows ~= metaInformation.rows;

            needsMetaInformationResize = metaRowsSpecified && metaRowsAndCurRowsMisMatch;

            if needsMetaInformationResize
                outputArg = reshape(outputArg, metaInformation.rows, metaInformation.cols);
            end
        end

        function outRecord = prepareTextDataForApending(schema, data)

            if matlabavro.AvroHelper.isText(data)
                data = string(data);
            end

            % convert row of char/string or col of char to java string
            if isscalar(data)
                outRecord = java.lang.String(data);

            elseif iscolumn(data) % isvector(data) %  1-D array in Java - a column
                numElements = numel(data);
                outRecord = javaObject('org.apache.avro.generic.GenericData$Array', numElements, schema.jSchemaObj);

                encodedData = jsonencode(data);
                outRecord.add(encodedData);

            else % requires 2-d array to get rows, MxN

                % Determine size of data in 2D
                [numRows, numCols] = size(data);

                try
                    % get inner and outter schemas
                    outerSchema = schema.jSchemaObj;
                    innerSchema = schema.getElementType().jSchemaObj;

                    % Create a array of Avro Arrays using outer schema
                    outRecord = javaObject('org.apache.avro.generic.GenericData$Array', numRows, outerSchema);

                    for rowIdx = 1:numRows
                        % Create array of strings using inner schema
                        thisRow = javaObject('org.apache.avro.generic.GenericData$Array', numCols, innerSchema);

                        for colIdx = 1:numCols
                            encodedData = jsonencode(data(rowIdx, colIdx));

                            javaColIdx = colIdx - 1;
                            thisRow.add(javaColIdx, encodedData);
                        end

                        javaRowIdx = rowIdx - 1;
                        outRecord.add(javaRowIdx, thisRow);
                    end

                catch ME
                    newException = MException('matlabavro:AvroHelper:prepareTextDataForApending', ...
                        "Error in preparing text data for Avro writing.");

                    newException = newException.addCause(ME);
                    throw(newException)
                end
            end
        end

        function outRecord = prepareNumericDataForApending(schema, data)

            if isscalar(data) || iscolumn(data) || isempty(data)
                % scalar and 1-D columns write directly
                outRecord = data;

            else % requires 1-d array to get rows, MxN

                % Determine size of data in 2D
                [numRows, numCols] = size(data);

                % get inner and outter schemas
                outerSchema = schema.jSchemaObj;
                innerSchema = schema.getElementType().jSchemaObj;

                % Create an Avro Arrays for the columns using outer schema
                outRecord = javaObject('org.apache.avro.generic.GenericData$Array', numCols, outerSchema);

                for rowIdx = 1:numRows
                    % Create array of strings using inner schema
                    thisRow = javaObject('org.apache.avro.generic.GenericData$Array', numCols, innerSchema);

                    for colIdx = 1:numCols
                        thisData = data(rowIdx, colIdx);

                        javaColIdx = colIdx - 1;
                        thisRow.add(javaColIdx, thisData);
                    end

                    javaRowIdx = rowIdx - 1;
                    outRecord.add(javaRowIdx, thisRow);
                end
            end
        end
        
        function data = prepareCellDataForApending(schema, data)

            if isempty(data)
                data = [];
                return;
            end

            % Check if homogenous cell with primitive type
            try
                innerData = cell2mat(data);

                % if no error, all cells share the same type, recurse
                innerSchema = matlabavro.Schema.createSchemaForData(innerData);
                data = matlabavro.AvroHelper.createDataToAppend(innerSchema, innerData);
                return;

            catch ME
                % Is this an non-homogenous cell, or an error
                isMixedType = strcmp(ME.identifier, 'MATLAB:cell2mat:MixedDataTypes');
                isNestedCell = strcmp(ME.identifier, 'MATLAB:cell2mat:UnsupportedCellContent');

                if isMixedType || isNestedCell
                    % Warn that this will be converted to a strucutre, and may
                    % require additional work to read back into a cell array
                    warningMessage = "Attempting to generate Avro Schema for " ...
                        + "cell array that is not homogenous in type. This " ...
                        + "will be converted to a structure in MATLAB and " ...
                        + "generating an Avro Record Schema. Additional work " ...
                        + "may be required to reconstruct into a cell array on read.";

                    warningID = 'matlabavro:AvroHelper:nonUniformCellArray';

                    warning(warningID, warningMessage);

                else
                    newException = MException('matlabavro:AvroHelper:prepareCellDataForApending', ...
                        "Error in preparing cell data for Avro writing.");

                    newException = newException.addCause(ME);
                    throw(newException)
                end
            end

            % Check if we can convert to struct
            try
                % Convert to struct
                [a,b] = size(data);

                if(a>1 && b == 1)
                    data = data';
                end
                data = table2struct(cell2table(data));
            catch ME
                newException = MException('matlabavro:AvroHelper:prepareCellDataForApending', ...
                    "Error in converting cell array to struct array.");

                newException = newException.addCause(ME);
                throw(newException)
            end

            % Get inner/field schema
            try
                fieldSchemaArray = schema.jSchemaObj.getTypes().toArray();
                firstFieldSchemaString = string(fieldSchemaArray(1).toString());
                innerSchema = matlabavro.Schema.parse(firstFieldSchemaString);
                innerSchema.dataMap = schema.dataMap;

            catch ME
                newException = MException('matlabavro:AvroHelper:prepareCellDataForApending', ...
                    "Error in accessing field data of java Avro schema object.");

                newException = newException.addCause(ME);
                throw(newException)
            end

            % Recurse
            data = matlabavro.AvroHelper.createDataToAppend(innerSchema, data);
        end

        function outRecord = prepareStructDataForAppending(schema, data)
            emptyStruct = struct();

            if isempty(data) || isequal(data, emptyStruct)
                outRecord = [];

            elseif isenum(data) || iscategorical(data)
                genericRecord = javaObject('org.apache.avro.generic.GenericData$EnumSymbol', schema.jSchemaObj, string(data));
                outRecord =  genericRecord;

            else
                genericRecord = javaObject('org.apache.avro.generic.GenericData$Record', schema.jSchemaObj);
                outRecord =  matlabavro.AvroHelper.createRecordForStruct(genericRecord, schema.dataMap);

            end
        end

        function genericRecord = createRecordForStruct(genericRecord, dataMap)
            %% Creates avro generic record for a struct data type
            % genericRecord - initial generic record
            % data to write to avro            

            mySchema = genericRecord.getSchema();
            schemaFields =  mySchema.getFields().toArray();            
            
            for fieldCount = 1:numel(schemaFields)
                % field metadata
                thisFieldName = schemaFields(fieldCount).name;
                thisFieldSchema = schemaFields(fieldCount).schema();

                if isempty(dataMap)
                    thisFieldData = [];
                else
                    thisFieldData = dataMap(char(thisFieldName));
                end

                % for nested Records we need to recurse
                thisFieldIsRecord = strcmp(thisFieldSchema.getType.toString(), 'RECORD') == 1;

                % Unions can hide records
                thisFieldIsUnion = strcmp(thisFieldSchema.getType.toString(), 'UNION') == 1;
                thisDataIsMap = isa(thisFieldData, 'containers.Map');
                thisFieldIsUnionOfRecord = thisFieldIsUnion && thisDataIsMap;
                
                % If union of record, update schema, and use record path
                if thisFieldIsUnionOfRecord
                    innerTypes = thisFieldSchema.getTypes.toArray();
                    
                    thisFieldSchema = innerTypes(1);
                    thisFieldIsRecord = true;
                end

                % Populates the properties
                if thisFieldIsRecord
                    innerRec = javaObject('org.apache.avro.generic.GenericData$Record', thisFieldSchema);
                    innerPayload = matlabavro.AvroHelper.createRecordForStruct(innerRec, thisFieldData);
                    
                    genericRecord.put(thisFieldName, innerPayload);

                else
                    % Create matlabavro schema for this field
                    stringOfFieldSchema = string(thisFieldSchema.toString());
                    matlabavroSchemaOfField = matlabavro.Schema.parse(stringOfFieldSchema);

                    % Get Avro packaged field
                    avroPreparedFieldData = matlabavro.AvroHelper.createDataToAppend(matlabavroSchemaOfField, thisFieldData);

                    genericRecord.put(thisFieldName, avroPreparedFieldData);    
                end
            end
        end

        function dNext = convertTypes(metaInformation, dNext)

            try
                isCastable = matlabavro.AvroHelper.isCastableData(dNext);

                isTextData = matlabavro.AvroHelper.isText(dNext);
                isAvroStringArray = matlabavro.AvroHelper.isStringArrayAvroSchema(metaInformation.schema);

                isText =  isTextData || isAvroStringArray;
                
                % Cast basic types
                if isCastable
                    matlabType = matlabavro.AvroHelper.getMATLABTypeForAvroArray(metaInformation.schema);
                    dNext = cast(dNext, matlabType);

                elseif isText
                    dNext = matlabavro.AvroHelper.convertAvroTextToMATLABString(metaInformation.schema, dNext);

                elseif isstruct(dNext)
                    dNext = matlabavro.AvroHelper.convertStructType(metaInformation.schema, dNext);

                end
                
                % Convert to Cell Array if required
                isUnionSchema = metaInformation.schema.Type == "UNION";
                isCellMeta = metaInformation.isCell;
                treatAsCell = isUnionSchema || isCellMeta;

                if treatAsCell && ~iscell(dNext)
                    dNext = num2cell(dNext);
                end
            
            catch ME
                rethrow(ME);
            end
        end

        function TF = isStringArrayAvroSchema(schema)
            try
                schemaTypeAsString = lower(string(schema.Type));
                
                % if string, return T
                if schemaTypeAsString == "string"
                    TF = true;

                elseif schemaTypeAsString == "array"
                    % gett inner type
                    innerSchema = schema.getElementType();

                    % recurse
                    TF = matlabavro.AvroHelper.isStringArrayAvroSchema(innerSchema);

                else
                    TF = false;
                end

            catch ME
                newException = MException(...
                    'matlabavro:AvroHelper:isStringArrayAvroSchema', ...
                    "Unable to determine leaf element type from Avro schema.");

                newException = newException.addCause(ME);
                throw(newException)
            end
        end
    
        function outputArg = convertAvroGenericDataArrayToMATLAB(metaInformation, inputAvroArray)

            schemaType = inputAvroArray.getSchema().getType().toString();
            elementType = inputAvroArray.getSchema().getElementType().toString();

            elementTypeString = erase(string(elementType), """");

            isArraySchema = lower(string(schemaType)) == "array";
            isStringType = lower(elementTypeString) == "string";

            isStringArray = isArraySchema && isStringType;

            if ~isStringArray % should only decode text?
                outputArg = jsondecode(char(inputAvroArray.toString));
            else
                arrayData = inputAvroArray.toArray();
                output = '';
                for i =1:numel(arrayData)
                    output = [output;char(arrayData(i).toString())];
                end
                outputArg = output;
            end

            outputArg = matlabavro.AvroHelper.metaReshapeData(outputArg, metaInformation);

            if(metaInformation.isCell == 1) && ~iscell(outputArg)
                outputArg = num2cell(outputArg);
            end

            % convert Types
            outputArg = matlabavro.AvroHelper.convertTypes(metaInformation, outputArg);
        end

        function outputArg = convertAvroGenericDataRecordToMATLAB(metaInformation, inputData)

            outputArg = jsondecode(char(inputData.toString));

            if isstruct(outputArg)

                % We need to check for embedded types that require special
                % handling - type information is in schema string.
                thisSchema = inputData.getSchema();
                thisSchemaString = thisSchema.toString();

                containsByteString = thisSchemaString.contains(java.lang.String('bytes'));
                containsString = thisSchemaString.contains(java.lang.String('string'));

                %Check if any field is bytes - requires conversion to int8
                if containsByteString

                    props = fieldnames(outputArg);
                    for pCount = 1:numel(props)
                        if thisSchema.getField(props{pCount}).schema.getType().toString().equals("BYTES")
                            outputArg.(props{pCount}) = inputData.get(props{pCount}).array();
                        end
                    end
                end

                %Check if any field is string - requires additional decoding?
                if containsString
                    outputArg = matlabavro.AvroHelper.convertStructStringField(metaInformation, inputData, outputArg);
                end

                % Perform data type conversion while still in struct form
                outputArg = matlabavro.AvroHelper.convertStructType(metaInformation.schema, outputArg);

                outputArg = matlabavro.AvroHelper.applyStructMetaTransforms(metaInformation, outputArg);
                
            elseif ismatrix(inputData)
                outputArg = inputArg;
                outputArg = matlabavro.AvroHelper.metaReshapeData(outputArg, metaInformation);

                if(metaInformation.isCell == 1)
                    outputArg = mat2cell(outputArg);
                end
            end
        end

        function dNext = convertAvroTextToMATLABString(schema, dNext)

            try
                schemaTypeAsString = lower(string(schema.Type));

                isTextData = matlabavro.AvroHelper.isText(dNext);
                isAvroStringArray = matlabavro.AvroHelper.isStringArrayAvroSchema(schema);

                if schemaTypeAsString == "array" && isTextData
                    dNext = string(jsondecode(dNext));

                elseif isTextData
                    dNext = string(dNext);

                elseif iscell(dNext) && schemaTypeAsString == "string"
                    dNext = string(dNext{:});

                elseif iscell(dNext) && isAvroStringArray
                    dNext = string(dNext{1})';
                end
                
            catch ME
                newException = MException(...
                    'matlabavro:AvroHelper:convertAvroTextToMATLABString', ...
                    "Unable to convert Avro text data to MATLAB string.");

                newException = newException.addCause(ME);
                throw(newException)
            end
        end
        
        function outputArg = convertStructStringField(metaInformation, inputData, outputArg)

            thisSchema = inputData.getSchema();

            props = fieldnames(outputArg);
            for pCount = 1:numel(props)
                % convenience vairable
                thisProp = props{pCount};
                thisField = thisSchema.getField(thisProp);
                thisFieldSchema = thisField.schema;

                thisFieldTypeString = string(thisFieldSchema.getType().toString());

                isArrayTypeString = thisFieldTypeString == "ARRAY";

                if ~isArrayTypeString
                    outputArg = matlabavro.AvroHelper.convertStructType(metaInformation.schema, outputArg);
                    return;
                end

                thisFieldElement = string(thisFieldSchema.getElementType().toString());

                isStringElementTypeString = isArrayTypeString && thisFieldElement == """string""";

                if isStringElementTypeString
                    encodedChar = char(inputData.get(thisProp).toString());
                    decodedChar = jsondecode(encodedChar); % R2017b jsondecode requires char
                    unpackedChar = decodedChar{1};
                    outputArg.(thisProp) = convertCharsToStrings(unpackedChar);
                end
            end
        end

        function isCastable = isCastableData(data)
            isCastable = isnumeric(data) || islogical(data);
        end

        function outputArg = applyStructMetaTransforms(metaInformation, outputArg)

            if metaInformation.isTable == 1
                outputArg = struct2table(outputArg);
                outputArg = matlabavro.AvroHelper.metaReshapeData(outputArg, metaInformation);

            elseif metaInformation.isCell == 1
                try
                    % Works when no struct field is empty
                    outputArg = table2cell(struct2table(outputArg));
                catch
                    % works with empty struct field
                    outputArg = table2cell(struct2table(outputArg, 'AsArray', true));
                end
            end
        end

        function dNext = convertStructType(schema, dNext)
            % get fields
            javaSchemaFields = schema.jSchemaObj.getFields().toArray();
            dataFieldList = string(fieldnames(dNext));

            schemaFieldCount = numel(javaSchemaFields);
            dataFieldCount = numel(dataFieldList);

            % error if not matching
            if (schemaFieldCount ~= dataFieldCount)
                error('matlabavro:AvroHelper:invalidTypeSchema', ...
                    'Schema does not appear to match data. Inconsistend field count.')
            end

            % iterate over fields
            for aField = 1:numel(dataFieldList)
                % find matching fields
                fieldName = dataFieldList(aField);
                schemaName = string(javaSchemaFields(aField).name);

                if fieldName ~= schemaName
                    error('matlabavro:AvroHelper:convertStructType', ...
                    'Schema field order inconsistent between matlab and java avro schemas.')
                end

                % Get schema object for field
                schemaForField = javaSchemaFields(aField).schema;
                schemaStringForField = string(schemaForField.toString());
                schemaObjForField = matlabavro.Schema.parse(schemaStringForField);

                % Call inner field method to convert
                dNext.(fieldName) = matlabavro.AvroHelper.convertStructFieldType(schemaObjForField, dNext, fieldName);
            end
        end

        function convertedData = convertStructFieldType(schemaObjForField, data, fieldName)

            % predicates for switching behavior
            isUnion = schemaObjForField.Type == matlabavro.SchemaType.UNION;
            isArray = schemaObjForField.Type == matlabavro.SchemaType.ARRAY;
            isRecord = schemaObjForField.Type == matlabavro.SchemaType.RECORD;

            if isUnion
                convertedData = matlabavro.AvroHelper.convertUnionStructFieldType(schemaObjForField, data, fieldName);

            elseif ~isRecord && ~isArray
                % Scalar type values can be converted directly
                convertedData = matlabavro.AvroHelper.castAvroTypedDataToMATLABTypedData(data.(fieldName), schemaObjForField.Type);

            elseif isArray
                convertedData = matlabavro.AvroHelper.convertArrayStructFieldType(schemaObjForField, data, fieldName);

            elseif isRecord
                % Struct type values need inspection

                % get struct field, and recurse
                thisFieldData = data.(fieldName);
                convertedData = matlabavro.AvroHelper.convertStructType(schemaObjForField, thisFieldData);
            end

        end

        function matlabType = getMATLABTypeForAvroArray(schema)
            %% Return the corresponding MATLAB type for element

            basicAvroTypes = ["BOOLEAN", "BYTES", "DOUBLE", "FLOAT", "INT", "LONG" "STRING"];

            try
                if ismember(schema.Type, basicAvroTypes) % scalar schema
                    avroType = schema.Type;
                elseif(schema.Type == "ARRAY")
                    avroType = matlabavro.AvroHelper.getAvroInnerTypeFromAvroArraySchema(schema);
                elseif (schema.Type == "UNION")
                    avroType = matlabavro.AvroHelper.getAvroTypesFromAvroUnionSchema(schema);
                else
                    avroType = schema.Type;
                end

                % Get mapping from Avro type to MATLAB type
                avroTypeString = lower(string(avroType));
                matlabType = matlabavro.getMATLABType(avroTypeString);

            catch ME
                rethrow(ME);
            end

        end

        function avroType = getAvroInnerTypeFromAvroArraySchema(schema)
            % Returns Avro Type for Inner-Most Element of N-D Avro Array

            % Matrices, or Avro Arrays, may have more than one
            % level of nesting before getting to the underlying
            % datatype so using a recursive approach

            % While the inner schema matches the outer, recurse
            aSchema = schema.jSchemaObj;
            while aSchema.getType() == aSchema.getElementType().getType()
                aSchema = aSchema.getElementType();
            end

            % No longer matching, so return inner schema
            aSchema = aSchema.getElementType();

            % Get decoded string
            schemaChar = char(aSchema.toString()); 
            avroType = jsondecode(schemaChar); % R2017b jsonencode requires char
        end

        function convertedData = convertArrayStructFieldType(schemaObjForField, data, fieldName)

            % get field schema
            schemaForField = schemaObjForField.jSchemaObj;
            schemaStringForField = string(schemaForField.toString());

            isArrayOfString = contains(schemaStringForField, "string");

            % cell arrays need to be unpacked
            if isArrayOfString && iscell(data.(fieldName)) && isscalar(data.(fieldName))
                cellData = data.(fieldName);
                convertedData = matlabavro.AvroHelper.castAvroTypedDataToMATLABTypedData(cellData{1}, schemaObjForField.Type);

            elseif ~isArrayOfString  % array possibly in need of casting and not a string -
                % get type for schema
                matlabType = matlabavro.AvroHelper.getMATLABTypeForAvroArray(schemaObjForField);

                % convert type
                convertedData = cast(data.(fieldName), matlabType);
            else
                convertedData = data.(fieldName);
            end
        end
        function convertedData = convertUnionStructFieldType(schemaObjForField, data, fieldName)

            if isempty(data.(fieldName)) % Avro Union -> used for empty
                convertedData = {};
            else
                % Get union types, and recurse
                schemaForField = schemaObjForField.jSchemaObj;
                innerTypeArray = schemaForField.getTypes().toArray();
                innerTypeSchemaString = string(innerTypeArray(1).toString());
                innerSchemaObj = matlabavro.Schema.parse(innerTypeSchemaString);

                innerData = matlabavro.AvroHelper.convertStructFieldType(innerSchemaObj, data, fieldName);
                % convertedData = {innerData};
                hasInnerRecord = innerSchemaObj.Type == matlabavro.SchemaType.RECORD;

                if hasInnerRecord
                    try
                        % Works when no struct field is empty
                        convertedData = table2cell(struct2table(innerData));
                    catch
                        % works with empty struct field
                        convertedData = table2cell(struct2table(innerData, 'AsArray', true));
                    end
                else
                    convertedData = num2cell(innerData);
                end

            end
        end

        function avroTypes = getAvroTypesFromAvroUnionSchema(schema)
            % Returns Avro type from a Avro Union Schema

            % Avro Unions may have a number of types
            % get types from java schema
            unionTypes = schema.jSchemaObj.getTypes().toArray();

            if numel(unionTypes) > 1
                % Avro unions are not supported - issue warning,
                % and abort efforts at datatype conversion
                errorMsg = "MATLAB Avro does not currently support unions of mulitple types.";
                error('matlabavro:AvroHelper:getAvroTypesFromAvroUnionSchema', errorMsg);
            end

            outerElement = unionTypes(1);
            outerType = outerElement.getType();
            outerTypeAsString = string(outerType.toString());
            
            if outerTypeAsString == "ARRAY"
                % Check if inner and outter are same (2D or higher array)
                innerElement = outerElement.getElementType();

                outerClass = string(class(outerElement));
                innerClass = string(class(innerElement));

                while outerClass == innerClass
                    % If both are array, go down to next level
                    outerElement = innerElement;

                    innerElement = innerElement.getElementType();

                    outerClass = string(class(outerElement));
                    innerClass = string(class(innerElement));
                end

                avroTypes = string(innerElement.toString());
            else
                avroTypes = outerTypeAsString;
            end

            % conversion may result in extra quotes (i.e. ""double"")
            avroTypes = erase(avroTypes, """");
        end

        function outputArg = getEmtpyValueForSchema(metaInformation)

            % Assume it is neither a union or union of record
            isUnion = false;
            isUnionOfRecord = false;

            % is this a union
            if ~isempty(metaInformation.schema)
                schemaTypeString = string(metaInformation.schema.Type);
                isUnion = schemaTypeString == "UNION";
            end

            % is this a union of a record (a.k.a. struct/table)
            if isUnion
                jSchema = metaInformation.schema.jSchemaObj;
                unionTypesString = string(jSchema.getTypes().toString());
                
                isUnionOfRecord = contains(unionTypesString, "record");
            end

            if metaInformation.isTable
                outputArg = table();

            elseif isUnionOfRecord
                outputArg = struct();

            elseif metaInformation.isCell || isUnion
                outputArg = {};
            
            else
                outputArg = [];
            end

        end

        function MATLABTypedData = castAvroTypedDataToMATLABTypedData(AvroTypedData, AvroType)
            % convert to MATLAB type
            avroTypeString = lower(string(AvroType));

            if avroTypeString == "null"
                % empty value, use MATLAB default
                MATLABTypedData = [];
            else

                matlabTypeString = matlabavro.getMATLABType(avroTypeString);

                % caste not supported for conversion to strings
                if matlabTypeString == "string"
                    MATLABTypedData = string(AvroTypedData);
                else
                    MATLABTypedData = cast(AvroTypedData, matlabTypeString);
                end
            end
        end
    end
    
end %class
