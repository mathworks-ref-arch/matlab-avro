classdef AvroDeSerializer
    % AvroDeSerializer Deserialize avro data using binary or json decoder

    % Copyright (c) 2020-2022 MathWorks, Inc.
    
    methods(Static)
        
        function data = deserializeFromBinary(schema, bytes)
            % deserializeFromBinary Use Binary decoder to deserialize
            % INPUT
            %   schema - matlabavro.schema to use for serializing
            %   bytes - byte array containing avro data conforming to schema
            % OUTPUT
            %   data - Deserialized data
            
            validateattributes(schema,{'matlabavro.Schema'},{});
            import org.apache.avro.generic.*;
            import java.io.ByteArrayInputStream;
            import java.io.ByteArrayOutputStream;
            import org.apache.avro.io.DecoderFactory;
            import org.apache.avro.file.DataFileStream;
            import org.apache.avro.file.*;
            
            is = ByteArrayInputStream(bytes);
            decoder = DecoderFactory.get().binaryDecoder(is, '');
            reader = GenericDatumReader();
            
            reader.setSchema(schema.jSchemaObj);
            data = reader.read('', decoder);

            % create metainformation for type conversion
            metaInformation = matlabavro.AvroDataMetaInformation;
            metaInformation.schema = schema;

            data = matlabavro.AvroHelper.convertToMATLAB(metaInformation, data);
        end
        
        function data = deserializeFromJSON(bytes)
            % deserializeFromJSON Use JSON decoder to deserialize
            % INPUT            
            %   bytes - byte array containing avro data conforming to schema
            % OUTPUT
            %   data - Deserialized data
            
            % Import Java 
            import org.apache.avro.generic.*;
            import java.io.ByteArrayInputStream;
            import java.io.ByteArrayOutputStream;
            import org.apache.avro.io.DecoderFactory;
            import org.apache.avro.file.DataFileStream;
            import org.apache.avro.file.*;
            
            is = ByteArrayInputStream(bytes);
            schema = matlabavro.Schema.parse('{"type":"string"}');
            decoder = DecoderFactory.get().jsonDecoder(schema.jSchemaObj, is);
            reader = GenericDatumReader();
            
            %set schema for reader and read bytes
            reader.setSchema(schema.jSchemaObj);
            data = reader.read('', decoder);
            
            % JSON decode the data
            data = jsondecode(char(data));
        end
    end
end %class
