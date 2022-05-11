[//]: #  (copyright 2017-2020, The MathWorks, Inc.)
# Building the MATLAB&reg; Interface *for Apache Avro*™ from source
The MATLAB interface for Avro can be rebuilt from source. The rebuilding of
this project can be accomplished by building the underlying JAR
artifacts.

## Requirements
- [Maven](https://maven.apache.org/download.cgi)
- [JDK 8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
- MATLAB 2018b or later

## Fetch the source
For developers wanting to go through the build process, make sure to clone
the project first and checkout master.

```bash
git clone --recursive https://github.com/matlab-avro.git
```

If working on an existing repository make sure its up to-date.

```bash
git pull
```

## Rebuilding the Java components
The JAR library can be rebuilt using:

```bash
cd Software/Java

mvn package
[INFO] Scanning for projects...
[INFO]
[INFO] -----------------< com.mathworks.avro.sdk:matlabavro >------------------
[INFO] Building MATLAB Interface for Avro 0.4
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] --- maven-dependency-plugin:3.1.1:copy (default-cli) @ matlab-avro-sdk ---
[INFO] Configured Artifact: org.apache.avro:avro:1.9.2:jar
[INFO] Copying avro-1.9.2.jar to C:\Pilot Work\Avro_fresh\Software\MATLAB\lib\jar\matlabavro.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  1.116 s
[INFO] Finished at: 2020-05-07T03:35:53-04:00
[INFO] ------------------------------------------------------------------------

```

The output JAR library resides in the ```/target/``` folder.
The maven package step places the renamed JAR file in the folder ```Software/MATLAB/lib/jar```.
