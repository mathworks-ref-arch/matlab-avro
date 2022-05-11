classdef DataFileWriter < handle
    %% DATAFILEWRITER Writes avro data to file.
    %
    %   Stores in a file a sequence of data conforming to a schema. The schema is stored in the file with the data.
    %   Each datum in a file is of the same schema. Data is written with a DatumWriter. Data is grouped into blocks.
    %   A synchronization marker is written between blocks, so that files may be split. Blocks may be compressed.
    %   Extensible metadata is stored at the end of the file. Files may be appended to.
    %
   
    % Copyright (c) 2020-2022 MathWorks, Inc.
   
    
    properties
        %% Compression types for the avro file - snappy, deflate, bzip2 and null. Use matlabavro.CompressionType enumeration. 
        compressionType matlabavro.CompressionType
        %% Compression level. Default value is 6. Provide a value between -5 and 22.
        compressionLevel = 6
    end
    
    properties(Hidden)
        jDatumObj
        jWriterObj
        jFile
        schemaString
    end
    
    properties(SetAccess = private)
        %% matlabavro.Schema used for this DatafileWriter.
        schema
    end

    properties(Access = private)
        metaInformation
    end
    
    methods       
        function obj = DataFileWriter()
             %% Constructor
            import org.apache.avro.reflect.*;
            
            % Connectg to Avro Java Jibrary
            obj.jDatumObj = ReflectDatumWriter();
            obj.jWriterObj = javaObject('org.apache.avro.file.DataFileWriter',obj.jDatumObj);

            % Create metadata object
            obj.metaInformation = matlabavro.AvroDataMetaInformation;
        end
        
        function obj = set.compressionType(obj,value)
            validateattributes(value,{'matlabavro.CompressionType'},{});
            import org.apache.avro.file.*;
            switch value
                case matlabavro.CompressionType.NULL
                    obj.jWriterObj.setCodec(CodecFactory.nullCodec);
                case matlabavro.CompressionType.SNAPPY
                    try
                        obj.jWriterObj.setCodec(CodecFactory.snappyCodec);
                    catch ME
                        warning('Snappy codec not found. Install the snappy compression library to use this option. Proceeding with deflate compression level 6.');
                        obj.jWriterObj.setCodec(CodecFactory.deflateCodec(6));
                    end
                case matlabavro.CompressionType.DEFLATE
                    obj.jWriterObj.setCodec(CodecFactory.deflateCodec(obj.compressionLevel));
            end
            obj.compressionType = value;
        end
        
        function obj = setMeta(obj,key, value)
            %% Constructor Sets meta data as key value pair.
            %  key - string/char
            %  value - string/double/long
            validateattributes(key,{'char','string'},{});
            validateattributes(value,{'double','char','string'},{});
            obj = obj.jWriterObj.setMeta(key,value);
        end

        function set.compressionLevel(obj, value)
            %% Sets compression level.
            %   value - double/int32 between -5 and 22
            %   Negative levels are 'fast' modes, levels above 9 are generally for archival purposes,
            %   and levels above 18 use a lot of memory.            
            validateattributes(value,{'int32','double'},{'>',-5,'<',22});
            obj.compressionLevel = value;
        end

        function obj = createAvroFile(obj,schema, fileName)
            %% Open a new file for data matching a schema with a random sync.
            validateattributes(fileName,{'char','string'},{});
            validateattributes(schema,{'matlabavro.Schema'},{});
            obj.jFile = javaObject('java.io.File',fileName);
            obj.schema = schema;
            obj.jWriterObj = obj.jWriterObj.create(schema.jSchemaObj, obj.jFile);
        end        

        function obj = createAvroStream(obj,schema)
            %% Open a new file for data matching a schema with a random sync.
            validateattributes(schema,{'matlabavro.Schema'},{});
            import java.io.ByteArrayOutputStream;
            jByteStream = ByteArrayOutputStream();
            obj.schema = schema;
            obj.jWriterObj = obj.jWriterObj.create(schema.jSchemaObj, jByteStream);
        end

        function obj = append(obj,data)
            %% Append a datum to a file
            dataToAppend = matlabavro.AvroHelper.createDataToAppend(obj.schema, data);
            obj.jWriterObj.append(dataToAppend);
            obj.jWriterObj.flush();
        end

        function pos = sync(obj)
            %% Returns the sync position to be used with a datafilereader.seek().
            pos = obj.jWriterObj.sync();
        end

        function obj = close(obj)
            %% Close the DataFileWriter.
            obj.jWriterObj.close();
        end
        
    end
end
