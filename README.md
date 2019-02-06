[//]: #  (Copyright 2017, The MathWorks, Inc.)

#  MATLAB&reg; Interface *for Apache Avro*™

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
Please see the [documentation](Documentation/Installation.md) for detailed installation instructions. To get started quickly:  

### Build the JAR file
To install the interface, first build the JAR file.
```bash
cd Software/Java
mvn clean package
```

### Install the MATLAB package
Open MATLAB and install the support package.
```MATLAB
cd Software/MATLAB
startup
```

## Getting Started

To write a variable to an Avro file:
```MATLAB
data = randn(1e2,5);
avrowrite('tmp.avro', data);
```

The same file can be read with
```MATLAB
tmp = avroread('tmp.avro');
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
