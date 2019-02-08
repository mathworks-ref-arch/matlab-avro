[//]: #  (Copyright 2017, The MathWorks, Inc.)
# MATLAB&reg; Interface *for Apache Avro*™

[Apache Avro™](https://avro.apache.org/) is a data serialization system.
Avro provides a compact, fast, binary data format and simple integration with dynamic languages.
Avro relies heavily on schemas. When data is stored in a file, the schema is stored with it, so that files may be processed later by any program.

The MATLAB interface for Apache Avro provides for reading and writing of Apache Avro files from within MATLAB. Functionality includes:
* Read and write of local Avro files
* Access to metadata of an Avro file

## Schemas
Avro relies on schemas. When Avro data is read, the schema used when writing it is always present. This permits each datum to be written with no per-value overheads, making serialization both fast and small. This also facilitates use with dynamic, scripting languages, since data, together with its schema, is fully self-describing.

When Avro data is stored in a file, its schema is stored with it, so that files may be processed later by any program. If the program reading the data expects a different schema this can be easily resolved, since both schemas are present.

When Avro is used in RPC, the client and server exchange schemas in the connection handshake. (This can be optimized so that, for most calls, no schemas are actually transmitted). Since both client and server both have the others full schema, correspondence between same named fields, missing fields, extra fields, etc. can all be easily resolved.

Avro schemas are defined with JSON . This facilitates implementation in languages that already have JSON libraries.

## Comparison with other systems
Avro provides functionality similar to systems such as Thrift, Protocol Buffers, etc. Avro differs from these systems in the following fundamental aspects.

*Dynamic typing*: Avro does not require that code be generated. Data is always accompanied by a schema that permits full processing of that data without code generation, static data types, etc. This facilitates construction of generic data-processing systems and languages.

*Untagged data*: Since the schema is present when data is read, considerably less type information need be encoded with data, resulting in smaller serialization size.

*No manually-assigned field IDs*: When a schema changes, both the old and new schema are always present when processing data, so differences may be resolved symbolically, using field names.

## Contents:
1. [System Requirements](Requirements.md)   
2. [Installing the support package](Installation.md)
3. [Basic usage](BasicUsage.md)
4. API reference

    The functions and classes for working with Apache Parquet files in MATLAB.

   The markdown versions of the help may not include all links and one should consult the shipped Help documentation for full documentation set.

    - [Functions](Functions.md)
    - [Classes](Classes.md)
5. Appendix
    - [Rebuilding the JAR](Rebuild.md)  

## References:  
Please see https://avro.apache.org/docs/current.
