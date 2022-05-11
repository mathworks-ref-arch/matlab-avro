function [schemaStructure,tmpMap] = getSchemaStructure(data, dataMap)
%GETSCHEMASTRUCTURE Generate schema for MATLAB data based on type
% Creates a structure of the data and create a JSON string using jsonencode
% to create  the schema.

% Copyright (c) 2020-2022 MathWorks, Inc.

if nargin < 2
    dataMap = containers.Map;
end
tmpMap = dataMap;
% if(isempty(data))
%     schemaStructure = getAvroNullStructure();
%     tmpMap = [];
%     return;
% end

if isPrimativeType(data)
    schemaStructure = getSchemaForPrimativeType(data);

elseif isCategoricalOrEnum(data)
    schemaStructure = getSchemaForCategoricalOrEnum(data);

elseif iscell(data)
    [schemaStructure,tmpMap] = getSchemaForCellArray(data, dataMap);

elseif isTabular(data)
    dataAsStruct = table2struct(data);
    [schemaStructure,tmpMap] = parseStructFields(dataAsStruct);

elseif isstruct(data)
    [schemaStructure,tmpMap] = parseStructFields(data);

elseif isobject(data)
    [schemaStructure,tmpMap] = parseStructFields(data);
    schemaStructure.name = class(data);
end
end

%% Sub-functions below

function schemaStructure = getNumericDataStructure(data)
if(isa(data,'int8'))
    schemaStructure = getPrimitiveStructure(data);
    return;
end

if isscalar(data) % scalar
    schemaStructure = getPrimitiveStructure(data);
elseif iscolumn(data) % column vector
    schemaStructure = getVectorStructure(data);
else %matrix. 2d array in avro
    schemaStructure = get2DArrayStructure(data);
end
end


function [schemaStructure, tmpMap] = getSchemaForCellArray(data, dataMap)
% Returns schema for cell array

if isempty(data)
    % in order to differentiate a numeric/string array null from a cell
    % array null try using a union schema
    nullType  = getAvroNullStructure();
    doubleType = matlabavro.getAvroType('double');
    
    schemaStructure = {nullType.type; doubleType};
    tmpMap = dataMap;

else
    % Check if homogenous cell with primitive type
    try
        innerData = cell2mat(data);

        % if no error, all cells share the same type
        % treat as avro union, recurse to get underlying type/structure
        [innerStructure, tmpMap] = matlabavro.getSchemaStructure(innerData, dataMap);

        % For Avro union, return schema strcuture in cell array
        schemaStructure = {innerStructure};

    catch ME
        % Is this an non-homogenous cell, or an error
        isMixedType = strcmp(ME.identifier, 'MATLAB:cell2mat:MixedDataTypes');
        isNestedCell = strcmp(ME.identifier, 'MATLAB:cell2mat:UnsupportedCellContent');

        if isMixedType || isNestedCell
            % Warn that this will be converted to a strucutre, and may
            % require additional work to read back into a cell array
            warningMessage = "Attempting to generate Avro Scheme for " ...
                + "cell array that is not homogenous in data type. This " ...
                + "will be converted to a structure in MATLAB and " ...
                + "generating an Avro Record Schema. Additional work " ...
                + "may be required to reconstruct into a cell array on read.";

            warningID = 'matlabavro:getSchemaStructure:nonUniformCellArray';

            warning(warningID, warningMessage);

            tmpDatastruct = table2struct(cell2table(data));
            [innerStructure, tmpMap] = parseStructFields(tmpDatastruct);
            schemaStructure = {innerStructure};

        else
            newException = MException('matlabavro:getSchemaStructure:getSchemaForCellArray', ...
                "Error in dynamic generation of schema for data provided. Consider assigning a schema manually. Use matlabavro.Schema.parse method");

            newException = newException.addCause(ME);
            throw(newException)
        end
    end
end
end


function schemaStructure = getStringDataStructure(data)

% to get consistent size/dimension informat, look at string version of text
dataAsString = string(data);

if isscalar(dataAsString) 
    %single char or char array/string
    schemaStructure = getPrimitiveStructure(dataAsString);
elseif iscolumn(dataAsString)
    %column vector of strings
    schemaStructure = getVectorStructure(dataAsString);
else
    % row, or matrix of strings
    schemaStructure = get2DArrayStructure(dataAsString);
end
end

function schemaStructure = getLogicalDataStructue(data)

if isscalar(data) %scalar
    schemaStructure = getPrimitiveStructure(data);

elseif iscolumn(data) % column vector
    schemaStructure = getVectorStructure(data);

else  % matrix. 2d array in avro
    schemaStructure = get2DArrayStructure(data);
    return;
end
end

