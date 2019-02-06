classdef Types
    % Enumeration between MATLAB and Avro types
    
    % Copyright (c) 2017, The MathWorks, Inc.
    
    properties
        % Avro native type
        Native
        
        % Avro logical type
        Logical
    end
    
    methods
        function obj = Types(a,b)
            obj.Native  = lower(a);
            obj.Logical = lower(b);
        end
        
        function [data, md] = convertData(obj, data)
            % Convert this MATLAB column to correct type for Avro Writer
            %
            % DATA - The converted data ready to be written to Avro
            % MD   - Additional metadata key-value pair about the datatype
            %        as a cellarray {'key','value'}
            %
            % Example:
            
            import bigdata.avro.enum.Types;
            
            md = struct('type', class(data), 'size', size(data));
            
            if isa(data, 'cell') && ~ (iscellstr(data) || ...
                    ( isstring(data{1}) && n == numel([data{:}])))
                % Pre-allocate the size array
                % This hold the size of the original data for the cell
                % elemenet.
                
                dims = size(numel(data),1);
                % Loop through each cell and see what the dimesnions are
                for j = 1 : numel(data)
                    dims(j) = ndims(data{j});
                end
                sameDims = max(dims) == min(dims);
                % The size is pre-allocated with ones, this ensures
                % dimensions less than max(dims) have a singleton
                md.size = ones(numel(data), max(dims), 'uint8');
            end
            
            switch obj
                case Types.CHAR
                    if verLessThan('matlab','9.5')
                        % On releases prior to 2018b cellstr is more
                        % efficient when there is more than a million or so
                        % rows
                        data = cellstr(data);
                    else
                        data = string(data);
                    end
                case Types.STRING
                    if verLessThan('matlab','9.5')
                        % On releases prior to 2018b cellstr is more
                        % efficient when there is more than a million or so
                        % rows
                        data = cellstr(data);
                    end
                case Types.DATE
                    if isa(data, 'cell')
                        % Unroll array
                        % Assumes first value contains a format
                        md.format = data{1}(1).Format;
                        for j = 1 : numel(data)
                            if sameDims
                                md.size(j, :) = size(data{j});
                            else
                                s = size(data{j});
                                md.size(j,1 : numel(s)) = s;
                            end
                            data{j} = int32(posixtime(data{j}(:)) / 86400);
                        end
                    else
                        md.format = data.Format;
                        data = int32(posixtime(data) / 86400);
                    end
                case Types.DURATION_MILLIS
                    if isa(data, 'cell')
                        % Unroll array
                        % Assumes first value contains a format
                        md.format = data{1}(1).Format;
                        for j = 1 : numel(data)
                            if sameDims
                                md.size(j, :) = size(data{j});
                            else
                                s = size(data{j});
                                md.size(j,1 : numel(s)) = s;
                            end
                            data{j} = int32(milliseconds(data{j}(:)));
                        end
                    else
                        md.format = data.Format;
                        data = int32(milliseconds(data));
                    end
                case Types.DURATION_MICROS
                    if isa(data, 'cell')
                        % Unroll array
                        % Assumes first value contains a format
                        md.format = data{1}(1).Format;
                        for j = 1 : numel(data)
                            if sameDims
                                md.size(j, :) = size(data{j});
                            else
                                s = size(data{j});
                                md.size(j,1 : numel(s)) = s;
                            end
                            data{j} = int64(milliseconds(data{j}(:)) * 1e7);
                        end
                    else
                        md.format = data.Format;
                        data = int64(milliseconds(data) * 1e7);
                    end
                case {Types.DATETIME_MILLIS, Types.DATETIME_MICROS}
                    if isa(data, 'cell')
                        % Unroll array
                        % Assumes first value contains a format
                        md.format = data{1}(1).Format;
                        for j = 1 : numel(data)
                            if sameDims
                                md.size(j, :) = size(data{j});
                            else
                                s = size(data{j});
                                md.size(j,1 : numel(s)) = s;
                            end
                            data{j} = int64(posixtime(data{j}(:)) * 1e7);
                        end
                    else
                        md.format = data.Format;
                        data = int64(posixtime(data) * 1e7);
                    end
                otherwise
                    if isa(data, 'cell')
                        % Unroll numeric, logical array
                        for j = 1 : numel(data)
                            if sameDims
                                md.size(j, :) = size(data{j});
                            else
                                s = size(data{j});
                                md.size(j,1 : numel(s)) = s;
                            end
                            data{j} = data{j}(:);
                        end
                    elseif ~ iscolumn(data)
                        data = reshape(data, md.size(1), prod(md.size(2 : end)));
                    end
            end
            if size(unique(md.size,'rows'),1) == 1
                md.size = md.size(1,:);
            end
        end
    end
    
    methods(Static, Hidden)
        function [out, varargout] = getEnum(data)
            % Get Type from MATLAB data and optionally return the converted
            % data
            %
            % Example:
            
            import bigdata.avro.enum.Types;
            t = Types.primitiveEnum(data);
            unrollArray = false;
            
            if t == Types.CELL
                n = numel(data);
                if iscellstr(data) || ( isstring(data{1}) && n == numel([data{:}]))
                    % Simple cellstr
                    out = Types.STRING;
                else
                    try
                        v = numel([data{:}]);
                    catch
                        % Cell elements will vary in dimensions
                        % so this will be an array
                        v = -1;
                    end
                    ct = Types.primitiveEnum(data{1});
                    if n ~= v
                        % If number of elements in cells is different to number
                        % of cell elements, then it is an array.
                        out.Native = struct('type', 'array', 'items', ...
                            ct.Native);
                        out.Logical = ct.Logical;
                        if nargout >= 2
                            unrollArray = true;
                            [varargout{1}, varargout{2}] = ct.convertData(data);
                        end
                    else
                        out = ct;
                    end
                end
            else
                if iscolumn(data)
                    out = t;
                else
                    % This wil be an array
                    out.Native = struct('type', 'array', 'items', ...
                        t.Native);
                    out.Logical = t.Logical;
                    if nargout >= 2
                        unrollArray = true;
                        [varargout{1}, varargout{2}] = t.convertData(data);
                    end
                end
            end
            
            if nargout >= 2 && ~ unrollArray
                [varargout{1}, varargout{2}] = out.convertData(data);
            end
            
        end
        
        function out = primitiveEnum(data)
            % Get the Avro Type for this MATLAB data
            %
            % This mainly deals with the special datetime types where
            % depending on Format indicates whether its date, datetime_micros,..
            %
            % Example:
            
            import bigdata.avro.enum.Types;
            
            if isa(data,'datetime')
                if isempty(regexp(data.Format,'[hHmsS]','once'))
                    % No hours/minutes or seconds so can use int32
                    out = Types.DATE;
                elseif contains(data.Format,{'SSSSSS','SSSSS','SSSS'})
                    out = Types.DATETIME_MICROS;
                else
                    out = Types.DATETIME_MILLIS;
                end
            elseif isa(data,'duration')
                if contains(data.Format,{'SSSSSS','SSSSS','SSSS'})
                    out = Types.DURATION_MICROS;
                else
                    out = Types.DURATION_MILLIS;
                end
            else
                out = Types.(upper(class(data)));
            end
        end
    end
    
    enumeration
        % -----------------------------------------------------
        %       These are fundamental MATLAB types
        % -----------------------------------------------------
        %
        % web(fullfile(docroot,
        % 'matlab/matlab_prog/fundamental-matlab-classes.html'))
        %
        % MATLABTYPE (NATIVE, LOGICAL)
        
        % logical to Avro
        LOGICAL ('BOOLEAN','')
        
        % double to Avro
        DOUBLE ('DOUBLE','')
        
        % single to Avro
        SINGLE ('FLOAT','')
        
        % int64 to Avro
        INT64 ('LONG','')
        
        % int32 to Avro
        INT32 ('INT','')
        
        % int16 to Avro
        INT16 ('INT','')
        
        % int8 to Avro
        INT8 ('INT','')
        
        % uint64 to Avro
        UINT64 ('LONG','')
        
        % uint32 to Avro
        UINT32 ('INT','')
        
        % uint16 to Avro
        UINT16 ('INT','')
        
        % uint8 to Avro
        UINT8 ('INT','')
        
        % string to Avro
        STRING ('STRING','')
        
        % char to Avro
        CHAR ('STRING','')
        
        % struct to Avro
        STRUCT ('RECORD','')
        
        % table to Avro
        TABLE ('RECORD','')
        
        % timetable to Avro
        TIMETABLE ('RECORD','')
        
        % cell to Avro
        % This needs to be used with getEnum
        CELL ('ARRAY','')
        
        % -----------------------------------------------------
        %       What follows are other derived classes
        % -----------------------------------------------------
        
        % date with yyyy-mm-dd format to Avro native and logical type
        DATE ('INT','DATE')
        
        % duration unlimited precision to Avro native and logical type
        DURATION ('FIXED','DURATION')
        
        % duration with millisecond precision to Avro native and logical type
        DURATION_MILLIS ('INT','TIME-MILLIS')
        
        % duration with microsecond precision to Avro native and logical type
        DURATION_MICROS ('LONG','TIME-MICROS')
        
        % datetime with millisecond precision to Avro native and logical type
        DATETIME_MILLIS ('LONG','TIMESTAMP-MILLIS')
        
        % datetime with microsecond precision to Avro native and logical type
        DATETIME_MICROS ('LONG','TIMESTAMP-MICROS')
    end
end

