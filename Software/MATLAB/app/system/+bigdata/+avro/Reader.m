classdef Reader < bigdata.avro.util.Core
    % Class for reading Avro files
    %
    % Example: Read Avro file
    %
    %   import bigdata.avro.Reader
    %
    %   p = Reader('FileName','tmp.avro')
    %
    %   data = p.read;
    %
    % See also bigdata.avro.Reader/read, bigdata.avro.Writer

    % Copyright (c) 2017, The MathWorks, Inc.

    properties
        % FileName to read
        FileName char

        % Seek position if < 0 then seeking is ignored
        SeekPosition (1,1) double {mustBeInteger} = -1;

        % Number of records to read
        NumRecords (1,1) double {mustBePositive} = inf;

        % The file encoding
        FileEncoding bigdata.avro.enum.FileEncoding = ...
            bigdata.avro.enum.FileEncoding.BINARY;
    end

    properties(SetObservable)
        % This sets whether to use sync or seek to seek through file
        % If sync wasn't used when writing file should be true

        UseSyncToSeek (1,1) logical = true;
    end

    properties(SetAccess = private, Hidden)
        % An instance of the Reader
        JavaHnd

        % The returned field names
        FieldNames
    end

    methods
        function obj = Reader(varargin)
            % Constructor for Avro Reader
            %
            % Inputs accept property/value pairs
            %
            % Example: Pass in the FileName
            %
            %   import bigdata.avro.Reader;
            %   p = Reader('FileName','tmp.avro')
            %
            % READER

            obj.JavaHnd = com.mathworks.bigdata.avro.Reader;
            obj.construct(varargin{:})
        end

        function data = read(obj,varargin)
            % Read the Avro file into a table
            %
            % Inputs accept property/value pairs
            %
            % READ

            obj.parseInputs(varargin{:})

            % Check if file exists
            if isempty(dir(obj.FileName))
                error(['bigdata.avro.Reader:read:FileNotFound ',obj.FileName])
            end

            if obj.FileEncoding == "JSON"
                data = obj.readJsonEncodedFile;
                return
            end

            % Read the Avro file
            data = cell(obj.JavaHnd.read(obj.FileName, obj.SeekPosition, ...
                obj.NumRecords));
            fieldNames = cellstr(string(obj.JavaHnd.getVariableNames));

            % This returns the number of array elements per record for a field
            arrayCount = cell(obj.JavaHnd.getArrayCount);

            % Get any extra metadata for Formating datetime/durations
            [matlabSchema,avroFields,matlabFields] = obj.getMetaData;

            % Convert data to MATLAB types if required
            for j = 1 : length(fieldNames)
                if isfield(avroFields{j},'logicalType')
                    % If Avro logical exists convert to correct datatype
                    data{j} = obj.convertToMatlab(data{j},...
                        avroFields{j}.logicalType, matlabFields{j});
                elseif ~ isempty(matlabFields) ...
                        && strcmp(matlabFields{j}.type,'string') || strcmp(matlabFields{j}.type,'char') ...
                        && ~ isstring(data{j})
                    % Check if a char array was written but original data in
                    % MATLAB was a string because of performance reason in <=2018b
                    data{j} = string(data{j});
                end
            end

            % Reshape the data if its an array
            for j = 1 : length(arrayCount)
                if ~ isempty(arrayCount{j})
                    endInd = cumsum(arrayCount{j});
                    startInd = endInd - arrayCount{j} + 1;
                    dj = data{j};
                    djc = cell(length(endInd), 1);
                    for k = 1 : length(endInd)
                        djc{k} = dj(startInd(k) : endInd(k));
                    end
                    data{j} = djc;
                end
            end

            % The underlying matlab data type, defaults to 'table'
            ind = 1 : length(fieldNames);
            matlabType = 'table';
            if ~ isempty(matlabSchema)
                matlabType = matlabSchema.type;
            end


            % The underlying data type if Avro file was written by MATLAB
            switch matlabType
                case 'timetable'
                    % First column is the RowTimes
                    ind  = setdiff(ind, 1);
                    data = timetable(data{1}, data{ind},...
                        'VariableNames', fieldNames(ind));
                    data.Properties.DimensionNames{1} = fieldNames{1};
                case 'table'
                    data = table(data{ind}, 'VariableNames', fieldNames);
                case 'table-rownames'
                    ind = 2 : length(ind);
                    data = table(data{ind}, ...
                        'VariableNames', fieldNames(ind),...
                        'RowNames',cellstr(data{1}));
                case 'struct'
                    data = cell2struct(data(ind), fieldNames);
                case 'char'
                    data = char(join([data{:}],""));
                case 'cell'
                    data = data(ind);
                    if any(size(data) ~= matlabSchema.size)
                        % reshape to original size
                        dataNew = [];
                        for j = 1 : numel(data)
                            if iscellstr(data{j})
                                dataNew = [dataNew, data{j}]; %#ok<*AGROW>
                            else
                                dataNew = [dataNew, num2cell(data{j})];
                            end
                        end
                        data = dataNew;
                    end
                otherwise
                    if matlabSchema.isObject
                        if exist(matlabSchema.type,'class')
                            % Create an instance of our object
                            myClass = repmat(feval(matlabSchema.type),...
                                matlabSchema.size);
                        end
                        for j = 1 : length(fieldNames)
                            d = [data{j}];
                            if ~ iscell(d)
                                d = num2cell(d);
                            end
                            [myClass.(fieldNames{j})] = deal(d{:});
                        end
                        data = myClass;
                    else
                        % Array
                        data = [data{ind}];
                    end
            end
        end

        function out = getSchema(obj,file)
            % Get the Avro schema

            File = obj.FileName;
            if nargin == 2
                File = file;
            end
            out = string(obj.JavaHnd.getSchema(File));
        end

        function out = pastSync(obj, pos)
            % Return true if past the next sync point after pos

            out = obj.JavaHnd.getDataFileReader.pastSync(pos);
        end

        function out = previousSync(obj)
            % Return the last sync point before our current position

            out = obj.JavaHnd.getDataFileReader.previousSync;
        end

        function seek(obj, pos)
            % Move to a specific, known sync point
            %
            % If the Avro file was written with sync markers use this
            % with the property UseSyncToSeek = false

            obj.JavaHnd.getDataFileReader.seek(pos);
        end

        function sync(obj, pos)
            % Move to the next sync point after a position
            %
            % Use with UseSyncToSeek = true

            obj.JavaHnd.getDataFileReader.sync(pos);
        end

        function out = tell(obj)
            % Return the current position in the input

            out = obj.JavaHnd.getDataFileReader.tell;
        end

    end

    methods(Access = private)
        function [matlabSchema,avroFields,matlabFields,avroSchema] = getMetaData(obj)
            % Return metadata that has been saved in the Avro file

            % Get any extra metadata for Formating datetime/durations
            % TODO get rid of passing filename
            metaData = obj.JavaHnd.getMeta(obj.FileName);
            matlabSchema = [];
            matlabFields = [];
            if metaData.containsKey('matlab.schema')
                matlabSchema = jsondecode(metaData.get('matlab.schema'));
                if isstruct(matlabSchema.fields)
                    matlabFields = cell(1,numel(matlabSchema.fields));
                    for j = 1 : numel(matlabSchema.fields)
                        matlabFields{j} = matlabSchema.fields(j);
                    end
                else
                    matlabFields = matlabSchema.fields;
                end
                % jsondecode has size returned as a column, flip it
                matlabSchema.size = matlabSchema.size';
            end

            avroSchema = jsondecode(metaData.get('avro.schema'));
            if isstruct(avroSchema.fields)
                avroFields = cell(1,numel(avroSchema.fields));
                for j = 1 : numel(avroSchema.fields)
                    avroFields{j} = avroSchema.fields(j);
                end
            else
                avroFields = avroSchema.fields;
            end
        end

        function t = readJsonEncodedFile(obj)
            % Read the JSON encoded file

            fid = fopen(obj.FileName);
            t = textscan(fid,'%s');
            fclose(fid);
            t = string([t{:}]);

            % Replace the last character with a comma to make properly
            % formatted JSON string that works with jsondecode. This is the
            % record separator.
            %
            % Skip first line as its the schema
            c = t{2}(end); % double(c) == 13 in our files
            t = regexprep(t(2:end),c,',');
            t = [t{:}];

            % Enclose with missing []
            t = "[" + t + "]";
            t = struct2table(jsondecode(t));
        end

        function setFileEncoding(obj)
            % Return true if file is binary encoded, otherwise false
            %
            % If false it may be JSON encoded

            % Open the file first line will do
            fid = fopen(obj.FileName);
            t = textscan(fid,'%s',1);
            fclose(fid);
            t = string(t{:});

            % Compare the first four magic bytes
            v = strcmp("Obj" + char(1), t{1}(1 : 4));
            if v
                obj.FileEncoding = 'BINARY';
            else
                % check to see if there is a '{' this might be a
                % JSON file
                if strcmp("{", t{1}(1))
                    obj.FileEncoding = 'JSON';
                end
            end
        end

    end

    methods(Static, Access = private)
        function v = convertToMatlab(v,avroLogical, metaData)
            % Convert to the correct MATLAB type from Avro
            %
            % DATA        - The returned MATLAB datatype
            % FIELDNAME   - The field name

            import bigdata.avro.enum.Types;

            switch avroLogical
                case Types.DATE.Logical
                    v = datetime(v * 86400,'ConvertFrom','posixtime',...
                        'Format','defaultdate');
                case Types.DURATION_MILLIS.Logical
                    v = duration(0,0,0,v);
                case Types.DURATION_MICROS.Logical
                    v = duration(0,0,0,v / 1e7);
                case {Types.DATETIME_MILLIS.Logical,...
                        Types.DATETIME_MICROS.Logical}
                    v = datetime(double(v) / 1e7,'ConvertFrom','posixtime');
            end

            % Apply same format to datetime/duration as original data
            if ~isempty(metaData) && isfield(metaData,'format')
                v.Format = metaData.format;
            end
        end
    end
end
