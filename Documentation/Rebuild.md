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
[INFO] Building MATLAB Interface for Avro 0.2
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ matlab-avro-sdk ---
[INFO] Deleting /opt/Pilotwork/Avro/Software/Java/target
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ matlab-avro-sdk ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /opt/Pilotwork/Avro/Software/Java/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.2:compile (default-compile) @ matlab-avro-sdk ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 3 source files to /opt/Pilotwork/Avro/Software/Java/target/classes
[INFO] /opt/Pilotwork/Avro/Software/Java/src/main/java/com/mathworks/bigdata/avro/Reader.java: /opt/Pilotwork/Avro/Software/Java/src/main/java/com/mathworks/bigdata/avro/Reader.java uses unchecked or unsafe operations.
[INFO] /opt/Pilotwork/Avro/Software/Java/src/main/java/com/mathworks/bigdata/avro/Reader.java: Recompile with -Xlint:unchecked for details.
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ matlab-avro-sdk ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /opt/Pilotwork/Avro/Software/Java/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.2:testCompile (default-testCompile) @ matlab-avro-sdk ---
[INFO] No sources to compile
[INFO]
[INFO] --- maven-surefire-plugin:2.17:test (default-test) @ matlab-avro-sdk ---
[INFO] No tests to run.
[INFO]
[INFO] --- maven-jar-plugin:3.1.1:jar (default-jar) @ matlab-avro-sdk ---
[INFO] Building jar: /opt/Pilotwork/Avro/Software/MATLAB/lib/jar/matlab-avro-sdk-0.2.jar
[INFO]
[INFO] --- maven-shade-plugin:3.2.1:shade (default) @ matlab-avro-sdk ---
[INFO] Including org.apache.avro:avro:jar:1.8.2 in the shaded jar.
[INFO] Including org.codehaus.jackson:jackson-core-asl:jar:1.9.13 in the shaded jar.
[INFO] Including org.codehaus.jackson:jackson-mapper-asl:jar:1.9.13 in the shaded jar.
[INFO] Including com.thoughtworks.paranamer:paranamer:jar:2.7 in the shaded jar.
[INFO] Including org.xerial.snappy:snappy-java:jar:1.1.1.3 in the shaded jar.
[INFO] Including org.apache.commons:commons-compress:jar:1.8.1 in the shaded jar.
[INFO] Including org.tukaani:xz:jar:1.5 in the shaded jar.
[INFO] Including org.slf4j:slf4j-api:jar:1.7.7 in the shaded jar.
[INFO] Including org.apache.avro:avro-mapred:jar:1.8.2 in the shaded jar.
[INFO] Including org.apache.avro:avro-ipc:jar:1.8.2 in the shaded jar.
[INFO] Including org.mortbay.jetty:jetty:jar:6.1.26 in the shaded jar.
[INFO] Including org.mortbay.jetty:jetty-util:jar:6.1.26 in the shaded jar.
[INFO] Including org.apache.velocity:velocity:jar:1.7 in the shaded jar.
[INFO] Including commons-lang:commons-lang:jar:2.4 in the shaded jar.
[INFO] Including org.mortbay.jetty:servlet-api:jar:2.5-20081211 in the shaded jar.
[INFO] Including commons-codec:commons-codec:jar:1.9 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-common:jar:3.2.0 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-annotations:jar:3.2.0 in the shaded jar.
[INFO] Including com.google.guava:guava:jar:11.0.2 in the shaded jar.
[INFO] Including commons-cli:commons-cli:jar:1.2 in the shaded jar.
[INFO] Including org.apache.commons:commons-math3:jar:3.1.1 in the shaded jar.
[INFO] Including org.apache.httpcomponents:httpclient:jar:4.5.2 in the shaded jar.
[INFO] Including org.apache.httpcomponents:httpcore:jar:4.4.4 in the shaded jar.
[INFO] Including commons-io:commons-io:jar:2.5 in the shaded jar.
[INFO] Including commons-net:commons-net:jar:3.6 in the shaded jar.
[INFO] Including commons-collections:commons-collections:jar:3.2.2 in the shaded jar.
[INFO] Excluding javax.servlet:javax.servlet-api:jar:3.1.0 from the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-server:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-http:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-io:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-util:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-servlet:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-security:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-webapp:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-xml:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including javax.servlet.jsp:jsp-api:jar:2.1 in the shaded jar.
[INFO] Including com.sun.jersey:jersey-core:jar:1.19 in the shaded jar.
[INFO] Including javax.ws.rs:jsr311-api:jar:1.1.1 in the shaded jar.
[INFO] Including com.sun.jersey:jersey-servlet:jar:1.19 in the shaded jar.
[INFO] Including com.sun.jersey:jersey-json:jar:1.19 in the shaded jar.
[INFO] Including org.codehaus.jettison:jettison:jar:1.1 in the shaded jar.
[INFO] Including com.sun.xml.bind:jaxb-impl:jar:2.2.3-1 in the shaded jar.
[INFO] Including org.codehaus.jackson:jackson-jaxrs:jar:1.9.2 in the shaded jar.
[INFO] Including org.codehaus.jackson:jackson-xc:jar:1.9.2 in the shaded jar.
[INFO] Including com.sun.jersey:jersey-server:jar:1.19 in the shaded jar.
[INFO] Including commons-logging:commons-logging:jar:1.1.3 in the shaded jar.
[INFO] Including log4j:log4j:jar:1.2.17 in the shaded jar.
[INFO] Including commons-beanutils:commons-beanutils:jar:1.9.3 in the shaded jar.
[INFO] Including org.apache.commons:commons-configuration2:jar:2.1.1 in the shaded jar.
[INFO] Including org.apache.commons:commons-lang3:jar:3.7 in the shaded jar.
[INFO] Including org.apache.commons:commons-text:jar:1.4 in the shaded jar.
[INFO] Including org.slf4j:slf4j-log4j12:jar:1.7.25 in the shaded jar.
[INFO] Including com.google.re2j:re2j:jar:1.1 in the shaded jar.
[INFO] Including com.google.protobuf:protobuf-java:jar:2.5.0 in the shaded jar.
[INFO] Including com.google.code.gson:gson:jar:2.2.4 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-auth:jar:3.2.0 in the shaded jar.
[INFO] Including com.nimbusds:nimbus-jose-jwt:jar:4.41.1 in the shaded jar.
[INFO] Including com.github.stephenc.jcip:jcip-annotations:jar:1.0-1 in the shaded jar.
[INFO] Including net.minidev:json-smart:jar:2.3 in the shaded jar.
[INFO] Including net.minidev:accessors-smart:jar:1.2 in the shaded jar.
[INFO] Including org.ow2.asm:asm:jar:5.0.4 in the shaded jar.
[INFO] Including org.apache.curator:curator-framework:jar:2.12.0 in the shaded jar.
[INFO] Including com.jcraft:jsch:jar:0.1.54 in the shaded jar.
[INFO] Including org.apache.curator:curator-client:jar:2.12.0 in the shaded jar.
[INFO] Including org.apache.curator:curator-recipes:jar:2.12.0 in the shaded jar.
[INFO] Including com.google.code.findbugs:jsr305:jar:3.0.0 in the shaded jar.
[INFO] Including org.apache.htrace:htrace-core4:jar:4.1.0-incubating in the shaded jar.
[INFO] Including org.apache.zookeeper:zookeeper:jar:3.4.13 in the shaded jar.
[INFO] Including jline:jline:jar:0.9.94 in the shaded jar.
[INFO] Including org.apache.yetus:audience-annotations:jar:0.5.0 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-simplekdc:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-client:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerby-config:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-core:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerby-pkix:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerby-asn1:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerby-util:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-common:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-crypto:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-util:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:token-provider:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-admin:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-server:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerb-identity:jar:1.0.1 in the shaded jar.
[INFO] Including org.apache.kerby:kerby-xdr:jar:1.0.1 in the shaded jar.
[INFO] Including com.fasterxml.jackson.core:jackson-databind:jar:2.9.5 in the shaded jar.
[INFO] Including com.fasterxml.jackson.core:jackson-annotations:jar:2.9.0 in the shaded jar.
[INFO] Including com.fasterxml.jackson.core:jackson-core:jar:2.9.5 in the shaded jar.
[INFO] Including org.codehaus.woodstox:stax2-api:jar:3.1.4 in the shaded jar.
[INFO] Including dnsjava:dnsjava:jar:2.1.7 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-hdfs:jar:3.2.0 in the shaded jar.
[INFO] Including org.eclipse.jetty:jetty-util-ajax:jar:9.3.24.v20180605 in the shaded jar.
[INFO] Including commons-daemon:commons-daemon:jar:1.0.13 in the shaded jar.
[INFO] Including io.netty:netty:jar:3.10.5.Final in the shaded jar.
[INFO] Including io.netty:netty-all:jar:4.0.52.Final in the shaded jar.
[INFO] Including org.fusesource.leveldbjni:leveldbjni-all:jar:1.8 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-client:jar:3.2.0 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-hdfs-client:jar:3.2.0 in the shaded jar.
[INFO] Including com.squareup.okhttp:okhttp:jar:2.7.5 in the shaded jar.
[INFO] Including com.squareup.okio:okio:jar:1.6.0 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-yarn-api:jar:3.2.0 in the shaded jar.
[INFO] Including javax.xml.bind:jaxb-api:jar:2.2.11 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-yarn-client:jar:3.2.0 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-mapreduce-client-core:jar:3.2.0 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-yarn-common:jar:3.2.0 in the shaded jar.
[INFO] Including com.sun.jersey:jersey-client:jar:1.19 in the shaded jar.
[INFO] Including com.fasterxml.jackson.module:jackson-module-jaxb-annotations:jar:2.9.5 in the shaded jar.
[INFO] Including com.fasterxml.jackson.jaxrs:jackson-jaxrs-json-provider:jar:2.9.5 in the shaded jar.
[INFO] Including com.fasterxml.jackson.jaxrs:jackson-jaxrs-base:jar:2.9.5 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-mapreduce-client-jobclient:jar:3.2.0 in the shaded jar.
[INFO] Including org.apache.hadoop:hadoop-mapreduce-client-common:jar:3.2.0 in the shaded jar.
[INFO] Including com.fasterxml.woodstox:woodstox-core:jar:5.2.0 in the shaded jar.
[INFO] Replacing original artifact with shaded artifact.
[INFO] Replacing /opt/Pilotwork/Avro/Software/MATLAB/lib/jar/matlab-avro-sdk-0.2.jar with /opt/Pilotwork/Avro/Software/Java/target/matlab-avro-sdk-0.2-shaded.jar
[INFO] Dependency-reduced POM written at: /opt/Pilotwork/Avro/Software/Java/dependency-reduced-pom.xml
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 11.846 s
[INFO] Finished at: 2019-04-25T13:01:21-04:00
[INFO] Final Memory: 61M/1866M
[INFO] ------------------------------------------------------------------------
```

The output JAR library resides in the ```/target/``` folder.
Please move the JAR files in this folder to ```Software/MATLAB/lib/jar```.
