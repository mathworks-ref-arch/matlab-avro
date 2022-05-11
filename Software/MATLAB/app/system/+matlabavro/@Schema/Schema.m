classdef Schema < handle
    %% Schema Schema for avro data
    %
    % A schema may be one of:
    % A record, mapping field names to field value data;
    % An enum, containing one of a small set of symbols;
    % An array of values, all of the same schema;
    % A map, containing string/value pairs, of a declared schema;
    % A union of other schemas;
    % A fixed sized binary object;
    % A unicode string;
    % A sequence of bytes;
    % A 32-bit signed int;
    % A 64-bit signed long;
    % A 32-bit IEEE single-float; or
    % A 64-bit IEEE double-float; or
    % A boolean; or null.
       
    % Copyright (c) 2020-2022 MathWorks, Inc.
    
    properties(SetAccess = private)        
        Type
    end
    properties
        dataMap
    end
    
    properties(Hidden) % public, doc
        jSchemaObj
        jFieldsObj = '';
        jTypesObj = '';
    end
    
    methods
        
        function obj = Schema()
            %% Constructor.              
        end
        
        function set.jSchemaObj(obj,value)
            obj.jSchemaObj = value;
            obj.Type = matlabavro.SchemaType(char(value.getType())); %#ok<MCSUP>
        end
        
        function set.jFieldsObj(obj,value)
            obj.jFieldsObj = value;
        end
        
        
        function innerSchema = getElementType(obj)
            %% If schema is an array, returns its element type.
            
            % create valid schema object for return
            innerSchema = matlabavro.Schema();

            % if the obj Type is array, dig into the inner schema
            if(obj.Type == matlabavro.SchemaType.ARRAY)
                innerSchema.jSchemaObj = obj.jSchemaObj.getElementType();

            end
        end
        
        function name = getName(obj)
            %% If this is a record, enum or fixed, returns its name, otherwise the name of the primitive type.
            
            name = matlabavro.SchemaType(char(obj.jSchemaObj.getName()));
        end
        
        
        function fName = getFullName(obj)
            %% If schema is a record, enum or fixed, returns its namespace-qualified name, otherwise returns the name of the primitive type.
            
            fName = string(obj.jSchemaObj.getFullName());
        end
        
        
        function setFields(obj,fields)
            %% If schema is a record, sets the fields.
            
            validateattributes(fields,{'cell'},{});
            validateattributes(obj.Type,{'matlabavro.SchemaType'},{});
            if(~isequal(obj.Type,matlabavro.SchemaType.RECORD))
                warning('setFields is only supported for RECORD schema type');
                return;
            end
            import java.util.ArrayList;
            A = ArrayList;
            for n = 1:numel(fields)
                add(A,fields{n}.jFieldObj);
            end
            obj.jSchemaObj.setFields(A);
        end
        
        function str = toString(obj)
            %% Return the schema string.
            
            str = string(obj.jSchemaObj.toString());
        end
 
        function allTypes = getTypes(obj)
            %% Return all included types for Avro Union

            validateattributes(obj.Type,{'matlabavro.SchemaType'},{});
            if(~isequal(obj.Type,matlabavro.SchemaType.UNION))
                warning('matlabavro:Schema:getTypesInvalidSchemaType', ...
                    'getTypes is only supported for UNION schema type');
                return;
            end


            try
                % Get Types
                obj.jTypesObj = obj.jSchemaObj.getTypes();
                unionTypes = toArray(obj.jTypesObj);
                allTypes = cell(1,numel(unionTypes));
            
                % Create matlabavro schema for each type
                for n = 1:numel(unionTypes)
                    typeSchema = unionTypes(n);
                    schemaString = string(typeSchema.toString());
                    schemaObj = matlabavro.Schema.parse(schemaString);

                    allTypes{n} = schemaObj;
                end

            catch ME
                newException = MException(...
                    'matlabavro:Schema:getTypes', ...
                    "Unable to create matlabavro scheme objects for Avro Union types.");

                newException = newException.addCause(ME);
                throw(newException)
            end

        end

        function allFields = getFields(obj)
            %% If schema is a record, gets all fields.
            
            validateattributes(obj.Type,{'matlabavro.SchemaType'},{});
            if(~isequal(obj.Type,matlabavro.SchemaType.RECORD))
                warning('matlabavro:Schema:getFieldInvalidSchemaType', ...
                    'getFields is only supported for RECORD schema type');
                return;
            end


            try
                obj.jFieldsObj = obj.jSchemaObj.getFields();
                schemaFields = toArray(obj.jFieldsObj);
                allFields = cell(1,numel(schemaFields));

                for n = 1:numel(schemaFields)
                    name = schemaFields(n).name;
                    schema = matlabavro.Schema();
                    schema.jSchemaObj = schemaFields(n).schema;

                    aVal = schemaFields(n).defaultVal;

                    basicAvroTypes = ["BOOLEAN", "BYTES", "DOUBLE", "FLOAT", "INT", "LONG"];
                    thisType = string(schema.Type);

                    if ismember(thisType, basicAvroTypes)
                        % get avro type
                        schemaChar = char(schema.jSchemaObj.toString());
                        avroType = lower(jsondecode(schemaChar)); % R2017b jsondecode requires char input

                        matlabType = matlabavro.getMATLABType(avroType);

                        % cast value
                        aVal = cast(aVal, matlabType);
                    end

                    allFields{n} = matlabavro.Field(name, schema,schemaFields(n).doc, aVal);
                end

            catch ME
                newException = MException(...
                    'matlabavro:Schema:getFields', ...
                    "Unable to create matlabavro field objects for Avro record fields.");

                newException = newException.addCause(ME);
                throw(newException)
            end

        end

    end
    
    methods (Static)

        function obj = parse(varargin)
            %% Create Schema object by passing in JSON string.
            % Parse a schema from the provided string.
            % Parse a schema from a set of JSON strings.
            
            jSchemaParser = javaObject('org.apache.avro.Schema$Parser');
            obj = matlabavro.Schema();
            try
                obj.jSchemaObj = jSchemaParser.parse(varargin{1:end});
            catch ME                
                newException = MException('matlabavro:Schema:Parse', ...
                    "Unable to parse JSON string: " + string(varargin{1:end}) + ".");

                newException = newException.addCause(ME);
                throw(newException)
          
            end
        end
        
        
        function obj = create(sType)
            %% Create a schema for primitive data types.
            % Schema Types allowed: int string boolean null double bytes
            % long float.
                        
            validateattributes(sType,{'matlabavro.SchemaType'},{})
            avroSchemaType = javaMethod('valueOf', 'org.apache.avro.Schema$Type', char(sType));
            obj = matlabavro.Schema();
            obj.jSchemaObj  = javaMethod('create','org.apache.avro.Schema',avroSchemaType);
        end
        
         function obj = createEnum(enumName)
            %% Create a schema for Enums.
            % name  - Enum name to store in avro data.
            % doc - doc text.
            % enumName - name of the ennumeration.
            
            validateattributes(enumName,{'char'},{})
            vals = string(enumeration(enumName));
            tmpO.type = 'enum';
            tmpO.name = enumName;
            tmpO.symbols = vals;            
            schemaStr = jsonencode(tmpO);
            obj = matlabavro.Schema.parse(schemaStr);            
         end
        
        function obj = createArray(elementType)
            %% Create a schema for arrays.
            % elementType - SchemaType for elements in array.
            
            validateattributes(elementType,{'matlabavro.SchemaType'},{})
            schema = matlabavro.Schema.create(elementType);
            obj = matlabavro.Schema();
            obj.jSchemaObj = javaMethod('createArray','org.apache.avro.Schema',schema.jSchemaObj);
        end
        
        
        function obj = createMap(valueType)
            %% Create a schema for maps.
            % valueType - type of elements to map to.
            
            validateattributes(valueType,{'matlabavro.SchemaType'},{})
            schema = matlabavro.Schema.create(valueType);
            obj = matlabavro.Schema();
            obj.jSchemaObj = javaMethod('createMap','org.apache.avro.Schema',schema.jSchemaObj);
        end
        
        
        function obj = createFixed(name,doc,space,size)
            %% Create a schema for Fixed type.
            % name  - Schema type of elements to map to.
            % doc - doc text.
            
            validateattributes(name,{'char','string','java.lang.String'},{})
            validateattributes(doc,{'char','string','java.lang.String'},{})
            validateattributes(space,{'char','string','java.lang.String'},{})
            validateattributes(size,{'int','double'},{})
            obj = matlabavro.Schema();
            obj.jSchemaObj = javaMethod('createFixed','org.apache.avro.Schema',name,doc,space,size);
        end
        
        
        function obj = createRecord(name,doc, namespace, isError)
            %% Create a Record type.
            % valueType - Schema type of elements to map to.
            
            validateattributes(name,{'char','string','java.lang.String'},{})
            validateattributes(doc,{'char','string','java.lang.String'},{})
            validateattributes(namespace,{'char','string','java.lang.String'},{})
            validateattributes(isError,{'logical'},{})
            obj = matlabavro.Schema();
            obj.jSchemaObj = javaMethod('createRecord','org.apache.avro.Schema',name,doc, namespace, isError);
        end
        
        
        function obj = createUnion(schemas)
            %% Create a union type.
            % schemas - cell array of matlabavro.schemas.
            
            validateattributes(schemas,{'cell'},{});
            if(~all(cellfun(@(x) isa(x,'matlabavro.Schema'),schemas,'UniformOutput',true)))
                error('All elements in input argument schemas must be of type matlabvro.Schema.');
            end
            obj = matlabavro.Schema();
            import java.util.ArrayList;
            A = ArrayList;
            for n=1:numel(schemas)
                add(A,schemas{n}.jSchemaObj);
            end
            obj.jSchemaObj = javaMethod('createUnion','org.apache.avro.Schema',A);
        end
        
        function obj = createSchemaForData(data) 
            tmpMap = containers.Map();
            [schemaStructure,tmpMap] = matlabavro.getSchemaStructure(data,tmpMap);
            
            %JSON encode and cleanup
            schemaString = jsonencode(schemaStructure);
            schemaString = strrep(strrep(schemaString,'[[','['),']]',']');
            obj = matlabavro.Schema();
            obj = obj.parse(schemaString);
            obj.dataMap = tmpMap;
        end
        
    end    
end
