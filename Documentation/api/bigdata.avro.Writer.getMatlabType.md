[//]: #  (Copyright 2017, The MathWorks, Inc.)
# bigdata.avro.Writer.getMatlabType  
  
  Get the MATLAB data type
 
  For most cases the values returned by class(data) will be used.
  Data types such as datetime or duration will be converted to one of the types as defined in
  bigdata.avro.enum.Types
 
  See the bigdata.avro.enum.Types for how values returned by
  this method, getMatlabType, are written to Avro.
 
  Only called by GETCOLUMNTYPE
 
  
  ## Method Details  
  
Name | Value  
:------------------- | :----------------------------------------------------------------
**Access** | public  
**Sealed** | false  
**Static** |true  
