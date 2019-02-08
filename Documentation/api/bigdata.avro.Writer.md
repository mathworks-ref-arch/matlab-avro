[//]: #  (Copyright 2017, The MathWorks, Inc.)
#   bigdata.avro.Writer 







Class for writing Avro files



See also



[bigdata.avro.Writer/write](Writer.md),
[bigdata.avro.Reader](bigdata.avro.Reader.md)



## Class Details 

Attributes | Class
:------------------- | :----------------------------------------------------------------
Superclasses      | [bigdata.avro.util.Core](bigdata.avro.util.Core.md)
Sealed            | false
Construct on load | false



## Constructor Summary

Constructor | Summary
:---------------------------------------------------- | :------------------------------
[Writer](Writer.md) | Constructor for Avro Writer 



## Property Summary

Property | Summary
:---------------------------------------------------------------------------- | :-----------------------------------------------------------------
 [AddSyncMarker](bigdata.avro.Writer.AddSyncMarker.md)          | Add a sync marker 
 [AppendToFile](bigdata.avro.Writer.AppendtoFile.md)            | Set this to true to append to existing file 
 [AutoGenerateSchema](bigdata.avro.Writer.AutoGenerateSchema.md)| If set to true will try to auto-generate schema from data 
 [Compression](bigdata.avro.Writer.Compression.md)       		| The compression codec to use 
 [CompressionLevel](bigdata.avro.Writer.CompressionLevel.md)   | The compression level between 1 and 9 
 Data                                                           | The data to write 
 FileName                                                       | to write 
 Schema                                                         | The Avro file schema, this can be a string/char or MessageType 



## Method Summary

Attributes | Method | Summary
:---------- | :-------------------------------------------------------------------------------- | :----------------------------------------------------------------------------
        |  [addJars](bigdata.avro.Writer.addJars.md)                          |  Dynamically add JAR\'s from the lib/jar folder 
        |  [addListeners](bigdata.avro.Writer.addListeners.md)                |  Add our PostSet listeners for properties 
        |  [addlistener](bigdata.avro.Writer.addlistener.md)                  |  Add listener for event. 
        |  [clearJars](bigdata.avro.Writer.clearJars.md)                      |  Clear dynamic JAR\'s from the resourcs/jar folder 
        |  construct 									                      |  the object using default initialization steps 
        |  [convertData](bigdata.avro.Writer.convertData.md)                  |  Converts the data for the Avro writer 
        |  delete								                              |  Release Java objects 
        |  eq																  |  == (EQ) Test handle equality. 
        |  findobj									                         |  Find objects matching specified conditions. 
        |  findprop										                 	 |  Find property of MATLAB handle object. 
        |  finish													         |  appending data 
        |  ge																 |  \>= (GE) Greater than or equal relation for handles. 
        |  [generateSchemaString](bigdata.avro.Writer.generateSchemaString.md) |  Generate a Avro schema string from underlying data 
        |  [getColumnAvroType](bigdata.avro.Writer.getColumnAvroType.md)    |  Get the column type used for Avro auto-generated schema 
Static  |  [getMatlabType](bigdata.avro.Writer.getMatlabType.md)            |  Get the MATLAB data type 
        |  [getResourcesFolder](bigdata.avro.Writer.getResourcesFolder.md)  |  Get the path to the resources folder 
        |  [getSizeAndFields](bigdata.avro.Writer.getSizeAndFields.md)      |  Get the data size and fields 
        |  [getSourceFolder](bigdata.avro.Writer.getSourceFolder.md)        |  Return the Source folder path 
        |  gt                                                               |  \> (GT) Greater than relation for handles. 
Static  |  [isValidData](bigdata.avro.Writer.isValidData.md)                                                       |  Is the data of a valid type to write 
Sealed  |  isvalid                                                          |  Test handle validity. 
        |  le                                                               |  \<= (LE) Less than or equal relation for handles. 
        |  listener                                                         |  Add listener for event without binding the listener to the source object. 
        |  lt                                                               |  \< (LT) Less than relation for handles. 
        |  ne                                                               |  \~= (NE) Not equal relation for handles. 
        |  notify                                                           |  Notify listeners of event. 
        |  [parseInputs](bigdata.avro.Writer.parseInputs.md)                |  Parse property values as property/value pairs 
        |  setter                                                           |  Callback for property PostSet listener 
        |  [write](bigdata.avro.Writer.write.md)                            |  data to Avro file 


## Event Summary

Event | Summary
:-------------------------------------------------------------------------------- | :------------------------------------------------------------------
 ObjectBeingDestroyed                                                             | Notifies listeners that a particular object has been destroyed. 
