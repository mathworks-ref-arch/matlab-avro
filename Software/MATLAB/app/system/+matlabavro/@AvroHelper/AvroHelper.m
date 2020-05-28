classdef AvroHelper
    %% AVROHELPER Helper class to create data structure complying with avro schema
    
    % (c) 2020 MathWorks, Inc.
    
    methods(Static)
        
        function outRecord = createDataToAppend(schema, data)
            %% Create data structure conforming to schema from MATLAB structures and tables, and data types like int8 which map to bytebuffer.
            % INPUT
            %   schema - matlabavro.schema for the data
            %   data - MATLAB data to append
            
            validateattributes(schema,{'matlabavro.Schema'},{});
            import import org.apache.avro.generic.*;
            if(istable(data) || isa(data,'timetable'))
                data = table2struct(data,'ToScalar',true);
            end
            outRecord = data;
            if isa(data,'char') || isa(data,'string')
                outRecord = java.lang.String(data);
            elseif isstruct(data) || isobject(data)
                if isenum(data)
                    genericRecord = javaObject('org.apache.avro.generic.GenericData$EnumSymbol',schema.jSchemaObj,string(data));
                    outRecord =  genericRecord;
                else
                    genericRecord = javaObject('org.apache.avro.generic.GenericData$Record',schema.jSchemaObj);
                    outRecord =  matlabavro.AvroHelper.createRecordForStruct(genericRecord, data);
                end
            elseif isa(data,'int8')
                bytesBuffer = java.nio.ByteBuffer.allocate(numel(data));
                bytesBuffer.put(data);
                bytesBuffer.rewind();
                outRecord = bytesBuffer;            
            end
        end
        
        
        function outputArg = convertToMATLABObject(inputData)
            %% Pass in data read from an avro file and convert to MATLAB object
            % inputData - data read from an avro file.
            
            outputArg = jsondecode(char(inputData.toString));
            className = inputData.getSchema.getName;
            
            % Construct the MATLAB object
            mlObj = feval(char(className)); %#ok<*AGROW>
            
            % Populate MATLAB object properties
            pNames = fieldnames(mlObj);
            
            %TODO - use convertotomatlab to ensure symmetry
            for pCount = 1:numel(pNames)
                mlObj.(pNames{pCount})=outputArg.(pNames{pCount});
            end
            outputArg = mlObj;
        end
        
        function outputArg = convertToMATLAB(isTable,isCell,rows, columns,inputData)
            %% Pass in data read from an avro file and convert to MATLAB type based on flags/metadata
            % isTable - convert to table
            % isCell - convert to cell
            % rows - number of rows to use for reshape
            % columns - number of columns to use for reshape
            
            outputArg = inputData;
            if isa(inputData,'org.apache.avro.generic.GenericData$Record')
                outputArg = jsondecode(char(inputData.toString));
                %Check if any field is bytes - requires conversion to int8
                if isstruct(outputArg)
                    if inputData.getSchema().toString().contains(java.lang.String('bytes'))
                        props = fieldnames(outputArg);
                        for pCount = 1:numel(props)
                           if inputData.getSchema().getField(props{pCount}).schema.getType().toString().equals("BYTES")
                               outputArg.(props{pCount}) = inputData.get(props{pCount}).array();
                           end
                        end
                    end
                    if(isTable == 1)
                        outputArg = struct2table(outputArg);
                        if rows > 0
                            outputArg = reshape(outputArg, rows,columns);
                        end
                    end
                elseif ismatrix(inputData)
                    if rows > 0
                        outputArg = reshape(inputData, rows,columns);
                    end
                    if(isCell == 1)
                        outputArg = mat2cell(outputArg);
                    end
                end
            elseif isa(inputData,'org.apache.avro.generic.GenericData$Array')
                outputArg = jsondecode(char(inputData.toString));
                if rows > 0
                    outputArg = reshape(outputArg, rows,columns);
                end
                if(isCell == 1)
                    outputArg = num2cell(outputArg);
                end
            elseif isa(inputData,'org.apache.avro.util.Utf8')
                outputArg = char(inputData);
            elseif isa(inputData,'java.nio.HeapByteBuffer')
                outputArg = inputData.array();
            else
                %TODO - temp check to resize if data type is not avro type.
                % Needs more edge case testing
                if(rows>0)
                    outputArg = reshape(outputArg, rows,columns);
                end
            end
        end
    end
    methods(Static, Access = private)
        function genericRecord = createRecordForStruct(genericRecord,data)
            %% Creates avro generic record for a struct data type
            % genericRecord - initial egeneric record
            % data to write to avro
            props = fieldnames(data);
            for pCount = 1:numel(props)
                % Populates the properties
                if(isa(data.(props{pCount}),'struct'))
                    innerSchema = genericRecord.getSchema().getField(props{pCount}).schema();
                    innerRec = javaObject('org.apache.avro.generic.GenericData$Record',innerSchema);
                    genericRecord.put(props{pCount},matlabavro.AvroHelper.createRecordForStruct(innerRec,data.(props{pCount})));
                else
                    if numel(data)>1
                        genericRecord.put(props{pCount},{data.(props{pCount})});
                    else
                        if isa(data.(props{pCount}),'int8')
                            bytesBuffer = java.nio.ByteBuffer.allocate(numel(data.(props{pCount})));
                            bytesBuffer.put(data.(props{pCount}));
                            bytesBuffer.rewind();
                            genericRecord.put(props{pCount},bytesBuffer);                        
                        else
                            %Required to handle single chars
                            if (isa(data.(props{pCount}),'char') || isa(data.(props{pCount}),'string')) && length(data.(props{pCount})) == 1
                                genericRecord.put(props{pCount},java.lang.String(data.(props{pCount})));
                            else
                                genericRecord.put(props{pCount},data.(props{pCount}));
                            end
                            
                        end
                    end
                end
            end
        end
    end
    
end %class