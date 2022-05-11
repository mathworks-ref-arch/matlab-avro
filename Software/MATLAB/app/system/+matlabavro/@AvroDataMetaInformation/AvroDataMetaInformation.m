classdef AvroDataMetaInformation < handle

    % Copyright (c) 2022 MathWorks, Inc.


    properties
        rows = 0 %(1,1) double {mustBeReal, mustBeNonnegative} = 0
        cols = 0 %(1,1) double {mustBeReal, mustBeNonnegative} = 0

        isCell = 0 %(1,1) logical {mustBeNumericOrLogical} = false
        isTable = 0 %(1,1) logical {mustBeNumericOrLogical} = false
        isObject = 0 %(1,1) logical {mustBeNumericOrLogical} = false

        schema = matlabavro.Schema.create(matlabavro.SchemaType.DOUBLE);
    end

    methods
        function obj = AvroDataMetaInformation(varargin)
            % AvroDataMetaInformation Constructor
            % 
            % Syntax:
            %   legacyMetaData = AvroDataMetaInformation()
            %   legacyMetaData = AvroDataMetaInformation(aSchema)
            %   legacyMetaData = AvroDataMetaInformation(data)
            %
            % Description:
            %    legacyMetaData = AvroDataMetaInformation() constructs a
            %    default AvroDataMetaInformation object with an empty
            %    schema. Legacy metadata attributes such as isCell or
            %    isTable can be set or queried.
            %
            %    legacyMetaData = AvroDataMetaInformation(aSchema)
            %    constructs an AvroDataMetaInformation object with the
            %    provided schema. Schema is used to set basic geometry and
            %    available class information. Legacy metadata attributes
            %    such as isCell or isTable can be set or queried.
            %
            %    legacyMetaData = AvroDataMetaInformation(data) constructs
            %    an AvroDataMetaInformation object and will generate the
            %    correspondign schema for data. Legacy metadata attributes
            %    such as isCell or isTable can be set or queried.
            %

            % invoke superclass/handle constructor
            obj = obj@handle();

            if nargin > 0
                if isa(varargin{1}, 'org.apache.avro.Schema')
                    try
                        jSchemaObj = varargin{1};

                        schemaString = string(jSchemaObj.toString());
                        obj.schema = matlabavro.Schema.parse(schemaString);

                        obj.isCell = obj.schema.Type == matlabavro.SchemaType.UNION;

                    catch ME
                        newException = MException('matlabavro:AvroDataMetaInformation', ...
                            "Error constructiong AvroMetaDataInformation object from java schema object.");

                        newException = newException.addCause(ME);
                        throw(newException)
                    end

                elseif isa(varargin{1}, 'matlabavro.Schema')
                    mSchemaObj = varargin{1};
                    obj.schema = mSchemaObj;

                    % Union type indicates a cell array
                    obj.isCell = mSchemaObj.Type == matlabavro.SchemaType.UNION;

                else 
                    data = varargin{1};
                    obj.schema = matlabavro.Schema.createSchemaForData(data);

                    % Query data to set metadata predicates
                    obj.isCell = iscell(data);
                    obj.isTable = matlabavro.AvroDataMetaInformation.isTabular(data);
                    obj.isObject = isobject(data);

                    % Set size
                    [obj.rows, obj.cols] = size(data);
                end
                
            end

        end

        function set.isCell(obj, value)
            %% Sets isCell value
            %   value - logical
            validateattributes(value,{'logical', 'numeric'},{'scalar'});
            obj.isCell = value;
        end

        function set.isTable(obj, value)
            %% Sets isTable value
            %   value - logical
            validateattributes(value,{'logical', 'numeric'},{'scalar'});
            obj.isTable = value;
        end

        function set.isObject(obj, value)
            %% Sets isObject value
            %   value - logical
            validateattributes(value,{'logical', 'numeric'},{'scalar'});
            obj.isObject = value;
        end

        function set.rows(obj, value)
            %% Sets rows value
            %   value - logical
            validateattributes(value,{'numeric'},{'scalar', 'real', 'nonnegative'});
            obj.rows = value;
        end

        function set.cols(obj, value)
            %% Sets cols value
            %   value - logical
            validateattributes(value,{'numeric'},{'scalar', 'real', 'nonnegative'});
            obj.cols = value;
        end

    end

    methods (Static, Access = protected)
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
    end
end