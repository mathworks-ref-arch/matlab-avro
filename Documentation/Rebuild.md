[//]: #  (Copyright 2017, The MathWorks, Inc.)
# Building the MATLAB&reg; Interface *for Apache Avro*™ from source
The MATLAB interface for Avro can be rebuilt from source. The rebuilding of
this project can be accomplished by building the underlying JAR
artifacts.

## Requirements
- [Maven](https://maven.apache.org/download.cgi)
- [JDK 8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
- MATLAB 2017b or later

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

mvn clean package

[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building MATLAB Interface for Avro 0.1
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ avro ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory C:\work\Avro\Software\Java\src\main\resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ avro ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 2 source files to C:\work\Avro\Software\Java\target\classes
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ avro ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory C:\work\Avro\Software\Java\src\test\resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ avro ---
[INFO] No sources to compile
[INFO]
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ avro ---
[INFO] No tests to run.
[INFO]
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ avro ---
[INFO] Building jar: C:\work\Avro\Software\Java\target\avro-0.1.jar
[INFO]
[INFO] --- maven-shade-plugin:3.1.1:shade (default) @ avro ---
[INFO] Including org.apache.avro:avro:jar:1.8.2 in the shaded jar.
[INFO] Including org.codehaus.jackson:jackson-core-asl:jar:1.9.13 in the shaded jar.
[INFO] Including org.codehaus.jackson:jackson-mapper-asl:jar:1.9.13 in the shaded jar.
[INFO] Including com.thoughtworks.paranamer:paranamer:jar:2.7 in the shaded jar.
[INFO] Including org.xerial.snappy:snappy-java:jar:1.1.1.3 in the shaded jar.
[INFO] Including org.apache.commons:commons-compress:jar:1.8.1 in the shaded jar.
[INFO] Including org.tukaani:xz:jar:1.5 in the shaded jar.
[INFO] Including org.slf4j:slf4j-api:jar:1.7.7 in the shaded jar.
[INFO] Replacing original artifact with shaded artifact.
[INFO] Replacing C:\work\Avro\Software\Java\target\avro-0.1.jar with C:\work\Avro\Software\Java\target\avro-0.1-shaded.jar
[INFO] Dependency-reduced POM written at: C:\work\Avro\Software\Java\dependency-reduced-pom.xml
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 16.966 s
[INFO] Finished at: 2018-11-30T17:00:25-08:00
[INFO] Final Memory: 20M/237M
[INFO] ------------------------------------------------------------------------
```

The output JAR library resides in the ```/target/``` folder.
Please move the JAR files in this folder to ```Software/MATLAB/lib/jar```.
