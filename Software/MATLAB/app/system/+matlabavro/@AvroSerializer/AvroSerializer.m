classdef AvroSerializer    
    %% AVROSERIALIZER Serialize MATLAB data using binary or JSON encoder    
    
    % (c) 2020 MathWorks, Inc.
    
    methods(Static)
        
        function bytes  = serializeToBinary(schema,data)
            %% Use binary encoder to serialize
            %   schema - matlabavro.schema to use for serializing
            %   data - MATLAB data to serialize            
            %   bytes - byte array containing avro data conforming to schema
            
            % Validate, import Java namespaces
            validateattributes(schema,{'matlabavro.Schema'},{});
            import java.io.ByteArrayInputStream;
            import java.io.ByteArrayOutputStream;
            import org.apache.avro.io.EncoderFactory;
            import org.apache.avro.generic.*;
            import org.apache.avro.reflect.*;
            
            % Define bytestream, reflectwriter, binary encoder
            baos = ByteArrayOutputStream();
            writer = ReflectDatumWriter;
            encoder = EncoderFactory.get().binaryEncoder(baos, '');
            
            % Set schema for writer, data to append
            writer.setSchema(schema.jSchemaObj);            
            datatoAppend = matlabavro.AvroHelper.createDataToAppend(schema,data);
            
            % Write to bytestream and flush
            writer.write(datatoAppend, encoder);
            encoder.flush();
            baos.close();
            
            % Return byte array.
            bytes = baos.toByteArray();
        end
        
        function bytes  = serializeToJSON(data)
            %% Use JSON encoder to serialize
            %   data - MATLAB data to serialize            
            %   bytes - byte array containing avro data conforming to schema
            %
            % NOTES:
            %   JSON serializing convertes the input data to JSON string using
            %   the MATLAB function jsonencode and then returns a byte array.
            %   Avro schemas other than "string" will work with this function,
            %   but will fail for MATLAB matrices having multiple rows.
            %   To serialize MATLAB matrices as avro JSON, use schema type
            %   "string". Look at test cases in testAvroSerializeDeSerialize.m
            %   for examples.
            
            % Import Java namespaces            
            import java.io.ByteArrayInputStream;
            import java.io.ByteArrayOutputStream;
            import org.apache.avro.io.EncoderFactory;
            import org.apache.avro.generic.*;
            import org.apache.avro.reflect.*;
            import org.apache.avro.io.*;
            
            % Define bytestream, reflectwriter, jsonencoder
            baos = ByteArrayOutputStream();
            writer = ReflectDatumWriter();
            schema = matlabavro.Schema.parse('{"type":"string"}');
            jsonEncoder = EncoderFactory.get().jsonEncoder(schema.jSchemaObj, baos);
            
            % Set schema for writer, JSON encode data to append
            writer.setSchema(schema.jSchemaObj);
            datatoAppend = jsonencode(data);
            
            % Write to bytestream and flush
            writer.write(datatoAppend, jsonEncoder);
            jsonEncoder.flush();
            baos.flush();
            
            % Return byte array
            bytes = baos.toByteArray();
        end
    end
    
end %class