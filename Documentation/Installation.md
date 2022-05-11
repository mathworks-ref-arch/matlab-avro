# MATLAB&reg; Interface *for Apache Avro*™

## Basic installation
To install this package:

1. Fetch the source
Fetch the source code, documentation and other files from GitHub.

```bash
git clone --recursive https://github.com/mathworks-ref-arch/matlab-avro.git
```

2. Create the matlabavro JAR file
Use Maven to download the Avro Java API jar file and place the matlabavro JAR file in the 'lib' folder. Please see [detailed instructions to rebuild](Rebuild.md) for more details.

```bash
cd Software/Java
mvn clean package
```

3. Start MATLAB and update paths.
Start MATLAB and update the MATLAB path. A startup script has been provided for this purpose.

```matlab
cd Software/MATLAB/
startup
```
The startup script adds an entry to the MATLAB dynamic Java class path for the Avro JAR file. Using the static class path may yield better performance. To set the static path, create or update a javaclasspath.txt file in the [prefdir](https://www.mathworks.com/help/matlab/ref/prefdir.html) folder. Add the path to the Avro JAR file in javaclasspath.txt.

More information on setting the static class path is [here](https://www.mathworks.com/help/matlab/matlab_external/static-path.html). Restart MATLAB after adding the path for the Avro JAR package.

4. Run unit tests
Run the unit tests using MATLAB's test framework. Please see the [documentation](BasicUsage.md) and  study the tests under the *test/unit* folder to understand the capabilities of this package.

```bash
cd /test/unit
runtests
```

## Advanced
To make this package always available in MATLAB, save the paths to the MATLAB path using *pathtool*. Additionally, create a file called *javaclasspath.txt* in the user's preferences directory ([prefdir](https://www.mathworks.com/help/matlab/ref/prefdir.html)) containing the path to the Avro JAR file.

[//]: #  (copyright 2017-2020, The MathWorks, Inc.)
