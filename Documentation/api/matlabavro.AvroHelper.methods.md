**matlabavro.AvroHelper/AvroHelper**

Helper class to create data structure complying with avro schema.

**matlabavro.AvroHelper.convertToMATLAB**

Pass in data read from an avro file and convert to MATLAB type based on
flags/metadata

isTable - convert to table

isCell - convert to cell

rows - number of rows to use for reshape

columns - number of columns to use for reshape

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.AvroHelper.convertToMATLABObject**

Pass in data read from an avro file and convert to MATLAB object

inputData - data read from an avro file.

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |

**matlabavro.AvroHelper.createDataToAppend**

Create data structure conforming to schema from MATLAB structures and tables.

schema - matlabavro.Schema for the data

data - MATLAB data to append

**Method Details**

| **Access** | public |
|------------|--------|
| **Sealed** | false  |
| **Static** | true   |
