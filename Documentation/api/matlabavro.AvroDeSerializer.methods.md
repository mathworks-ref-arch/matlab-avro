**matlabavro.AvroDeSerializer/AvroDeSerializer**

Deserialize avro data using binary or JSON decoder

**matlabavro.AvroDeSerializer.deserializeFromBinary**

Use Binary decoder to deserialize

INPUT

schema - matlabavro.Schema to use for deserializing

bytes - byte array containing avro data conforming to schema

OUTPUT

data - Deserialized data

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.AvroDeSerializer.deserializeFromJSON**

Use JSON decoder to deserialize

INPUT

bytes - byte array containing avro data conforming to schema

OUTPUT

data - Deserialized data

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |
