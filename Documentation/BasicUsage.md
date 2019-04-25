[//]: #  (Copyright 2017, The MathWorks, Inc.)
# MATLAB&reg; Interface *for Apache Avro*™  

## Overview
This package provides the ```avroread``` and ```avrowrite``` functions to serialize and deserialize Avro files.
Help is also available from within MATLAB.

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

- numeric | string arrays
- table
- timetable
- struct
- cell
- custom user defined objects

The schema can be inspected as well.

## Write an Avro file
Writing an array of numbers to file is easy using ```avrowrite```:

```matlab
data = randn(1e5,10);
avrowrite('tmp.avro', data);
```

Writing to HDFS:

```
% Replace the server address and user in hdfsURL with correct values.
hdfsURL = "hdfs://\<server>/<user>/";
hdfsFName = hdfsURL + "tmp.avro";
avrowrite(hdfsFName,data);   
```


## Read an Avro file
Use ```avroread``` to read the values back in:

```
r = avroread('tmp.avro');
```

Reading from HDFS:

```
r = avroread(hdfsFName);   
```

To ensure the values are equal:

```
isequal(data,r)
```
## Writing a Linear Spaced Vector to an Avro file
When writing a linear spaced vector to an Avro file, note that the data should be transposed before writing to the file. This is because MATLAB stores data in column-major order.
This behavior is similar to using [jsonencode](https://www.mathworks.com/help/matlab/ref/jsonencode.html) and [jsondecode](https://www.mathworks.com/help/matlab/ref/jsondecode.html) of data in MATLAB.

```
D1.x = linspace(0,6)';
D1.y = sin(D1.x);
fn = 'tmp.avro';
avrowrite(fn, D1);
D2 = avroread(fn);
isequal(D1,D2)
```

## Serialization of MATLAB objects to Avro files
Data packed in user defined objects or array of objects can be persisted into Avro files.

For example:

```matlab
ex = example.user;
ex.name = 'Test';
ex.number = 42;
ex.color = 'ultraviolet';
```

To save the object as an Avro file:

```matlab
avrowrite('example.avro',ex);   
```
## Deserialization of MATLAB objects from Avro files
The deserialization of MATLAB objects works equally simply.

```matlab
user = avroread('example.avro')

user =

  user with properties:

      name: 'Test'
    number: 42
     color: 'ultraviolet'
```

## Vectorization
The serialization support extends to arrays of objects. This allows code to be vectorized.

For example, let us create an array of a 100 users.

```matlab
n = 100;
containerObjs = repmat(example.user, n,1);
```

Populating them with random data:

```matlab
names  = cellfun(@(x) char(randi([65 122],15,1))', cell(n,1)','UniformOutput',false)';
colors = cellfun(@(x) char(randi([65 122],15,1))', cell(n,1)','UniformOutput',false)';
nums   = num2cell(randi(1024,100,1));

[containerObjs.name] = deal(names{:});
[containerObjs.color] = deal(colors{:});
[containerObjs.number] = deal(nums{:});
```

It is possible to save the data file by saving all elements of the array.

```matlab
avrowrite('sample.avro', containerObjs);
```

Save a slice of the data
```matlab
avrowrite('slice.avro', containerObjs(50:70));
```

## Appending data
It is possible to append data to existing files. For example,
using the same array of objects in the previous section, slices of this
data can be appended to an avro file.

```matlab
avrowrite('growingfile.avro', [containerObjs(1:10).number]);   
avrowrite('growingfile.avro', [containerObjs(11:20).number],'AppendToFile',true);   
avrowrite('growingfile.avro',[containerObjs(21:30).number],'AppendToFile',true)   
avrowrite('growingfile.avro', [containerObjs(31:40).number],'AppendToFile',true);   

```

## Test sync markers

Lets seek to an arbitrary position first, it will seek to the next sync
marker automatically since the file has been written with sync markers.

```
[data,reader] = avroread('growingfile.avro','NumRecords',1,...
    'SeekPosition',-1,'UseSyncToSeek',false)   

data =

   510   326   287   901   195   273    68   151   635   575


reader =

  Reader with properties:

         FileName: 'growingfile.avro'
     SeekPosition: -1
       NumRecords: 1
     FileEncoding: BINARY
    UseSyncToSeek: 0

```

Read the next record, switch the seek position off by setting < 0

```
reader.read('SeekPosition',-1)

ans =

   504   184   356   480    80   152   558   874   158   212

```

Now read 2 records

```
reader.NumRecords = 2;
```

Similarly using Property/Value pairs

```
reader.read('NumRecords',2)   

ans =

  Columns 1 through 8

         946         265         317         933         196         529         366         108
         632        1003         927         681         789         107         670         192

  Columns 9 through 10

         636         478
         355         338
```

Capture the sync point, for future use.

```
pos = reader.previousSync
pos =

        1054
```

Read some more records, two at a time.

```
reader.read;
reader.read;
reader.read
```

Seek back to our sync point, *pos* from above

```
reader.read('SeekPosition',pos)
```

## Inspecting the Schema
The schema from a stored file can be inspected.

```matlab
reader = avroread;
reader.getSchema('sample.avro')
```
The result is a JSON string that describes the schema of the file.

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
