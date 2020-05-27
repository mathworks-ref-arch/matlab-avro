function schemaStructure = getSchemaStructure(data)
%GETSCHEMASTRUCTURE Generate schema for MATLAB data based on type
% Creates a structure of the data and create a JSON string using jsonencode
% to create  the schema.

if isstruct(data)
    schemaStructure = parseStructFields(data);
elseif(isobject(data))
    schemaStructure = parseObjectProperties(data);
elseif isscalar(data) || ischar(data)
    schemaStructure = getPrimitiveStructure(data);
elseif isvector(data)
    schemaStructure = getVectorStructure(data);
elseif ismatrix(data)
    schemaStructure = get2DArrayStructure(data);
end
end

function schemaStructure = getVectorStructure(data)
schemaStructure.type = 'array';
if(iscell(data))
    schemaStructure.items = matlabavro.getAvroType(class(data{1}));
else
    schemaStructure.items = matlabavro.getAvroType(class(data));
end
end

function schemaStructure = getVectorStructureForTable(data)
schemaStructure.type = 'array';
schemaStructure.items = matlabavro.getAvroType(class(data));
end
function schemaStructure = get2DArrayStructure(data)
tmpSt.type = 'array';
tmpSt.items = matlabavro.getAvroType(class(data(1,1)));
schemaStructure.type = 'array';
schemaStructure.items = tmpSt;
end

function schemaStructure = getPrimitiveStructure(data)
schemaStructure.type = matlabavro.getAvroType(class(data));
end

function schemaStructure = parseObjectProperties(data)
props = properties(data);
fields = getFields(data,props);
schemaStructure = getSchemaStructureFromFields(fields);
schemaStructure.name = class(data);
end

function schemaStructure = parseStructFields(data)
% Create schema structure if type of data is a MATLAB struct
try
    props = fieldnames(data);
    fields = getFields(data,props);
    schemaStructure = getSchemaStructureFromFields(fields);    
catch ME
    displayMsg = 'parseStructFields: Error in dynamic generation of schema for data provided. Consider assigning a schema manually. Use matlabavro.Schema.parse method';
    error(displayMsg);
end
end
function fields = getFields(data,props)
%TODO  - Rewrite to handle data types without redundant code.
for pCount = 1:numel(props)
    fields(pCount) = struct('name',[],'type',[]);  %#ok<*AGROW>
    if(numel(data) >1)
        if(isa(data(1).(props{pCount}),'int8'))
            fields(pCount).name = props{pCount};
            fields(pCount).type = "bytes";
        elseif(isa(data(1).(props{pCount}),'logical'))
            fields(pCount).name = props{pCount};
            fields(pCount).type = getVectorStructureForTable(data(1).(props{pCount}));
        elseif(isa(data(1).(props{pCount}),'numeric'))            
                fields(pCount).name = props{pCount};
                fields(pCount).type = getVectorStructureForTable(data(1).(props{pCount}));            
        elseif(isa(data(1).(props{pCount}),'char'))
            fields(pCount).name = props{pCount};
            fields(pCount).type = getVectorStructureForTable(data(1).(props{pCount}));
        elseif isa(data(1).(props{pCount}),'struct')
            fields(pCount).name = props{pCount};
            tmpStruct = getSchemaStructure(data(1).(props{pCount}));
            fields(pCount).type = tmpStruct;
        elseif ismatrix(data(1).(props{pCount}))
            fields(pCount).name = props{pCount};
            fields(pCount).type = get2DArrayStructure(data(1).(props{pCount}));
        end
    else
        %special handling for bytes. TODO - redesign int8 handling
        if(isa(data.(props{pCount}),'int8'))
            fields(pCount).name = props{pCount};
            fields(pCount).type = "bytes";
        elseif(isa(data.(props{pCount}),'logical'))
            fields(pCount).name = props{pCount};            
            if(numel(data.(props{pCount})) == 1) 
                fields(pCount).type = getPrimitiveStructure(data.(props{pCount}));
            elseif (isa(data.(props{pCount}),'Array') || size(data.(props{1}),1) > 1)
                fields(pCount).type = getVectorStructure(data.(props{pCount}));
            else
                %matrix
                fields(pCount).type = get2DArrayStructure(data.(props{pCount}));
            end
        elseif(isa(data.(props{pCount}),'numeric'))
            if isscalar(data.(props{pCount}))
                fields(pCount).name = props{pCount};
                fields(pCount).type = matlabavro.getAvroType(class(data.(props{pCount})));
            elseif isvector(data.(props{pCount}))
                fields(pCount).name = props{pCount};
                fields(pCount).type = getVectorStructure(data.(props{pCount}));
            elseif ismatrix(data.(props{pCount}))
                fields(pCount).name = props{pCount};
                if(size(data.(props{pCount}),2) == 1)
                    fields(pCount).type = getVectorStructure(data.(props{pCount}));
                else
                    fields(pCount).type = get2DArrayStructure(data.(props{pCount}));
                end
            end
        elseif(isa(data.(props{pCount}),'char') || isa(data.(props{pCount}),'string'))
            if (isa(data.(props{pCount}),'Array') || size(data.(props{1}),1) > 1)
                fields(pCount).name = props{pCount};
                fields(pCount).type = getVectorStructure(data.(props{pCount}));
            else
                fields(pCount).name = props{pCount};
                fields(pCount).type = matlabavro.getAvroType(class(data.(props{pCount})));
            end
        elseif isa(data.(props{pCount}),'struct')
            fields(pCount).name = props{pCount};
            tmpStruct = matlabavro.getSchemaStructure(data.(props{pCount}));
            fields(pCount).type = tmpStruct;
        elseif ismatrix(data.(props{pCount}))
            fields(pCount).name = props{pCount};
            if(size(data.(props{pCount}),2) == 1)
                fields(pCount).type = getVectorStructure(data.(props{pCount}));
            else
                fields(pCount).type = get2DArrayStructure(data.(props{pCount}));
            end
            
        end
    end
end
end
function schemaStructure = getSchemaStructureFromFields(fields)
schemaStructure.type = 'record';
schemaStructure.namespace = 'com.mathworks.avro';
%Generate random name - only alphabets allowed. should not start with
%numbers/spec.chars.
randString = matlab.lang.makeValidName(char(java.util.UUID.randomUUID()));
schemaStructure.name = randString;
schemaStructure.fields = {fields};
end
