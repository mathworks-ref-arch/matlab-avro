[//]: #  (Copyright 2017, The MathWorks, Inc.)
#  bigdata.avro.util.Core/Core  
  
  Core class from which other classes in this project can inherit
 
  This provides useful re-useable methods for classes, thus minimizing the amount of boilerplate  
  level code each class needs.  
 
  - locating the resource and root source path for a project
  - adding and removing dynamic jars
  - constructor method for parsing inputs and setting up loggers
  - parsing of property/value pairs for constructors
  - adding PostSet listeners for properties
  - passing on property changes to equivalent Java setter methods