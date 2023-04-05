FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:7.4.10-3
RUN /bin/sh -c 'nohup $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -b 0.0.0.0  > /dev/null &' && \
    sleep 10 && \
    cd /tmp && \
    curl --location --output ojdbc8.jar --url https://download.oracle.com/otn-pub/otn_software/jdbc/1918/ojdbc8.jar && \
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="module add --name=com.oracle --resources=ojdbc8.jar --dependencies=javax.api,javax.transaction.api" && \
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name=oracle.jdbc.driver.OracleDriver)" && \
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=oracleXA:add(driver-name="oracleXA",driver-module-name="com.oracle",driver-xa-datasource-class-name=oracle.jdbc.xa.client.OracleXADataSource)"