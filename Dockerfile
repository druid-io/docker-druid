FROM openjdk:8

ENV DRUID_VERSION 0.15.1-incubating
ENV ZOOKEEPER_VERSION 3.4.14

# Get Druid
RUN mkdir -p /tmp \
    && cd /tmp/ \
    && curl -fsLS "https://www.apache.org/dyn/closer.cgi?filename=/incubator/druid/$DRUID_VERSION/apache-druid-$DRUID_VERSION-bin.tar.gz&action=download" | tar xvz \
    && mv apache-druid-$DRUID_VERSION /opt/druid

WORKDIR /opt/druid/

# Zookeeper
RUN curl -fsLS "https://www.apache.org/dyn/closer.cgi?filename=/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz&action=download" | tar xvz \
    && mv zookeeper-$ZOOKEEPER_VERSION zk

RUN bash -c "./bin/start-micro-quickstart &" && \
    ./bin/post-index-task --file quickstart/tutorial/wikipedia-index.json --url http://localhost:8081 --submit-timeout 600

# Expose ports:
# - 8888: HTTP (router)
# - 8081: HTTP (coordinator)
# - 8082: HTTP (broker)
# - 8083: HTTP (historical)
# - 8090: HTTP (overlord)
# - 2181 2888 3888: ZooKeeper
EXPOSE 8888
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 8090
EXPOSE 2181 2888 3888

ENTRYPOINT ./bin/start-micro-quickstart
