FROM druid/base

# Druid system user
RUN adduser --system --group --no-create-home druid
RUN mkdir -p /var/lib/druid
RUN chown druid:druid /var/lib/druid

# Druid (release tarball)
RUN wget -q -O - http://static.druid.io/artifacts/releases/druid-services-0.6.121-bin.tar.gz | tar -xzf - -C /usr/local
RUN ln -s /usr/local/druid-services-0.6.121 /usr/local/druid

# Druid (from source)
#ENV DRUID_VERSION druid-0.6.121
#RUN git clone -q --branch $DRUID_VERSION --depth 1 https://github.com/metamx/druid.git /tmp/druid
#WORKDIR /tmp/druid
#RUN hash=$(git rev-parse --short HEAD); mkdir -p /usr/local/druid-$hash/lib && ln -s /usr/local/druid-$hash /usr/local/druid
#RUN mvn package -DskipTests=true
#RUN cp services/target/druid-services-*-selfcontained.jar /usr/local/druid/lib

# Setup metadata store
RUN /etc/init.d/mysql start && echo "GRANT ALL ON druid.* TO 'druid'@'localhost' IDENTIFIED BY 'diurd'; CREATE database druid;" | mysql -u root && /etc/init.d/mysql stop

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Clean up
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

# Expose ports:
# - 8080: HTTP
# - 3306: MySQL
# - 2181 2888 3888: ZooKeeper
EXPOSE 8080
EXPOSE 3306
EXPOSE 2181 2888 3888

WORKDIR /var/lib/druid
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
