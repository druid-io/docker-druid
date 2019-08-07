FROM openjdk:8

ENV DRUID_VERSION 0.15.0-incubating
ENV ZOOKEEPER_VERSION 3.4.11

# Get Druid
RUN cd /tmp/ && \
    curl -s http://apache.mirror.anlx.net/incubator/druid/$DRUID_VERSION/apache-druid-$DRUID_VERSION-bin.tar.gz | tar xvz && \
    mv apache-druid-$DRUID_VERSION /opt/druid

WORKDIR /opt/druid/

# Zookeeper
RUN curl -s https://archive.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar xvz && \
    mv zookeeper-$ZOOKEEPER_VERSION zk

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