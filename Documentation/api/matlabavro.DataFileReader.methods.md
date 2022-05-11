**matlabavro.DataFileReader/DataFileReader**

Constructor

fName - file path for Avro file.

**matlabavro.DataFileReader/getMetaKeys**

Return all meta keys.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/getMetaString**

Return the value of a metadata property.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/getSchema**

Return the schema for data in this file.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/getMATLABType**

Return the MATLAB datatype for avro data schema in this file.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/hasNext**

True if more entries remain in this file.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/next**

Returns the next datum.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/pastSync**

Return true if past the next sync point after pos.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/previousSync**

Return the last synchronization point before our current position.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/seek**

Move to a specific, known synchronization point, one returned from
DataFileWriter.sync() while writing. If synchronization points were not saved
while writing a file, use sync(long) instead.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |

**matlabavro.DataFileReader/sync**

Move to the next synchronization point after a position. To process a range of
file entires, call this with the starting position, then check pastSync(long)
with the end point before each call to DataFileStream.next().

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | false  |
