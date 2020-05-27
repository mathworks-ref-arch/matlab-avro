classdef Field < handle
    %% FIELD - A field within a record
             
    % (c) 2020 MathWorks, Inc.
    properties
        name
        schema
    end
    properties(Hidden)
        jFieldObj
    end
    methods
        %% Constructor        
        function obj = Field(name,schema,doc,val)
            % Constructs a new Field instance with the same name, doc, defaultValue, and order as field has with changing the schema to the specified one.
            fObject = javaObject('org.apache.avro.Schema$Field', name, schema.jSchemaObj,doc,val);
            obj.jFieldObj = fObject;
        end
        
        % Returns the name of the field
        function name = get.name(obj)
            name = string(obj.jFieldObj.name());
        end
        
        % This field's Schema.
        function schema = get.schema(obj)
            schema = matlabavro.Schema();
            schema.jSchemaObj = obj.jFieldObj.schema();
        end
    end
    
end %class