function schemaStructure = getEnumDataStructue(enumName)
vals = string(enumeration(enumName));
schemaStructure.type = 'enum';
schemaStructure.name = enumName;
schemaStructure.symbols = vals;
end

function schemaStructure = getCategoricalDataStructue(data)
vals = categories(data);
schemaStructure.type = 'enum';
schemaStructure.name = matlab.lang.makeValidName(char(java.util.UUID.randomUUID()));
schemaStructure.symbols = vals;
end

function schemaStructure = getVectorStructure(data)
schemaStructure.type = 'array';
if(iscell(data))
    schemaStructure.items = matlabavro.getAvroType(class(data{1}));
else
    schemaStructure.items = matlabavro.getAvroType(class(data));
end
end

% function schemaStructure = getVectorStructureForTable(data)
% schemaStructure.type = 'array';
% schemaStructure.items = matlabavro.getAvroType(class(data));
% end

function schemaStructure = get2DArrayStructure(data)
tmpSt.type = 'array';
dataElementClass = getMATLABType(data);
tmpSt.items = matlabavro.getAvroType(dataElementClass);
schemaStructure.type = 'array';
schemaStructure.items = tmpSt;
end

function schemaStructure = getPrimitiveStructure(data)
schemaStructure.type = matlabavro.getAvroType(class(data));
end

function schemaStructure = getAvroNullStructure()
schemaStructure.type = 'null';
end

function matlabType = getMATLABType(data)
matlabType = class(data);
if iscell(data)
    matlabType = getMATLABType(data{1});
end
end

% function schemaStructure = parseObjectProperties(data)
% props = properties(data);
% fields = getFields(data,props);
% schemaStructure = getSchemaStructureFromFields(fields);
% schemaStructure.name = class(data);
% end

function [schemaStructure,dataMap] = parseStructFields(data)
% Create schema structure if type of data is a MATLAB struct
try
    props = fieldnames(data);

    if isempty(props)
        % struct to hold schema - must have name, and type must be null
        emptyFields = struct('name','data', 'type', 'null', 'formattedData', []); 
        dataMap = containers.Map();

        emptyStructureSchema = getSchemaStructureFromFields(emptyFields);

        % in order to differentiate from a record or empty cell try union
        nullType  = getAvroNullStructure();

        schemaStructure = {nullType.type; emptyStructureSchema};

    else
        [fields,dataMap] = getFields(data,props);
        schemaStructure = getSchemaStructureFromFields(fields);
    end
    
    

catch ME
    newException = MException('matlabavro:getSchemaStructure:ParseStructFields', ...
        "Error in dynamic generation of schema for data provided. Consider assigning a schema manually. Use matlabavro.Schema.parse method");

    newException = newException.addCause(ME);
    throw(newException)	
end
end

function [fields,dataMap] = getFields(data, props)
% Creates fields structure array that will jsonencode into Avro schema and dataMap

dataMap = containers.Map();

for pCount = 1:numel(props)
    thisFieldsName = props{pCount};

    % create struct to hold schema for field
    fields(pCount) = struct('name',[],'type',[],'formattedData',[]);  %#ok<*AGROW>
    fields(pCount).name = thisFieldsName;

    % Problem: accessing a field from a struct array
    % Assumption: homogenous fields - is this a valid constraint/assumption?

    %     numeric/logical fields concatenate with [] or vertcat
    %     textual fields as strings concatenate with [] or vertcat
    %     nested struct/table/objects concatenate with {}

    % try - test for string, vertcat the rest, else error

    try
        % check if text, and convert to string if needed
        fieldHasTextTF = isTextStructField(data, thisFieldsName);

        if fieldHasTextTF
            thisFieldsData = concatenateTextFromStructField(data, thisFieldsName);
        else
            thisFieldsData = vertcat(data.(thisFieldsName));
        end

    catch ME
        % possibly bad vertcat, warn on homogeneity assumption
        newException = MException('matlabavro:getSchemaStructure:getFields', ...
            "Error in concatenation of structure field " + thisFieldsName ...
            + " confirm field is of consistent type, or consider assigning" ...
            + " a schema manually. Use matlabavro.Schema.parse method");

        newException = newException.addCause(ME);
        throw(newException)
    end

    [thisFieldsType, dataMap] = innerFieldMethod(thisFieldsName, thisFieldsData, dataMap);
    fields(pCount).type = thisFieldsType;

end
end

% function dataMap  = addDataToRecord(innerSchemaStructure,data,dataMap)
% innerSchemaString = jsonencode(innerSchemaStructure);
% innerSchemaString = strrep(strrep(innerSchemaString,'[[','['),']]',']');
% innerSchema =  matlabavro.Schema.parse(innerSchemaString);
% genericRecord = javaObject('org.apache.avro.generic.GenericData$Record',innerSchema.jSchemaObj);
% genericRecord.put(field.name,data);
% dataMap(field.name) = genericRecord;
% end


