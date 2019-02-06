[//]: #  (Copyright 2017, The MathWorks, Inc.)
#   bigdata.avro.Reader 


Class for reading Avro files

See also

[bigdata.avro.Reader/read](bigdata.avro.Reader.read.md),
[bigdata.avro.Writer](bigdata.avro.Writer.md)



## Class Details 

Attributes | Class
:------------------- | :----------------------------------------------------------------
Superclasses      | [bigdata.avro.util.Core](bigdata.avro.util.Core.md)
Sealed            | false
Construct on load | false



## Constructor Summary

Constructor | Summary
:---------------------------------------------------- | :------------------------------
[Reader](Reader.md) | Constructor for Avro Reader 



## Property Summary

Property | Summary
:------------------------------------------------------------------ | :------------------------------------------------
 FileEncoding                                                       | The file encoding 
 FileName                                                           | to read 
 NumRecords                                                         | Number of records to read 
 SeekPosition                                                       | Seek position if \< 0 then seeking is ignored 
 UseSyncToSeek                                                      |  



## Method Summary

Attributes | Method | Summary
:---------- | :---------------------------------------------------------------------------- | :----------------------------------------------------------------------------
        |   [addJars](bigdata.avro.Reader.addJars.md)                     |  Dynamically add JAR\'s from the lib/jar folder 
        |   [addListeners](bigdata.avro.Reader.addListeners.md)           |  Add our PostSet listeners for properties 
        |   [addlistener](bigdata.avro.Reader.addListener.md)             |  Add listener for event. 
        |   [clearJars](bigdata.avro.Reader.clearJars.md)                 |  Clear dynamic JAR\'s from the resourcs/jar folder 
        |   construct                                                     |  the object using default initialization steps 
        |   delete                                                        |  Delete a handle object. 
        |   eq                                                            |  == (EQ) Test handle equality. 
        |   findobj                                                       |  Find objects matching specified conditions. 
        |   findprop                                                      |  Find property of MATLAB handle object. 
        |   ge                                                            |  \>= (GE) Greater than or equal relation for handles. 
        |   getResourcesFolder                                            |  Get the path to the resources folder 
        |   getSchema                                                     |  Get the Avro schema 
        |   getSourceFolder                                               |  Return the Source folder path 
        |   gt                                                            |  \> (GT) Greater than relation for handles. 
Sealed  |   isvalid                                                       |  Test handle validity. 
        |   le                                                            |  \<= (LE) Less than or equal relation for handles. 
        |   listener                                                      |  Add listener for event without binding the listener to the source object. 
        |   lt                                                            |  \< (LT) Less than relation for handles. 
        |   ne                                                            |  \~= (NE) Not equal relation for handles. 
        |   notify                                                        |  Notify listeners of event. 
        |   [parseInputs](bigdata.avro.Reader.parseInputs.md)             |  Parse property values as property/value pairs 
        |   [pastSync](bigdata.avro.Reader.pastSync.md)                   |  Return true if past the next sync point after pos 
        |   [previousSync](bigdata.avro.Reader.previousSync.md)           |  Return the last sync point before our current position 
        |   [read](bigdata.avro.Reader.read.md)                           |  the Avro file into a table 
        |   [seek](bigdata.avro.Reader.seek.md)                           |  Move to a specific, known sync point 
        |   [setter](bigdata.avro.Reader.setter.md)                       |  Callback for property PostSet listener 
        |   [sync](bigdata.avro.Reader.sync.md)                           |  Move to the next sync point after a position 
        |   [tell](bigdata.avro.Reader.tell.md)                           |  Return the current position in the input 



## Event Summary

Event | Summary
:-------------------------------------------------------------------------------- | :------------------------------------------------------------------
 ObjectBeingDestroyed                                                             | Notifies listeners that a particular object has been destroyed. 
