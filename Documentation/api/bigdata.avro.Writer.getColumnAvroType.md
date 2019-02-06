[//]: #  (Copyright 2017, The MathWorks, Inc.)
# bigdata.avro.Writer/getColumnAvroType  
  
  Get the column type used for Avro auto-generated schema  
 
  Returns a containers.Map object K=COLUMN_NAME, V=TYPE
  where TYPE is a struct with fields indicating 'Native' and
  'Logical' type values used in schema generation, as well as
  the 'MATLAB' field for the underlying MATLAB type.
 
  NOTE: The fields are returned in their original order. If 
  extracted from the Map using the keys value then the
  fields will be alphabetically sorted. This can change the
  order in which fields are written.
  
  ## Method Details  
  
Name | Value  
:------------------- | :----------------------------------------------------------------
**Access** | public  
**Sealed** | false  
**Static** |false  