function schemaStructure = getSchemaStructureFromFields(fields)
schemaStructure.type = 'record';
schemaStructure.namespace = 'com.mathworks.avro';
%Generate random name - only alphabets allowed. should not start with
%numbers/spec.chars.
randString = matlab.lang.makeValidName(char(java.util.UUID.randomUUID()));
schemaStructure.name = randString;
schemaStructure.fields = {fields};
end

function schemaStructure = getSchemaForPrimativeType(data)
if isempty(data)
    schemaStructure = getAvroNullStructure();
elseif islogical(data)
    schemaStructure = getLogicalDataStructue(data);
elseif isnumeric(data)
    schemaStructure = getNumericDataStructure(data);
elseif isTextual(data)
    schemaStructure = getStringDataStructure(data);
end
end

function schemaStructure = getSchemaForCategoricalOrEnum(data)
if isenum(data)
    schemaStructure = getEnumDataStructue(class(data));
elseif iscategorical(data)
    schemaStructure = getCategoricalDataStructue(data);
end
end

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

function TF = isPrimativeType(data)
% Returns true if data is numeric, logical, or textual

isNumericOrLogicalData = isnumeric(data) || islogical(data);
isTextualData = isTextual(data);

% enums will return true for isnumeric, but false for isobject
isNumericOrLogicalData = isNumericOrLogicalData && ~isobject(data);

TF = isNumericOrLogicalData || isTextualData;
end

function TF = isCategoricalOrEnum(data)
TF = iscategorical(data) || isenum(data);
end

function TF = isTextual(data)
% Returns true if data is character, string, or cellstring
isCharOrString = ischar(data) || isstring(data);
isNonEmptyCellStr = iscellstr(data) && ~isempty(data); %#ok<ISCLSTR>

TF = isCharOrString || isNonEmptyCellStr;
end

function TF = isTextStructField(data, thisFieldsName)
% Returns true if structfield is character, string, or cellstring

% access first element
firstElement = data(1).(thisFieldsName);

if isempty(firstElement)
    TF = false;
    return;
end

if isscalar(firstElement)
    TF = isTextual(firstElement);
else
    TF = isTextual(firstElement(1,:));
end

end

function thisFieldsData = concatenateTextFromStructField(data, thisFieldsName)
% Returns text field of structure as single string return value

% access first element
firstElement = data(1).(thisFieldsName);

% Char and cellstr vertcat better after converting to strings
if ischar(firstElement) 
    if isscalar(data)
        thisFieldsData = cellstr(data.(thisFieldsName));
    else
        % Collect as cell array - loosing shape in the process
        fieldAsCell = {data.(thisFieldsName)}; 
        
        % Convert to cellstr for easys tring conversion later
        thisFieldsData = cellstr(fieldAsCell);

        % reshape based on data
        thisFieldsData = reshape(thisFieldsData, size(data));
    end

    % convert to string now will work
    thisFieldsData = string(thisFieldsData);

elseif iscellstr(firstElement) %#ok<ISCLSTR>
    thisFieldsData = string(data.(thisFieldsName));

else % string
    thisFieldsData = vertcat(data.(thisFieldsName));
end

end


function [thisFieldsType, dataMap] = innerFieldMethod(thisFieldsName, thisFieldsData, dataMap)
% Maps struct field data into dataMap, and recurses for nested structures

[thisFieldsType, tmpMap] = matlabavro.getSchemaStructure(thisFieldsData, dataMap);

if isTextual(thisFieldsData)
    aSchema = matlabavro.Schema.createSchemaForData(thisFieldsData);

    preparedData = matlabavro.AvroHelper.createDataToAppend(aSchema, thisFieldsData);
    dataMap(thisFieldsName) = preparedData;

else
    if isa(thisFieldsData,'int8')
        numBytesToAllocate = numel(thisFieldsData);
        bytesBuffer = java.nio.ByteBuffer.allocate(numBytesToAllocate);

        % Dump all elements irresective of scalar/array/matrix. Use
        % meta info to reshape in case of array/msatrix
        bytesBuffer.put(thisFieldsData(:));
        bytesBuffer.rewind();
        dataMap(thisFieldsName) = bytesBuffer;

    elseif isa(thisFieldsData, 'struct') || isa(thisFieldsData, 'cell')
        % Both have their own maps
        if isempty(thisFieldsData)
            dataMap(thisFieldsName) = [];
        elseif isempty(tmpMap)
            dataMap(thisFieldsName) = thisFieldsData;
        else
            dataMap(thisFieldsName) = tmpMap;
        end
    else
        dataMap(thisFieldsName) = thisFieldsData;
    end
end
end
