# Druid Docker Image

## Run a simple Druid cluster

[Install Docker](docker-install.md)

Download and launch the docker image

```sh
docker pull druidio/example-cluster
docker run --rm -i -p 3000:8082 -p 3001:8081 -p 3090:8090 druidio/example-cluster
```

Wait a minute or so for Druid to start up and download the sample.

On OS X

- List datasources

```
curl http://$(docker-machine ip default):3000/druid/v2/datasources
```

- access the coordinator console

```
open http://$(docker-machine ip default):3001/
```

On Linux

- List datasources

```
curl http://localhost:3000/druid/v2/datasources
```

- access the coordinator console at http://localhost:3001/

## Build Druid Docker Image

To build the docker image yourself

```sh
git clone https://github.com/druid-io/docker-druid.git
docker build -t example-cluster docker-druid
```

## Logging

You might want to look into the logs when debugging the Druid processes. This can be done by logging into the container using `docker ps`:
```
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                                                                                                      NAMES
9e73cbfc5612        druidio/example-cluster   "/bin/sh -c 'export H"   7 seconds ago       Up 6 seconds        2181/tcp, 2888/tcp, 3306/tcp, 3888/tcp, 8083/tcp, 0.0.0.0:3001->8081/tcp, 0.0.0.0:3000->8082/tcp, 0.0.0.0:3090->8090/tcp   sick_lamport
```

And attaching to the container using `docker exec -ti 9e73cbfc5612 bash` logs are written to 
`/tmp/`:

```
root@d59a3d4a68c3:/tmp# ls -lah        
total 224K
drwxrwxrwt  8 root   root   4.0K Jan 18 20:38 .
drwxr-xr-x 61 root   root   4.0K Jan 18 20:38 ..
-rw-------  1 root   root      0 Jan 18 20:38 druid-broker-stderr---supervisor-az6WwP.log
-rw-------  1 root   root    18K Jan 18 20:39 druid-broker-stdout---supervisor-D28zOC.log
-rw-------  1 root   root      0 Jan 18 20:38 druid-coordinator-stderr---supervisor-RYMt5L.log
-rw-------  1 root   root   100K Jan 18 21:14 druid-coordinator-stdout---supervisor-Jq4WCi.log
-rw-------  1 root   root      0 Jan 18 20:38 druid-historical-stderr---supervisor-rmMHmF.log
-rw-------  1 root   root    18K Jan 18 20:39 druid-historical-stdout---supervisor-AJ0SZX.log
-rw-------  1 root   root   7.9K Jan 18 21:09 druid-indexing-service-stderr---supervisor-x3YNlo.log
-rw-------  1 root   root    28K Jan 18 21:14 druid-indexing-service-stdout---supervisor-5uyV7u.log
-rw-------  1 root   root    155 Jan 18 20:38 mysql-stderr---supervisor-NqN9nY.log
-rw-------  1 root   root    153 Jan 18 20:38 mysql-stdout---supervisor-23izTf.log
-rw-------  1 root   root     78 Jan 18 20:38 zookeeper-stderr---supervisor-Rm33j8.log
-rw-------  1 root   root   7.4K Jan 18 20:39 zookeeper-stdout---supervisor-6AFVOR.log
```



