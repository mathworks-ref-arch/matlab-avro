matlabavro.Schema

**Schema** for avro data

A schema may be one of:

A record, mapping field names to field value data;

An enum, containing one of a small set of symbols;

An array of values, all of the same schema;

A map, containing string/value pairs, of a declared schema;

A union of other schemas;

A fixed sized binary object;

A unicode string;

A sequence of bytes;

A 32-bit signed int;

A 64-bit signed long;

A 32-bit IEEE single-float; or

A 64-bit IEEE double-float; or

A boolean; or null.

**Class Details**

| **Superclasses**      | handle |
|-----------------------|--------------------------------|
| **Sealed**            | false                          |
| **Construct on load** | false                          |

**Constructor Summary**

| Schema | Constructor.  |
|--------------------------------------------------|---------------|


**Property Summary**

| Type |   | Schema type of the avro data.

**Method Summary**

|          | addlistener                     | Add listener for event.                                                                                                        |
|----------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| Static   | [create](matlabavro.Schema.methods.md)                                            | a schema for primitive data types.                                                                                             |
| Static   | [createArray](matlabavro.Schema.methods.md)                     | Create a schema for arrays.                                                                                                    |
| Static   | [createEnum](matlabavro.Schema.methods.md)                       | Create a schema for Enums.                                                                                                     |
| Static   | [createFixed](matlabavro.Schema.methods.md)                     | Create a schema for Fixed type.                                                                                                |
| Static   | [createMap](matlabavro.Schema.methods.md)                         | Create a schema for maps.                                                                                                      |
| Static   | [createRecord](matlabavro.Schema.methods.md)                   | Create a Record type.                                                                                                          |
| Static   | [createSchemaForData](matlabavro.Schema.methods.md)     | Generate schema for data to be saved in avro format.                                                                           |
| Static   | [createUnion](matlabavro.Schema.methods.md)                     | Create a union type.                                                                                                           |
|          | delete                               | Delete a handle object.                                                                                                        |
|          | eq                                     | == (EQ) Test handle equality.                                                                                                  |
|          | findobj                             | Find objects matching specified conditions.                                                                                    |
|          | findprop                          | Find property of MATLAB handle object.                                                                                         |
|          | ge                                       | \>= (GE) Greater than or equal relation for handles.                                                                           |
|          | [getElementType](matlabavro.Schema.methods.md)               | If schema is an array, returns its element type.                                                                               |
|          | [getFields](matlabavro.Schema.methods.md)                         | If schema is a record, gets all fields.                                                                                        |
|          | [getFullName](matlabavro.Schema.methods.md)                     | If schema is a record, enum or fixed, returns its namespace-qualified name, otherwise returns the name of the primitive type.  |
|          | [getName](matlabavro.Schema.methods.md)                             | If this is a record, enum or fixed, returns its name, otherwise the name of the primitive type.                                |
|          | [getTypes](matlabavro.Schema.methods.md)                         | If schema is a union, gets all included types.                                                                                        |
|          | gt)                                       | \> (GT) Greater than relation for handles.                                                                                     |
| Sealed   | isvalid                             | Test handle validity.                                                                                                          |
|          | le                                       | \<= (LE) Less than or equal relation for handles.                                                                              |
|          | listener                           | Add listener for event without binding the listener to the source object.                                                      |
|          | lt                                      | \< (LT) Less than relation for handles.                                                                                        |
|          | ne                                      | \~= (NE) Not equal relation for handles.                                                                                       |
|          | notify                               | Notify listeners of event.                                                                                                     |
| Static   | [parse](matlabavro.Schema.methods.md)                                 | Create Schema object by passing in JSON string.                                                                                |
|          | [setFields](matlabavro.Schema.methods.md)                         | If schema is a record, sets the fields.                                                                                        |
|          | [toString](matlabavro.Schema.methods.md)                           | Return the schema string.                                                                                                      |

**Event Summary**

| ObjectBeingDestroyed | Notifies listeners that a particular object has been destroyed.  |
|------------------------------------------------------------------------------|------------------------------------------------------------------|

