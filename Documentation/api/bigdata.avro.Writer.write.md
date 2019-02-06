[//]: #  (Copyright 2017, The MathWorks, Inc.)
# bigdata.avro.Writer/write  
  
  Write data to Avro file  
 
  write(DATA, Property, Value,...) Write the DATA to file, this
  can be followed by additional Property/Value pairs.
 
  #### Example: Write a table to a Avro file  
 
        % Initialize the Writer
        import bigdata.avro.*;
        writer = Writer('FileName','tmp.avro');
 
        % Create table of values
        rows = 100;
        cols = 2;
        maxi = 65536;
        data = array2table([(1 : rows)', randi(maxi,rows,cols)]);
 
        % Add some RowNames and write these as well.
        data.Properties.RowNames = cellstr("Row"+(1:100))';
        writer.write(data)
 
  
 ## Method Details  
  
Name | Value  
:------------------- | :----------------------------------------------------------------
**Access** | public  
**Sealed** | false  
**Static** |false  
