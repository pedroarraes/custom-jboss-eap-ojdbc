# How to customize  Red Hat JBoss EAP image to install Oracle JDBC Drivers
This smart-start describes how create a a custom JBoss EAP image and install Oracle JDBC drivers. For this tutorial we used a Red Hat Container Image, you need a Runtimes Subscription to execute, but, as a alternative you can use a Wildfly Community Image, not supported to Red Hat.

## Requeriments
* Red Hat Subscription
* podman
* VSCode or any text editor

## Summary
* [Registry Aut](#building-an-application)
* [Running JBoss EAP](#running-jboss-eap)
    * [Deploying this example](#deploying-this-example)
    * [Inspecting application logs](#inspecting-application-logs)
* [Understanding LOG configuration](#understanding-log-configuration)
    * [Servlet Example](#servlet-example)
    * [File logging.properties](#file-logging.properties)
    * [Using JBoss EAP System Properties](#using-jboss-eap-system-properties)

## Authentication on Red Hat Registry Image
To pull Red Hat JBoss EAP image is necessary be authenticated. To login at registry use podman.
```bash
$ podman login -u <your-user> registry.redhat.io
```
```console
Password: 
Login Succeeded!
```

## Building custom image image
To build custom image use podman
```bash
$ cd custom-jboss-eap-ojdbc/
$ podman build . -t jboss74-ojdbc:v1
```
```console
STEP 1/2: FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:7.4.10-3
Trying to pull registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:7.4.10-3...
Getting image source signatures
Checking if image destination supports signatures
Copying blob 4015a8249bc6 done  
Copying blob c4877503c8d2 done  
Copying config be2dbd5abd done  
Writing manifest to image destination
Storing signatures
STEP 2/2: RUN /bin/sh -c 'nohup $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -b 0.0.0.0  > /dev/null &' &&     sleep 10 &&     cd /tmp &&     curl --location --output ojdbc8.jar --url https://download.oracle.com/otn-pub/otn_software/jdbc/1918/ojdbc8.jar &&     $JBOSS_HOME/bin/jboss-cli.sh --connect --command="module add --name=com.oracle --resources=ojdbc8.jar --dependencies=javax.api,javax.transaction.api" &&     $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name=oracle.jdbc.driver.OracleDriver)" &&     $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=oracleXA:add(driver-name="oracleXA",driver-module-name="com.oracle",driver-xa-datasource-class-name=oracle.jdbc.xa.client.OracleXADataSource)" &&     rm ojdbc8.jar
Formatter ##CONSOLE-FORMATTER## is not defined
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.wildfly.extension.elytron.SSLDefinitions (jar:file:/opt/jboss/container/wildfly/s2i/galleon/galleon-m2-repository/org/wildfly/core/wildfly-elytron-integration/15.0.25.Final-redhat-00001/wildfly-elytron-integration-15.0.25.Final-redhat-00001.jar!/) to method com.sun.net.ssl.internal.ssl.Provider.isFIPS()
WARNING: Please consider reporting this to the maintainers of org.wildfly.extension.elytron.SSLDefinitions
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   443  100   443    0     0    305      0  0:00:01  0:00:01 --:--:--   848
100 4383k  100 4383k    0     0  1544k      0  0:00:02  0:00:02 --:--:-- 4714k
{"outcome" => "success"}
{"outcome" => "success"}
COMMIT jboss74-ojdbc:v1
--> 66856731bf0
Successfully tagged localhost/jboss74-ojdbc:v1
66856731bf0ed8c0b0685aae998a72ceef22d9039df4546999881a04f67e903f
```
```bash
$ podman images
```
```console
REPOSITORY                                                      TAG         IMAGE ID      CREATED         SIZE
localhost/jboss74-ojdbc                                         v1          66856731bf0e  58 seconds ago  1.04 GB
registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8  7.4.10-3    be2dbd5abda1  2 weeks ago     1 GB
```
## Undertanding Containerfile
Above containerfile.
```dockerfile
FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:7.4.10-3 (1)
RUN /bin/sh -c 'nohup $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -b 0.0.0.0  > /dev/null &' && \ (2)
    sleep 10 && \ (3)
    cd /tmp && \
    curl --location --output ojdbc8.jar --url https://download.oracle.com/otn-pub/otn_software/jdbc/1918/ojdbc8.jar && \ (4)
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="module add --name=com.oracle --resources=ojdbc8.jar --dependencies=javax.api,javax.transaction.api" && \ (5)
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name=oracle.jdbc.driver.OracleDriver)" && \ (6)
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=oracleXA:add(driver-name="oracleXA",driver-module-name="com.oracle",driver-xa-datasource-class-name=oracle.jdbc.xa.client.OracleXADataSource)" && \ (7)
    rm ojdbc8.jar
```