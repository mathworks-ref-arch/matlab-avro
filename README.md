[//]: #  (Copyright 2017, The MathWorks, Inc.)

#  MATLAB&reg; Interface *for Apache Avro*™

[![Build Status](https://travis-ci.com/mathworks-ref-arch/matlab-avro.svg?branch=master)](https://travis-ci.com/mathworks-ref-arch/matlab-avro)

## Requirements
### MathWorks Products (http://www.mathworks.com)
* Requires MATLAB release R2017b or newer

### 3rd Party Products:
For building the JAR file:
- [Maven](https://maven.apache.org/download.cgi)
- [JDK 8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

## Introduction
[Apache Avro™](https://avro.apache.org/) is a data serialization system.
Avro provides a compact, fast, binary data format and simple integration with dynamic languages.
Avro relies heavily on schemas. When data is stored in a file, the schema is stored with it, so that files may be processed later by any program.

The MATLAB interface for Apache Avro provides for reading and writing of Apache Avro files from within MATLAB. Functionality includes:
* Read and write of local Avro files
* Access to metadata of an Avro file


## Installation
Installation of the interface requires building the support package (JAR file) using Maven.

Before proceeding, ensure that the below products are installed:  
a) Java SDK  
b) Maven  

The links to download these products are provided in the section [3rd party products](#3rd-party-products).

Please see the [documentation](Documentation/Installation.md) for detailed installation instructions. To get started quickly:  

### Build the JAR file
To install the interface, first build the JAR file.
```bash
cd Software/Java
mvn clean package
```  
The maven build places the Avro package in the location ```/Software/MATLAB/lib/jar/```. Note the full path to the JAR file as this should be added to the MATLAB Java classpath path in the next step.  

### Install the MATLAB package
Open MATLAB and install the support package.
```MATLAB
cd Software/MATLAB
startup
```
The startup script checks if the required packages are added to the MATLAB paths. If the JAR file is not already added to the MATLAB static Java class path, the startup script will automatically add it to the dynamic classpath. Using the static class path may result in better performance. To set the static path, see [detailed instructions to install](Documentation/Installation.md).  

## Getting Started

To write a variable to an Avro file:
```MATLAB
myData = 'Test string data.';

% Create STRING schema.
mySchema = matlabavro.Schema.create(matlabavro.SchemaType.STRING);

% Create DataFileWriter for avro file
myWriter = matlabavro.DataFileWriter();
myWriter.createAvroFile(mySchema,'myFile.avro');

% Append string data
myWriter.append(myData);
```

The same file can be read with
```MATLAB
myReader = matlabavro.DataFileReader('myFile.avro');
myReaderData = myReader.next();
```
Always close the reader and writer objects
```MATLAB
myReader.close();
myWriter.close();
```
A few unit tests are provided in the Software/MATLAB/test/unit folder. These can be run with
```MATLAB
cd Software/MATLAB/test/unit;
runtests;
```

For more details, look at the [Basic Usage document](Documentation/BasicUsage.md).


## Documentation
See [documentation](Documentation/README.md) for more information.


## License
The license for MATLAB interface *for Avro* is available in the [LICENSE.TXT](LICENSE.TXT) file in this GitHub repository.
This package uses certain third-party content which is licensed under separate license agreements.
See the [pom.xml](Software/Java/pom.xml) file for third-party software downloaded at build time.

## Enhancement Requests
Provide suggestions for additional features or capabilities using the following link:   
https://www.mathworks.com/products/reference-architectures/request-new-reference-architectures.html

## Support
Email: `mwlab@mathworks.com`

------------
