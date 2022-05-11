**matlabavro.DataFileReader**

Random access to files written with DataFileWriter.

**Class Details**

| **Superclasses**      | handle |
|-----------------------|--------------------------------|
| **Sealed**            | false                          |
| **Construct on load** | false                          |

**Constructor Summary**

| [DataFileReader](matlabavro.DataFileReader.methods.md) | Constructor   |
|--------------------------------------------------------------------------|---------------|


**Method Summary**

|          | addlistener     | Add listener for event.                                                                                                                                                                                                     |
|----------|------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|          | [close](matlabavro.DataFileReader.methods.md)                 | close the DataFileReader                                                                                                                                                                                                              |
|          | delete               | Delete a handle object.                                                                                                                                                                                                     |
|          | eq                      | == (EQ) Test handle equality.                                                                                                                                                                                               |
|          | findobj           | Find objects matching specified conditions.                                                                                                                                                                                 |
|          | findprop           | Find property of MATLAB handle object.                                                                                                                                                                                      |
|          |ge                       | \>= (GE) Greater than or equal relation for handles.                                                                                                                                                                        |
|          | [getMetaKeys](matlabavro.DataFileReader.methods.md)     | Return all meta keys.                                                                                                                                                                                                       |
|          | [getMetaString](matlabavro.DataFileReader.methods.md) | Return the value of a metadata property.                                                                                                                                                                                    |
|          | [getSchema](matlabavro.DataFileReader.methods.md)         | Return the schema for data in this file.  
|          | [getMATLABType](matlabavro.DataFileReader.methods.md)         | Return the MATLAB data type for the data schema in this file.  
|          | gt                     | \> (GT) Greater than relation for handles.                                                                                                                                                                                  |
|          | [hasNext](matlabavro.DataFileReader.methods.md)             | True if more entries remain in this file.                                                                                                                                                                                   |
| Sealed   | isvalid          | Test handle validity.                                                                                                                                                                                                       |
|          | le                      | \<= (LE) Less than or equal relation for handles.                                                                                                                                                                           |
|          | listener           | Add listener for event without binding the listener to the source object.                                                                                                                                                   |
|          | lt                      | \< (LT) Less than relation for handles.                                                                                                                                                                                     |
|          | ne                       | \~= (NE) Not equal relation for handles.                                                                                                                                                                                    |
|          | [next](matlabavro.DataFileReader.methods.md)                   | Returns the next datum                                                                                                                                                                                                      |
|          | notify              | Notify listeners of event.                                                                                                                                                                                                  |
|          | [pastSync](matlabavro.DataFileReader.methods.md)           | Return true if past the next sync point after pos                                                                                                                                                                           |
|          | [previousSync](matlabavro.DataFileReader.methods.md)   | Return the last synchronization point before our current position.                                                                                                                                                          |
|          | [seek](matlabavro.DataFileReader.methods.md)                   | Move to a specific, known synchronization point, one returned from DataFileWriter.sync() while writing.If synchronization points were not saved while writing a file, use sync(long) instead.                               |
|          | [sync](matlabavro.DataFileReader.methods.md)                   | Move to the next synchronization point after a position. To process a range of file entires, call this with the starting position, then check pastSync(long) with the end point before each call to DataFileStream.next().  |
|          | [tell](matlabavro.DataFileReader.methods.md)                   | Return the current position in the input                                                                                                                                                                                    |

**Event Summary**

| ObjectBeingDestroyed | Notifies listeners that a particular object has been destroyed.  |
|--------------------------------------------------------------------------------------|------------------------------------------------------------------|

