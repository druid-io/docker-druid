FROM ubuntu:16.04

# Set version and github repo which you want to build from
ENV GITHUB_OWNER druid-io
ENV DRUID_VERSION 0.12.0
ENV ZOOKEEPER_VERSION 3.4.12

# Java 8
RUN apt-get update \
      && apt-get install -y software-properties-common \
      && apt-add-repository -y ppa:webupd8team/java \
      && apt-get purge --auto-remove -y software-properties-common \
      && apt-get update \
      && echo oracle-java-8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
      && apt-get install -y oracle-java8-installer oracle-java8-set-default \
                            postgresql postgresql-contrib \
                            supervisor \
                            git \
                            python-pip \
      && apt-get clean \
      && rm -rf /var/cache/oracle-jdk8-installer \
      && rm -rf /var/lib/apt/lists/*

# Maven
RUN wget -q -O - http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar -xzf - -C /usr/local \
      && ln -s /usr/local/apache-maven-3.3.9 /usr/local/apache-maven \
      && ln -s /usr/local/apache-maven/bin/mvn /usr/local/bin/mvn

# Zookeeper
RUN wget -q -O - http://www.us.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xzf - -C /usr/local \
      && cp /usr/local/zookeeper-$ZOOKEEPER_VERSION/conf/zoo_sample.cfg /usr/local/zookeeper-$ZOOKEEPER_VERSION/conf/zoo.cfg \
      && ln -s /usr/local/zookeeper-$ZOOKEEPER_VERSION /usr/local/zookeeper

# Druid system user
RUN adduser --system --group --no-create-home druid \
      && mkdir -p /var/lib/druid \
      && chown druid:druid /var/lib/druid && \
    adduser --system --group --no-create-home postgresql \
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
            /root/.m2

WORKDIR /

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER druid WITH SUPERUSER PASSWORD 'diurd';" &&\
    createdb -O druid druid

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

USER root

# Setup metadata store
RUN /etc/init.d/postgresql start \
      && java -cp /usr/local/druid/lib/druid-services-*-selfcontained.jar \
          -Ddruid.extensions.directory=/usr/local/druid/extensions \
          -Ddruid.extensions.loadList=[\"postgresql-metadata-storage\"] \
          -Ddruid.metadata.storage.type=postgresql \
          io.druid.cli.Main tools metadata-init \
              --connectURI="jdbc:postgresql://localhost:5432/druid" \
              --user=druid --password=diurd \
      && /etc/init.d/postgresql stop

# Setup supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports:
# - 8081: HTTP (coordinator)
# - 8082: HTTP (broker)
# - 8083: HTTP (historical)
# - 8090: HTTP (overlord)
# - 5432: Postgresql
# - 2181 2888 3888: ZooKeeper
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 8090
EXPOSE 3306
EXPOSE 2181 2888 3888

# Mount the data inside of the container
ADD ./ingestion/ /ingestion/

WORKDIR /var/lib/druid

# Create directories used for storing the segments
# Start Druid, and run an ingestion job, wait until the job is done and data is a available, then shut Druid down
RUN mkdir -p /tmp/druid/localStorage/ \
 && chown druid:druid /tmp/druid/localStorage/ \
 && cat /etc/supervisor/conf.d/supervisord.conf | sed 's/nodaemon=true/nodaemon=false/g' > /tmp/supervisord-no-deamon.conf \
 && export HOSTIP="$(hostname -i)" && /usr/bin/supervisord -c /tmp/supervisord-no-deamon.conf \
 && pip install -r /ingestion/requirements.txt \
 && /ingestion/provision.py --file /ingestion/wikiticker-index.json \
 && supervisorctl -c /etc/supervisor/conf.d/supervisord.conf shutdown


CMD export HOSTIP="$(hostname -i)" && exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
