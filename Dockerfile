FROM ubuntu:14.04

# Set version and github repo which you want to build from
ENV GITHUB_OWNER druid-io
ENV DRUID_VERSION 0.9.2
ENV ZOOKEEPER_VERSION 3.4.9

# Java 8
RUN apt-get update \
      && apt-get install -y software-properties-common \
      && apt-add-repository -y ppa:webupd8team/java \
      && apt-get purge --auto-remove -y software-properties-common \
      && apt-get update \
      && echo oracle-java-8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
      && apt-get install -y oracle-java8-installer oracle-java8-set-default \
                            mysql-server \
                            supervisor \
                            git \
      && apt-get clean \
      && rm -rf /var/cache/oracle-jdk8-installer \
      && rm -rf /var/lib/apt/lists/*

# Maven
RUN wget -q -O - http://archive.apache.org/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz | tar -xzf - -C /usr/local \
      && ln -s /usr/local/apache-maven-3.2.5 /usr/local/apache-maven \
      && ln -s /usr/local/apache-maven/bin/mvn /usr/local/bin/mvn

# Zookeeper
RUN wget -q -O - http://www.us.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xzf - -C /usr/local \
      && cp /usr/local/zookeeper-$ZOOKEEPER_VERSION/conf/zoo_sample.cfg /usr/local/zookeeper-$ZOOKEEPER_VERSION/conf/zoo.cfg \
      && ln -s /usr/local/zookeeper-$ZOOKEEPER_VERSION /usr/local/zookeeper

# Druid system user
RUN adduser --system --group --no-create-home druid \
      && mkdir -p /var/lib/druid \
      && chown druid:druid /var/lib/druid

# Druid (from source)
RUN mkdir -p /usr/local/druid/lib

# trigger rebuild only if branch changed
ADD https://api.github.com/repos/$GITHUB_OWNER/druid/git/refs/heads/$DRUID_VERSION druid-version.json
RUN git clone -q --branch $DRUID_VERSION --depth 1 https://github.com/$GITHUB_OWNER/druid.git /tmp/druid
WORKDIR /tmp/druid

# package and install Druid locally
# use versions-maven-plugin 2.1 to work around https://jira.codehaus.org/browse/MVERSIONS-285
RUN mvn -U -B org.codehaus.mojo:versions-maven-plugin:2.1:set -DgenerateBackupPoms=false -DnewVersion=$DRUID_VERSION \
  && mvn -U -B install -DskipTests=true -Dmaven.javadoc.skip=true \
  && cp services/target/druid-services-$DRUID_VERSION-selfcontained.jar /usr/local/druid/lib \
  && cp -r distribution/target/extensions /usr/local/druid/ \
  && cp -r distribution/target/hadoop-dependencies /usr/local/druid/ \
  && apt-get purge --auto-remove -y git \
  && apt-get clean \
  && rm -rf /tmp/* \
            /var/tmp/* \
            /usr/local/apache-maven-3.2.5 \
            /usr/local/apache-maven \
            /root/.m2

WORKDIR /

# Setup metadata store and add sample data
ADD sample-data.sql sample-data.sql
RUN /etc/init.d/mysql start \
      && mysql -u root -e "GRANT ALL ON druid.* TO 'druid'@'localhost' IDENTIFIED BY 'diurd'; CREATE database druid CHARACTER SET utf8;" \
      && java -cp /usr/local/druid/lib/druid-services-*-selfcontained.jar \
          -Ddruid.extensions.directory=/usr/local/druid/extensions \
          -Ddruid.extensions.loadList=[\"mysql-metadata-storage\"] \
          -Ddruid.metadata.storage.type=mysql \
          io.druid.cli.Main tools metadata-init \
              --connectURI="jdbc:mysql://localhost:3306/druid" \
              --user=druid --password=diurd \
      && mysql -u root druid < sample-data.sql \
      && /etc/init.d/mysql stop

# Setup supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports:
# - 8081: HTTP (coordinator)
# - 8082: HTTP (broker)
# - 8083: HTTP (historical)
# - 8090: HTTP (overlord)
# - 3306: MySQL
# - 2181 2888 3888: ZooKeeper
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 8090
EXPOSE 3306
EXPOSE 2181 2888 3888

WORKDIR /var/lib/druid
ENTRYPOINT export HOSTIP="$(resolveip -s $HOSTNAME)" && exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
