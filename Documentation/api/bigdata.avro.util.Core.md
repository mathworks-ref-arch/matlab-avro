[//]: #  (Copyright 2017, The MathWorks, Inc.)
#  bigdata.avro.util.Core


Core class from which other classes in this project can inherit
 
  This provides useful re-useable methods for classes, thus minimizing
  the amount of boilerplate level code each class needs.
 
  - locating the resource and root source path for a project
  - adding and removing dynamic jars
  - constructor method for parsing inputs and setting up loggers
  - parsing of property/value pairs for constructors
  - adding PostSet listeners for properties
  - passing on property changes to equivalent Java setter methods  
  

## Class Details 

Attributes | Class
:------------------- | :----------------------------------------------------------------
Superclasses      | handle
Sealed            | false
Construct on load | false



## Constructor Summary

Constructor | Summary
:---------------------------------------------------- | :------------------------------
[Core](Core.md) | class from which other classes in this project can inherit


## Method Summary

Attributes | Method | Summary
:---------- | :-------------------------------------------------------------------------------- | :----------------------------------------------------------------------------
        |  [addJars](bigdata.avro.util.Core.addJars.md)                          |  Dynamically add JAR\'s from the lib/jar folder 
        |  [addListeners](bigdata.avro.util.Core.addListeners.md)                |  Add our PostSet listeners for properties 
        |  [addlistener](bigdata.avro.util.Core.addlistener.md)                  |  Add listener for event. 
        |  [clearJars](bigdata.avro.util.Core.clearJars.md)               	          |  Clear dynamic JAR\'s from the resourcs/jar folder 
        |  construct									                         |  the object using default initialization steps 
        |  delete									                             |  Release Java objects 
        |  eq							                                      |  == (EQ) Test handle equality. 
        |  findobj                         									 |  Find objects matching specified conditions. 
        |  findprop									                         |  Find property of MATLAB handle object. 
        |  ge								                                 |  \>= (GE) Greater than or equal relation for handles. 
        |  [getResourcesFolder](bigdata.avro.util.Core.getResourcesFolder.md)|  Get the path to the resources folder 
        |  [getSourceFolder](bigdata.avro.util.Core.getSourceFolder.md)    	|  Return the Source folder path
        |  gt                                                               |  \> (GT) Greater than relation for handles. 
Sealed  |  isvalid                                                          |  Test handle validity. 
        |  le                                                               |  \<= (LE) Less than or equal relation for handles. 
        |  listener                                                         |  Add listener for event without binding the listener to the source object. 
        |  lt                                                               |  \< (LT) Less than relation for handles. 
        |  ne                                                               |  \~= (NE) Not equal relation for handles. 
        |  notify                                                           |  Notify listeners of event. 
        |  [parseInputs](bigdata.avro.util.Core.parseInputs.md)		                    |  Parse property values as property/value pairs 
        |  [setter](bigdata.avro.util.Core.setter.md)                                 |  Callback for property PostSet listener 




## Event Summary

Event | Summary
:-------------------------------------------------------------------------------- | :------------------------------------------------------------------
 ObjectBeingDestroyed                                                             | Notifies listeners that a particular object has been destroyed. 