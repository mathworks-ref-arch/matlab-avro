[//]: #  (Copyright 2017, The MathWorks, Inc.)
#   avroread 





Read an Apache Avro file

DATA = avroread(FILE) Read the Avro FILE and return DATA.

[DATA, READER] = ... second output returns the Reader class.

DATA = avroread(FILE, *Property, Value*,...) optional *Property, Value* pairs
for the READER.

## Properties

Valid Properties for the Reader

'SeekPosition'  - position at which to open or seek or sync
to a file. <  0 are ignored and file will not seek (double)

'NumRecords'    -  number of records to return, Inf is the default
value and will read all records (double)

'UseSyncToSeek' - If the sync marker positions are known, set this to
false, otherwise true.

#### Example: Read in an Avro file and return the reader object as well

[data, reader] = avroread('tmp.avro');

#### Example: Return just the Reader object

reader = avroread;



See also



[bigdata.avro.Reader](bigdata.avro.Reader.md),
[avrowrite](avrowrite.md)
