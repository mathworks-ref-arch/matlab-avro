classdef DataFileReader < handle    
    %% DATAFILEREADER Random access to files written with DataFileWriter.   
    
    % Copyright (c) 2020-2022 MathWorks, Inc.
        
    properties(Hidden)
        jDatumObj
        jReaderObj
        jFile
    end
    
    properties(Access = private)
        metaInformation
    end
    
    methods
        
        function obj = DataFileReader(fName)
            %% DataFileReader Constructor            
            %   fName - file path for Avro file
            validateattributes(fName,{'char'},{});
            import org.apache.avro.generic.*;
            import org.apache.avro.file.*;

            % Connect to Java Avro library
            obj.jDatumObj = GenericDatumReader();
            obj.jFile = javaObject('java.io.File',fName);
            obj.jReaderObj = DataFileReader(obj.jFile, obj.jDatumObj);

            % Create metadata object
            obj.metaInformation = matlabavro.AvroDataMetaInformation;

            % Get shape metadata
            if obj.jReaderObj.getMetaKeys.contains('rows')
                obj.metaInformation.rows = obj.jReaderObj.getMetaLong('rows');
            end
            if obj.jReaderObj.getMetaKeys.contains('columns')
                obj.metaInformation.cols = obj.jReaderObj.getMetaLong('columns');
            end

            % get type metadata
            if obj.jReaderObj.getMetaKeys.contains('isCell')
                obj.metaInformation.isCell = obj.jReaderObj.getMetaLong('isCell');
            end
            if obj.jReaderObj.getMetaKeys.contains('isTable')
                obj.metaInformation.isTable = obj.jReaderObj.getMetaLong('isTable');
            end
             if obj.jReaderObj.getMetaKeys.contains('isObject')
                obj.metaInformation.isObject = obj.jReaderObj.getMetaLong('isObject');
            end
            
            % set schema in metadata
            obj.metaInformation.schema = getSchema(obj);
        end
        
        
        function seek(obj,position)
            %% Move to a specific, known synchronization point, one returned from DataFileWriter.sync() while writing.If synchronization points were not saved while writing a file, use sync(long) instead.
            validateattributes(position,{'int','double'},{});
            obj.jReaderObj.seek(position);
        end
        
        function sync(obj,position)
            %% Move to the next synchronization point after a position. To process a range of file entires, call this with the starting position, then check pastSync(long) with the end point before each call to DataFileStream.next().
            validateattributes(position,{'int','double'},{});
            obj.jReaderObj.sync(position);
        end
        
        function pSync = previousSync(obj)
            %% Return the last synchronization point before our current position.
            pSync  = obj.jReaderObj.previousSync();
        end
        function out = pastSync(obj, pos)
            %% Return true if past the next sync point after pos
            out = obj.jReaderObj.pastSync(pos);
        end
        function out = tell(obj)
            %% Return the current position in the input
            out = obj.jReaderObj.tell;
        end
        
        function schema = getSchema(obj)
            %% Return the schema for data in this file.
            sString = obj.jReaderObj.getSchema().toString();
            schema = matlabavro.Schema.parse(sString);
        end

        function metaString = getMetaString(obj,key)
            %% Return the value of a metadata property.
            metaString = string(obj.jReaderObj.getMetaString(key));
        end
        
        function metaKeys = getMetaKeys(obj)
            %% Return all meta keys.
            allKeys = obj.jReaderObj.getMetaKeys();
            metaKeys = string(toArray(allKeys));
        end
        
        
        function hNext = hasNext(obj)
            %% True if more entries remain in this file.
            hNext = obj.jReaderObj.hasNext();
        end
        
        
        function dNext = next(obj)
            %% Returns the next datum
            datum = obj.jReaderObj.next();
            try
                if(obj.metaInformation.isObject)
                    dNext = matlabavro.AvroHelper.convertToMATLABObject(datum);
                else
                    dNext = matlabavro.AvroHelper.convertToMATLAB(obj.metaInformation, datum);
                end

            catch ME
                newException = MException('matlabavro:DataFileReader:next', ...
                    "Unable to read next value from " + string(obj.jFile.toString()) + ".");

                newException = newException.addCause(ME);
                throw(newException)
            end

        end
        
        function obj = close(obj)
            %%  close the datareader
            obj.jReaderObj.close();
        end
    end

end %class
