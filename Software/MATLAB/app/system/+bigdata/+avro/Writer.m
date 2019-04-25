classdef Writer < bigdata.avro.util.Core
    % Class for writing Avro files
    %
    %
    % See also bigdata.avro.Writer/write, bigdata.avro.Reader

    % Copyright (c) 2017, The MathWorks, Inc.

    properties
        % FileName to write
        FileName char

        % The Avro file schema, this can be a string/char or MessageType
        Schema {bigdata.avro.Writer.mustBeString} = '';

        % The compression codec to use
        Compression bigdata.avro.enum.Compression = ...
            bigdata.avro.enum.Compression.SNAPPY;

        % The compression level between 1 and 9
        CompressionLevel (1,1) double {mustBeInteger,mustBePositive,...
            mustBeLessThanOrEqual(CompressionLevel,9)} = 5;
    end

    properties(SetObservable, AbortSet)
        % Set this to true to append to existing file
        AppendToFile bigdata.avro.enum.Boolean = false;

        % Add a sync marker
        AddSyncMarker bigdata.avro.enum.Boolean = false;
    end

    properties(SetAccess = private, Hidden)
        % An instance of the Writer
        JavaHnd

        % File metadata
        MetaData (1,1) struct
    end

    properties
        % If set to true will try to auto-generate schema from data
        AutoGenerateSchema bigdata.avro.enum.Boolean = true;

        % The data to write
        Data
    end

    methods
        function obj = Writer(varargin)
            % Constructor for Avro Writer
            %
            % Inputs accept property/value pairs
            %
            % Example: Create a writer that will write to 'temp.avro'
            %
            %   writer = bigdata.avro.Writer('FileName','tmp.avro')

            obj.JavaHnd = com.mathworks.bigdata.avro.Writer;
            obj.construct(varargin{:})
        end

        function write(obj,data,varargin)
            % Write data to Avro file
            %
            % WRITE(DATA, Property, Value,...) Write the DATA to file, this
            % can be followed by additional Property/Value pairs.
            %
            %   Example: Write a table to a Avro file
            %
            %       % Initialize the Writer
            %       import bigdata.avro.*;
            %       writer = Writer('FileName','tmp.avro');
            %
            %       % Create table of values
            %       rows = 100;
            %       cols = 2;
            %       maxi = 65536;
            %       data = array2table([(1 : rows)', randi(maxi,rows,cols)]);
            %
            %       % Add some RowNames, we will write these too.
            %       data.Properties.RowNames = cellstr("Row"+(1:100))';
            %       writer.write(data)
            %
            % WRITE

            % Parse any property/value pairs
            obj.parseInputs(varargin{:})

            % Assign data to Data property
            if nargin > 1 && ~ isempty(data)
                obj.Data = data;
            end

            % Generate schema
            if obj.AutoGenerateSchema
                [obj.Schema, type] = obj.generateSchemaString;
            end

            % Add the metadata
            obj.addMetaData();

            % Convert data
            [data, ~, fields] = obj.convertData(type);

            % Set any extra meta data to be written to Avro file
            obj.setExtraMetaData

            % Detect if contains arrays
            containsArrays = false;
            for n = 1:length( data )
                if iscell( data{n} ) && ~isempty( data{n} )
                    example = data{n}{1};
                    if isa( example, 'double' ) && numel( example ) > 1
                        containsArrays = true;
                    end
                end
            end
            
            % Write the Avro file             
            if containsArrays
                obj.writeAvroFile(obj.FileName, fields, data, obj.Schema,...
                    obj.Compression.string, obj.CompressionLevel)
            else
                obj.JavaHnd.write(obj.FileName, fields, data, obj.Schema,...
                    obj.Compression.string, obj.CompressionLevel)                
            end
            
        end

        function writeAvroFile(obj, filename, keys, data, schemaString, compressionCodec, compressionLevel)
        
            schemaString = replace( schemaString, '"type":"double"', ...
                '"type":{"type":"array","items":"double"}' );
            avroSchema = javaMethod( 'parse', 'org.apache.avro.Schema', schemaString );
            
            % Create the writer to serialize the file
            genericWriter = org.apache.avro.generic.GenericDatumWriter();
            genericWriter.setSchema(avroSchema);
            
            dfw = org.apache.avro.file.DataFileWriter(genericWriter);
            
            % set compression codec
            obj.JavaHnd.addCompression(dfw, compressionCodec, compressionLevel);
            
            % obtain the filesystem file
            if startsWith(filename, "hdfs://")
                file = obj.JavaHnd.getHDFSfile(filename);
%                 conf = org.apache.hadoop.conf.Configuration;
%                 conf.set("fs.hdfs.impl", "org.apache.hadoop.hdfs.DistributedFileSystem");
%                 fs = org.apache.hadoop.fs.FileSystem.get( ...
%                     java.net.URI.create(filename), conf );
%                 file = fs.create(org.apache.hadoop.fs.Path(filename));
            else
                file = java.io.File( filename );
            end

            if obj.AppendToFile
                dfw.appendTo( file );
            else
                dfw.create( avroSchema, file );
            end
            
            rows = length( data{1} );
            for n = 1:rows
                % Use the schema parser to create a generic record
                genericRecord = javaObject('org.apache.avro.generic.GenericData$Record',avroSchema);
                for p = 1:length( data )
                    v = data{p}(n);
                    if isscalar( v ) && isa( v, 'double' )
                        v = { v }; % Box
                    end
                    if iscell( v )
                        stream = javaMethod('of', 'java.util.stream.DoubleStream', v{1}(:) );
                        boxed = stream.boxed();
                        list = boxed.collect(java.util.stream.Collectors.toList());
                        genericRecord.put(keys{p},list);
                    else
                        genericRecord.put(keys{p},v);
                    end
                end
                % Append the record to the file
                dfw.append(genericRecord);
                dfw.flush(); % emits a sync marker and flushes the current state.
            end
            
            dfw.close();
        end                
        
        function finish(obj)
            % Finish appending data
            %
            % FINISH

            obj.JavaHnd.finish
        end

        function delete(obj)
            % Release Java objects
            %
            % DELETE

            obj.JavaHnd = [];
        end

        function [schema, type] = generateSchemaString(obj)
            % Generate a Avro schema string from underlying data
            %
            % GENERATESCHEMASTRING

            [type, fields] = obj.getColumnAvroType;

            % Define the output file
            schema.namespace = '';
            schema.type = 'record';
            schema.name = 'record_name';
            schema.fields = [];

            % Loop through properties and add the appropriate structure
            for pCount = 1 : numel(fields)
                fieldStruct = struct('name',[],'type','');
                fieldStruct.name = fields{pCount};
                fieldStruct.type = type(fields{pCount}).Native;
                logicalType = type(fields{pCount}).Logical;
                if ~ isempty(logicalType)
                    fieldStruct.logicalType = logicalType;
                end
                schema.fields = [schema.fields,{fieldStruct}];
            end

            % Encode the schema
            schema = jsonencode(schema);

        end

        function [out, fields] = getColumnAvroType(obj)
            % Get the column type used for Avro auto-generated schema
            %
            % Returns a containers.Map object K=COLUMN_NAME, V=TYPE
            % where TYPE is a struct with fields indicating 'Native' and
            % 'Logical' type values used in schema generation, as well as
            % the 'MATLAB' field for the underlying MATLAB type.
            %
            % NOTE: The fields are returned in their original order. If extracted
            % from the Map using the keys value then the
            % fields will be alphabetically sorted. This will change the
            % order in which fields are written.
            %
            % GETCOLUMNAVROTYPE

            import bigdata.avro.enum.Types
            [~, clmn, fields] = obj.getSizeAndFields;

            out  = containers.Map;
            data = obj.Data;
            for j = 1 : clmn
                if isa(data,'table') || isa(data,'timetable')
                    if isa(data,'timetable') && j == 1
                        c = obj.getMatlabType(data.Properties.RowTimes);
                    elseif isa(data,'table') && j == 1 && ...
                            ~ isempty(data.Properties.RowNames)
                        c = obj.getMatlabType(data.Properties.RowNames);
                    else
                        c = obj.getMatlabType(data.(fields{j}));
                    end
                elseif isnumeric(data) || isstring(data) || ischar(data) || islogical(data)
                    c = obj.getMatlabType(data(:,j));
                elseif isstruct(data)
                    c = obj.getMatlabType(data.(fields{j}));
                elseif iscell(data)
                    c = obj.getMatlabType(data{j});
                elseif isobject(data) % custom class
                    c = obj.getMatlabType(data(1).(fields{j}));
                end
                out(fields{j}) = struct('Native',Types.(c).Native,...
                    'Logical',Types.(c).Logical,'MATLAB',c);
            end
        end

        function [rows,clmn,fields] = getSizeAndFields(obj)
            % Get the data size and fields
            %
            % Third output argument is fields for structs
            %
            % GETSIZEANDFIELDS

            data = obj.Data;
            if isa(data,'timetable')
                fields = [data.Properties.DimensionNames(1),...
                    data.Properties.VariableNames];
                clmn = length(fields);
                rows = height(data);
            elseif isa(data,'table')
                fields = data.Properties.VariableNames;
                if ~ isempty(data.Properties.RowNames)
                    fields = [data.Properties.DimensionNames(1), fields];
                end
                clmn = length(fields);
                rows = height(data);
            elseif isnumeric(data) || isstring(data) || ischar(data) || islogical(data)
                [rows, clmn] = size(data);
                fields = "Field_" + (1 : clmn);
            elseif isstruct(data)
                fields = fieldnames(data);
                clmn   = length(fields);
                rows   = numel(data.(fields{1}));
            elseif iscell(data)
                [rows, clmn] = size(data);
                if rows == 1
                    % check for an array in the cell
                    rows = numel(data{:,1});
                end
                fields = "Field_" + (1 : clmn);
            elseif isobject(data) % custom class
                rows   = numel(data);
                fields = properties(data(1));
                clmn   = numel(fields);
            end
        end

        function [val, rows, fields] = convertData(obj,type,varargin)
            % Converts the data for the Avro writer
            %
            % VAL    - Cell array, one per column of data
            % ROWS   - Number of rows in the data
            % FIELDS - The name of the fields as a cellstr
            %
            % CONVERTDATA

            data = obj.Data;
            [rows,clmn,fields] = obj.getSizeAndFields;
            val = cell(1, clmn);

            for j = 1 : clmn
                f = fields{j};
                t = type(f);
                if istable(data) || istimetable(data)
                    if istimetable(data) && j == 1
                        val{j} = obj.convertColumn(...
                            data.Properties.RowTimes,t,f);
                    elseif istable(data) && j == 1 && ...
                            ~ isempty(data.Properties.RowNames)
                        val{j} = obj.convertColumn(...
                            string(data.Properties.RowNames),t,f);
                    else
                        val{j} = obj.convertColumn(data.(f),t,f);
                    end
                elseif isnumeric(data) || isstring(data) || ischar(data) || islogical(data)
                    val{j} = obj.convertColumn(data(:,j),t,f);
                elseif isstruct(data)
                    val{j} = obj.convertColumn(data.(f),t,f);
                elseif iscell(data)
                    val{j} = obj.convertColumn([data{:,j}],t,f);
                elseif isobject(data) % custom class
                    val{j} = obj.classToCell(f);
                end
            end
        end
    end

    methods(Access = private)
        function [data, md] = convertColumn(obj, data, type, field)
            % Convert this MATLAB column to correct type for Avro Writer
            %
            % DATA - The converted data ready to be written to Avro
            % MD   - Additional metadata key-value pair about the datatype
            %        as a cellarray {'key','value'}
            %
            % CONVERTCOLUMN

            md = struct('name',field,'type',class(data));
            switch type.MATLAB
                case 'CHAR'
                    if verLessThan('matlab','9.5')
                        % On releases prior to 2018b cellstr is more
                        % efficient when there is more than a million or so
                        % rows
                        data = cellstr(data);
                    else
                        data = string(data);
                    end
                case 'STRING'
                    if verLessThan('matlab','9.5')
                        % On releases prior to 2018b cellstr is more
                        % efficient when there is more than a million or so
                        % rows
                        data = cellstr(data);
                    end
                case 'DATE'
                    md.format = data.Format;
                    data = int32(posixtime(data) / 86400);
                case 'DURATION_MILLIS'
                    md.format = data.Format;
                    data = int32(milliseconds(data));
                case 'DURATION_MICROS'
                    md.format = data.Format;
                    data = int64(milliseconds(data) * 1e7);
                case {'DATETIME_MILLIS','DATETIME_MICROS'}
                    md.format = data.Format;
                    data = int64(posixtime(data) * 1e7);
            end
            obj.addMetaData(md);
        end

        function addMetaData(obj,md)
            % Add MATLAB specific metadata used for reading file
            %
            % ADDMETADATA

            if nargin == 1 || isempty(md)
                if istable(obj.Data) && ~ isempty(obj.Data.Properties.RowNames)
                    obj.MetaData = struct('type','table-rownames');
                else
                    obj.MetaData = struct('type',class(obj.Data));
                end

                if isstring(obj.Data) || istable(obj.Data) ||...
                        istimetable(obj.Data)
                    obj.MetaData.isObject = false;
                else
                    % numeric, logical, char, cell, struct return false
                    obj.MetaData.isObject = isobject(obj.Data);
                end
                obj.MetaData.size = size(obj.Data);
                obj.MetaData.fields = [];
            else
                obj.MetaData.fields = [obj.MetaData.fields, {md}];
            end
        end

        function s = classToCell(obj,f)
            % Convert custom class to cell array
            %
            % CLASSTOCELL

            md = struct('name',f,'type',class(obj.Data(1).(f)));
            s = {};
            [s{1 : length(obj.Data)}] = deal(obj.Data.(f));
            if iscellstr(s)
                s = string(s);
            else
                s = [s{:}];
            end
            obj.addMetaData(md);
        end

        function setExtraMetaData(obj)
            % Set the extra metadata for the Avro file
            %
            % SETEXTRAMETADATA

            if ~ isempty(obj.MetaData)
                obj.JavaHnd.setMetaKeys({'matlab.schema'})
                obj.JavaHnd.setMetaValue({jsonencode(obj.MetaData)});
            end
        end
    end

    methods(Static)
        function out = getMatlabType(data)
            % Get the MATLAB data type
            %
            % For most cases the values returned by class(data)is used.
            % Data types such as datetime or duration will be
            % converted to one of the types as defined in
            % bigdata.avro.enum.Types
            %
            % See the bigdata.avro.enum.Types for how values returned by
            % this method, GETMATLABTYPE, are written to Avro.
            %
            % Only called by GETCOLUMNTYPE
            %
            % GETMATLABTYPE

            import bigdata.avro.enum.Types

            if isa(data,'datetime')
                if isempty(regexp(data.Format,'[hHmsS]','once'))
                    % No hours/minutes or seconds so can use int32
                    out = Types.DATE.char;
                elseif contains(data.Format,{'SSSSSS','SSSSS','SSSS'})
                    out = Types.DATETIME_MICROS.char;
                else
                    out = Types.DATETIME_MILLIS.char;
                end
            elseif isa(data,'duration')
                if contains(data.Format,{'SSSSSS','SSSSS','SSSS'})
                    out = Types.DURATION_MICROS.char;
                else
                    out = Types.DURATION_MILLIS.char;
                end
            elseif iscellstr(data) %#ok<ISCLSTR>
                out = Types.STRING.char;
             elseif iscell(data)
                 out = upper(class(data{1}));
            else
                out = upper(class(data));
            end
        end

        function out = isValidData(data)
            % Is the data of a valid type to write

            if istable(data) ...
                    || istimetable(data) ...
                    || isnumeric(data) ...
                    || isstring(data) ...
                    || isstruct(data) ...
                    || iscell(data) ...
                    || islogical(data) ...
                    || isobject(data) % custom class
                out = true;
            else
                out = false;
            end
        end
    end

    methods(Static, Access = private)
        function mustBeString(schema)
            % Property validation function for Schema
            %
            % MUSTBESTRING

            if ~ (ischar(schema) || isstring(schema))
                error('Needs to be a char or string')
            end
        end
    end
end
