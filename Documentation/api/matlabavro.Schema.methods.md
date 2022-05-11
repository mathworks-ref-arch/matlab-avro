**matlabavro.Schema.create**

Create a schema for primitive data types.

Schema Types allowed: int, string, Boolean, null, double, bytes, long, float.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.Schema.createArray**

Create a schema for arrays.

elementType - SchemaType for elements in array.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.Schema.createEnum**

Create a schema for Enums.

name - Enum name to store in avro data.

doc - doc text.

enumName - name of the ennumeration.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.Schema.createFixed**

Create a schema for Fixed type.

name - Schema type of elements to map to.

doc - doc text.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.Schema.createMap**

Create a schema for maps.

valueType - type of elements to map to.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |
|            |        |

**matlabavro.Schema.createRecord**

Create a Record type.

valueType - Schema type of elements to map to.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.Schema.createUnion**

Create a union type.

schemas - cell array of matlabavro.Schema.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.Schema.createSchemaForData**

Generate schema for data to be saved in avro format. Use this method to
automatically generate schema for MATLAB structures, cells and tables.

Set the metadata information for dimensions.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.Schema/getElementType**

If schema is an array, returns its element type.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.Schema/getFields**

If schema is a record, gets all fields.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.Schema/getFullName**

If schema is a record, enum or fixed, returns its namespace-qualified name,
otherwise returns the name of the primitive type.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.Schema/getName**

If this is a record, enum or fixed, returns its name, otherwise the name of the
primitive type.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.Schema/getTypes**

If schema is a union, gets all included types.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.Schema.parse**

Create Schema object by passing in JSON string.

Parse a schema from the provided a single or set of JSON strings.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.Schema/setFields**

If schema is a record, sets the fields.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.Schema/toString**

Return the JSON formatted string.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |
