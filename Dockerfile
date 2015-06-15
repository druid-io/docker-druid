FROM ubuntu:14.04

# Add Java 8 repository
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:webupd8team/java \
      && apt-get update

# Oracle Java 8, MySQL, Supervisor, Git
RUN echo oracle-java-8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
      && apt-get install -y oracle-java8-installer oracle-java8-set-default mysql-server supervisor git curl

# Maven
RUN wget -q -O - http://archive.apache.org/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz | tar -xzf - -C /usr/local \
      && ln -s /usr/local/apache-maven-3.2.5 /usr/local/apache-maven \
      && ln -s /usr/local/apache-maven/bin/mvn /usr/local/bin/mvn

# Zookeeper
RUN wget -q -O - http://www.us.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -xzf - -C /usr/local \
      && cp /usr/local/zookeeper-3.4.6/conf/zoo_sample.cfg /usr/local/zookeeper-3.4.6/conf/zoo.cfg \
      && ln -s /usr/local/zookeeper-3.4.6 /usr/local/zookeeper

# Druid system user
RUN adduser --system --group --no-create-home druid \
      && mkdir -p /var/lib/druid/log \
      && chown druid:druid /var/lib/druid

# Pre-cache Druid dependencies (this step is optional, but can help speed up re-building the Docker image)
#RUN mvn dependency:get -Dartifact=io.druid:druid-services:0.7.1.1


# Druid (from source)
RUN mkdir -p /usr/local/druid/lib /usr/local/druid/repository
# trigger rebuild only if branch changed
ADD https://api.github.com/repos/metamx/druid/git/refs/heads/master druid-version.json
RUN git clone -q --branch master --depth 1 https://github.com/metamx/druid.git /tmp/druid
WORKDIR /tmp/druid
# package and install Druid locally
RUN mvn -U -B clean install -DskipTests=true -Dmaven.javadoc.skip=true \
  && cp services/target/druid-services-0.8.0-SNAPSHOT-selfcontained.jar /usr/local/druid/lib

# pull dependencies for Druid extensions

RUN /bin/bash -c 'java "-Ddruid.extensions.coordinates=[\"io.druid.extensions:druid-s3-extensions\",\"io.druid.extensions:mysql-metadata-storage\", \"io.druid.extensions:druid-kafka-eight\"]" -Ddruid.extensions.localRepository=/usr/local/druid/repository -Ddruid.extensions.remoteRepositories=[\"file:///root/.m2/repository/\",\"https://repo1.maven.org/maven2/\"] -cp /usr/local/druid/lib/* io.druid.cli.Main tools pull-deps'

#
## Setup metadata store
RUN /bin/bash -c "/etc/init.d/mysql start && mysql -e \"GRANT ALL ON druid.* TO 'druid'@'localhost' IDENTIFIED BY 'diurd'; CREATE database druid CHARACTER SET utf8;\" && /etc/init.d/mysql stop"
#
# Add sample data
RUN /bin/bash -c '/etc/init.d/mysql start && java -cp /usr/local/druid/lib/druid-services-*-selfcontained.jar -Ddruid.extensions.coordinates=[\"io.druid.extensions:mysql-metadata-storage\"] -Ddruid.metadata.storage.type=mysql io.druid.cli.Main tools metadata-init --connectURI="jdbc:mysql://localhost:3306/druid" --user=druid --password=diurd && /etc/init.d/mysql stop'

ADD sample-data.sql /tmp/sample-data.sql
RUN /etc/init.d/mysql start && cat /tmp/sample-data.sql | mysql -u root druid && /etc/init.d/mysql stop

## Setup supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

## Clean up
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*
RUN chown -R druid:druid /usr/local/druid
## Expose ports:
## - 8081: HTTP (coordinator)
## - 8082: HTTP (broker)
## - 8083: HTTP (historical)
## - 3306: MySQL
## - 2181 2888 3888: ZooKeeper
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 3306
EXPOSE 2181 2888 3888

WORKDIR /var/lib/druid
