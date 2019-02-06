[//]: #  (Copyright 2017, The MathWorks, Inc.)
# avrowrite 

Write data to an Apache Avro file

avrowrite(FILE, DATA) writes DATA to an Avro FILE

WRITER = ... return the Writer object.

avrowrite(FILE, DATA, *Property, Value*,...) optional *Property, Value* pairs
for the Writer.

## Properties

Valid Properties for the Writer

'Compression' - 'snappy','none','deflate'

'CompressionLevel' - a value from 1 to 9 , only applies to deflate

'AppendToFile' - true to append to existing file (logical)

'AddSyncMarker' - true to add sync markers after each record (logical)

#### Example: Create an array and write to tmp.avro

avrowrite('tmp.avro',randn(10))

See also


[bigdata.avro.Writer](bigdata.avro.Writer.md),
[avroread](avroread.md)
