# MATLAB Interface *for Apache Avro*

## Overview
This package provides a MATLAB® wrapper for the Apache Avro™ Java API to enable MATLAB developers to work with Avro files.
Help for the MATLAB package is available from within MATLAB. Documentation on the Java API is available [here](https://avro.apache.org/docs/current/api/java/index.html)

## Data types and Schemas
Avro files use schemas that are defined in JSON, with the following mapping between MATLAB data types:

| MATLAB Type | Avro Type |
|---|---|
| double | double |
| logical | boolean  |
| single | float |
| uint8 | int |
| uint16 | int |
| uint32 | int |
| uint64 | long |
| char | string |
| datetime | date |
| duration | timestamp | (both milli and micro second)
| datetime | time |      (both milli and micro second)
| cell | array |

In addition, the interface supports writing of the following MATLAB data types:

- numeric arrays
- string arrays
- table
- timetable
- struct
- cell
- custom user defined objects

The schema can be inspected as well.

## Writing to an Avro file

Writing MATLAB data to an Avro file involves the following steps:

- Define the schema for the data
- Create a DataFileWriter object
- Append the data using the DataFileWriter's append function

To write an array of doubles, the MATLAB code is:

```matlab
myData = 'Test string data.';

% Create STRING schema.
mySchema = matlabavro.Schema.create(matlabavro.SchemaType.STRING);

% Create DataFileWriter for avro file
myWriter = matlabavro.DataFileWriter();
myWriter.createAvroFile(mySchema,'myFile.avro');

% Append string data
myWriter.append(myData);

% Close the writer
myWriter.close();
```
## Reading from an Avro file

Reading from an Avro file involves the following steps:

- Create a DataFileReader for the Avro file
- Use the next() function to read a record

```matlab
myReader = matlabavro.DataFileReader('myFile.avro');
myReaderData = myReader.next();
% Close the reader
myReader.close();
```

To ensure the values are equal:

```matlab
isequal(myData,myReaderData)
```

The Schema class provides methods to create different types of Avro schema. For example, to create a Union Schema, use matlabavro.Schema.CreateUnion method.
The list of supported methods in the Java API is [here](https://avro.apache.org/docs/current/api/java/index.html).

## Writing metadata to an Avro file

When writing MATLAB data types to Avro, it is sometimes necessary to store information such as number of rows, columns etc to ensure data symmetry when writing and reading.
The DataFileWriter class provides a setMeta method that can be used to store meta information. For example, writing a row vector is shown below:

```matlab
myData = [1,2,3];
mySchema = matlabavro.Schema.createArray(matlabavro.SchemaType.DOUBLE);
myWriter = matlabavro.DataFileWriter();

% Set Meta information
myWriter.setMeta('rows',1);
myWriter.setMeta('columns',3);

myWriter.createAvroFile(mySchema,'myFile.avro');
myWriter.append(myData);
myWriter.close();

% Verify equal
myReader = matlabavro.DataFileReader('myFile.avro');
myReaderData = myReader.next();
myReader.close();
isequal(myData,myReaderData)
```

## Writing a MATLAB structure or table to an Avro file

Writing a MATLAB structure to an Avro file requires the creation of a RECORD schema. The matlabavro package provides a method to automatically generate
schema for a MATLAB structure or table. The below code shows an example of how this can be done.

```matlab
myData.x = 'test data';
myData.y = 25;

% Generate schema for struct automatically by parsing the data
mySchema = matlabavro.Schema.createSchemaForData(myData);

% Create a writer, append data and close
myWriter = matlabavro.DataFileWriter();
myWriter.createAvroFile(mySchema,'myFile.avro');
myWriter.append(myData);
myWriter.close();
```

## Writing a Linear Spaced Vector to an Avro file

When writing a linear spaced vector to an Avro file, there are two options:
1. Store meta information for dimension when writing the file using the setMeta method as shown above. When reading, the meta information can be used to reshape the
vector to the correct dimension.
2. Transpose the data before writing to the file. This is because MATLAB stores data in column-major order.

This behavior is similar to using [jsonencode](https://www.mathworks.com/help/matlab/ref/jsonencode.html) and [jsondecode](https://www.mathworks.com/help/matlab/ref/jsondecode.html) of data in MATLAB.
An example using transpose is shown below:

```matlab
% Transpose example for a row vector.
myData = [1,2,3]';
mySchema = matlabavro.Schema.createArray(matlabavro.SchemaType.DOUBLE);
myWriter = matlabavro.DataFileWriter();
myWriter.createAvroFile(mySchema,'myFile.avro');
myWriter.append(myData);
myWriter.close();
% Verify equal
myReader = matlabavro.DataFileReader('myFile.avro');
myReaderData = myReader.next();
myReader.close();
isequal(myData,myReaderData)
```
## Writing int8 values to an Avro file

When writing MATLAB int8 values to Avro, the data type maps to Avro schema 'bytes'. The append method of the DataFileWriter uses a Java byte buffer object to write the data in Avro format. Use the below example to write int8 values:

```matlab
% Transpose example for a row vector.
myData = int8[1,2,3]';
mySchema = matlabavro.Schema.parse('{"type": "bytes"}');
myWriter = matlabavro.DataFileWriter();
myWriter.createAvroFile(mySchema,'myFile.avro');
myWriter.append(myData)
myWriter.close();
% Verify equal
myReader = matlabavro.DataFileReader('myFile.avro');
myReaderData = myReader.next();
myReader.close();
isequal(myData,myReaderData)
```

## Serialization of MATLAB objects to Avro files
Data packed in user defined objects or array of objects can be persisted into Avro files.

Create a MATLAB class user:
```matlab
classdef user
    %USER Class to test writing MATLAB objects to Avro
    properties
        name
        age
        weight
    end

    methods
        function obj = user()
        end
    end
end
```

To write an object of class user, use the below code:

```matlab
myData = user();
myData.name ='test';
myData.age = 42;
myData.weight = 155;
props = properties(myData);
mySchema = matlabavro.Schema.createSchemaForData(myData);
myWriter = matlabavro.DataFileWriter();
% Set metadata isObject to 1
myWriter.setMeta('isObject',1);
myWriter.createAvroFile(mySchema,'myFile.avro');
myWriter.append(myData);
myWriter.close();
% Verify equal
myReader = matlabavro.DataFileReader('myFile.avro');
myReaderData = myReader.next();
myReader.close();
isequal(myData,myReaderData)

```

## Test sync markers

The matlabavro package exposes the seek, sync, tell methods which can be used for seeking to an arbitrary position.

```matlab
mySchema = matlabavro.Schema.create(matlabavro.SchemaType.DOUBLE);
myWriter = matlabavro.DataFileWriter();
myWriter = myWriter.createAvroFile(mySchema,'myFile.avro');

% Define data to write
D1 = 100;
D2 = 200;
D3 = 300;
D4 = 400;

% Write the data and get sync marker for each
myWriter.append(D1);
D2Pos = myWriter.sync();
myWriter.append(D2);
D3Pos = myWriter.sync();
myWriter.append(D3);
D4Pos = myWriter.sync();
myWriter.append(D4);

% Define a DataFileReader
myReader = matlabavro.DataFileReader('myFile.avro');

% To read the value D4, seek using the sync marker from the append method. D7 now has the value for D4
myReader.seek(D4Pos);
D7 = myReader.next();
% To read the value D3, seek using the sync marker from the append method. D6 now has the value for D3
myReader.seek(D3Pos);
D6 = myReader.next();
% To read the value D2, seek using the sync marker from the append method. D5 now has the value for D2
myReader.seek(D2Pos);
D5 = myReader.next();

% Verify equal
isequal(D2,D5)
isequal(D3,D6)
isequal(D4,D7)

% Close reader and writer
myWriter.close();
myReader.close();

```

## Inspecting the Schema

The schema from a stored file can be inspected.

```matlab
myReader = matlabavro.DataFileReader('myFile.avro');
% Get MATLAB wrapper class for the Java Schema object
mySchema = myReader.getSchema();

% Print out schema as a JSON string:
schemaString = mySchema.toString()

```
Using the toString() method of the Schema class returns the JSON string that describes the schema of the file.

```json
 {
       "type" : "record",
       "name" : "record_name",
       "namespace" : "",
       "fields" : [ {
         "name" : "name",
         "type" : "string"
       }, {
         "name" : "number",
         "type" : "double"
       }, {
         "name" : "color",
         "type" : "string"
       } ]
     }
```

[//]: #  (Copyright 2017-2020, The MathWorks, Inc.)
