FROM ubuntu:14.04

# Add Java 7 repository
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:webupd8team/java
RUN apt-get update

# Oracle Java 7
RUN echo oracle-java-7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer
RUN apt-get install -y oracle-java7-set-default

# MySQL (Metadata store)
RUN apt-get install -y mysql-server

# Supervisor
RUN apt-get install -y supervisor

# Maven
RUN wget -q -O - http://mirror.olnevhost.net/pub/apache/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.tar.gz | tar -xzf - -C /usr/local
RUN ln -s /usr/local/apache-maven-3.2.1 /usr/local/apache-maven
RUN ln -s /usr/local/apache-maven/bin/mvn /usr/local/bin/mvn

# Zookeeper
RUN wget -q -O - http://apache.mirrors.pair.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -xzf - -C /usr/local
RUN cp /usr/local/zookeeper-3.4.6/conf/zoo_sample.cfg /usr/local/zookeeper-3.4.6/conf/zoo.cfg
RUN ln -s /usr/local/zookeeper-3.4.6 /usr/local/zookeeper

# Druid
RUN wget -q -O - http://static.druid.io/artifacts/releases/druid-services-0.6.121-bin.tar.gz | tar -xzf - -C /usr/local
RUN ln -s /usr/local/druid-services-0.6.121 /usr/local/druid

# Setup metadata store
RUN /etc/init.d/mysql start && echo "GRANT ALL ON druid.* TO 'druid'@'localhost' IDENTIFIED BY 'diurd'; CREATE database druid;" | mysql -u root

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Clean up
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

# Expose ports:
# - 8080: HTTP
# - 3306: MySQL
# - 2181 2888 3888 ZooKeeper
EXPOSE 8080
EXPOSE 3306
EXPOSE 2181 2888 3888

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
