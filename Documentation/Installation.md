[//]: #  (Copyright 2017, The MathWorks, Inc.)
# MATLAB&reg; Interface *for Apache Avro*™

## Basic installation  
To install this package:

1. Fetch the source
Fetch the source code, documentation and other files from GitHub.  

```
git clone --recursive https://github.com/matlab-avro.git
```

2. Compile the JAR file
Compile the Java code using Maven. Please see [detailed instructions to rebuild](Rebuild.md) for more details.  

```
cd Software/Java  
mvn clean package

```

3. Start MATLAB and update paths.
Start MATLAB and update the MATLAB path. A startup script has been provided for this purpose.  

```
cd Software/MATLAB/
startup

```

4. Run unit tests  
Run the unit tests using MATLAB's test framework. Please see the [documentation](BasicUsage.md) and  study the tests under the *test/unit* folder to understand the capabilities of this package.  

```
cd /test/unit
runtests
```

## Advanced
To make this package always available to MATLAB, please save the paths to the MATLAB path using the *pathtool*. Additionally, create a file called *javaclasspath.txt* in the user's preferences directory ([prefdir](https://www.mathworks.com/help/matlab/ref/prefdir.html)).
