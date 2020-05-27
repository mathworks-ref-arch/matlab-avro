matlabavro.DataFileWriter

Writes avro data to file.

Stores in a file a sequence of data conforming to a schema. The schema is stored
in the file with the data. Each datum in a file is of the same schema. Data is
written with a DatumWriter. Data is grouped into blocks. A synchronization
marker is written between blocks, so that files may be split. Blocks may be
compressed.

Extensible metadata is stored at the end of the file. Files may be appended to.

**Class Details**

| **Sealed**            | false |
|-----------------------|-------|
| **Construct on load** | false |

**Constructor Summary**

| [DataFileWriter](matlabavro.DataFileWriter.methods.md) | Constructor  |
|--------------------------------------------------------------------------|--------------|


**Property Summary**
| [compressionLevel](matlabavro.DataFileWriter.properties.md)                                                       | Compression level. Default value is 6. Provide a value between -5 and 22.                                            |
|----------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| [compressionType](matlabavro.DataFileWriter.properties.md) | Compression types for the avro file - snappy, deflate, bzip2 and null. Use matlabavro.CompressionType enumeration.   |
| [schema](matlabavro.DataFileWriter.properties.md)                   | matlabavro.Schema used for this DatafileWriter.                                                                      |

**Method Summary**

|   | [append](matlabavro.DataFileWriter.methods.md)                     | Append a datum to a file .                                                  |
|---|------------------------------------------------------------------------------|---------------------------------------------------------------------|
|   | [close](matlabavro.DataFileWriter.methods.md)                       | Close the dataFileWriter.      |
|   | [createAvroFile](matlabavro.DataFileWriter.methods.md)     | Open a new file for data matching a schema with a random sync.      |
|   | [createAvroStream](matlabavro.DataFileWriter.methods.md) | Open a new file for data matching a schema with a random sync.      |
|   | [setMeta](matlabavro.DataFileWriter.methods.md)                   | Constructor Sets meta data as key value pair.                       |
|   | [sync](matlabavro.DataFileWriter.methods.md)                         | Returns the sync position to be used with a datafilereader.seek().  |
