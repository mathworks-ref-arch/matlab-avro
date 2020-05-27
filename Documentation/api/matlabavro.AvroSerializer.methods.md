**matlabavro.AvroSerializer/AvroSerializer**

Serialize MATLAB data using binary or JSON encoder

**matlabavro.AvroSerializer.serializeToBinary**

Use binary encoder to serialize

schema - matlabavro.schema to use for serializing

data - MATLAB data to serialize

bytes - byte array containing avro data conforming to schema

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.AvroSerializer.serializeToJSON**

Use JSON encoder to serialize

data - MATLAB data to serialize %

bytes - byte array containing avro data conforming to schema

NOTES:

JSON serializing converts the input data to JSON string using the MATLAB
function jsonencode and then returns a byte array. Avro schemas other than
"string" will work with this function, but will fail for MATLAB matrices having
multiple rows. To serialize MATLAB matrices as avro JSON, use schema type
"string". Look at test cases in testAvroSerializeDeSerialize.m for examples.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |
