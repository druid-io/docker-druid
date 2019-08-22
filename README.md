[![Build Status](https://travis-ci.org/Fokko/docker-druid.svg?branch=master)](https://travis-ci.org/Fokko/docker-druid)

# Apache Druid (Incubating) Docker Image

[Install Docker](https://docs.docker.com/install/)

## Run a simple Apache Druid (Incubating) cluster

Download and launch the docker image:
```sh
docker pull druidio/example-cluster
docker run --rm -i -p 8888:8888 druidio/example-cluster
```

Once the cluster has started, you can navigate to [http://localhost:8888](http://localhost:8888). The [Druid router process](../development/router.html), which serves the Druid console, resides at this address.

## Build Druid Docker Image

To build the docker image yourself

```sh
git clone https://github.com/druid-io/docker-druid.git
cd docker-druid
docker build -t docker-druid .
docker run --rm -i -p 8888:8888 docker-druid
```

## Logging

You might want to look into the logs when debugging the Druid processes. This can be done by logging into the container using `docker ps`:
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                           NAMES
5782c4d4fa40        docker-druid        "/bin/sh -c ./bin/st…"   4 seconds ago       Up 3 seconds        2181/tcp, 2888/tcp, 3888/tcp, 8081-8083/tcp, 8090/tcp, 0.0.0.0:8888->8888/tcp   angry_banach
```

Run the `docker logs` command to fetch the logs.

```
$ docker logs -f 5782c4d4fa40
[Wed Aug  7 09:22:41 2019] Running command[zk], logging to[/opt/druid/var/sv/zk.log]: bin/run-zk conf
[Wed Aug  7 09:22:41 2019] Running command[coordinator-overlord], logging to[/opt/druid/var/sv/coordinator-overlord.log]: bin/run-druid coordinator-overlord conf/druid/single-server/micro-quickstart
[Wed Aug  7 09:22:41 2019] Running command[broker], logging to[/opt/druid/var/sv/broker.log]: bin/run-druid broker conf/druid/single-server/micro-quickstart
[Wed Aug  7 09:22:41 2019] Running command[router], logging to[/opt/druid/var/sv/router.log]: bin/run-druid router conf/druid/single-server/micro-quickstart
[Wed Aug  7 09:22:41 2019] Running command[historical], logging to[/opt/druid/var/sv/historical.log]: bin/run-druid historical conf/druid/single-server/micro-quickstart
[Wed Aug  7 09:22:41 2019] Running command[middleManager], logging to[/opt/druid/var/sv/middleManager.log]: bin/run-druid middleManager conf/druid/single-server/micro-quickstart
```

## Troubleshooting

This section will help you troubleshoot problems related to the Dockerized Druid.

### Out-Of-Memory (OOM) when using OSX

When using Docker on OSX, the Docker environment will be executed within the [HyperKit](https://github.com/docker/hyperkit) hypervisor, a lightweight visualization framework for running the Docker containers:
```
docker-druid foobar$ ps -ax | grep docker.hyperkit
71175 ??         0:04.02 /Applications/Docker.app/Contents/MacOS/com.docker.hyperkit -A -m 2048M -c 4 -u -s ...
```

The allocated resources are limited by default to 2 cpu's and 2gb of memory. Although 2gb is sufficient in most application, the Druid container is rather heavyweight because of the Mysql, Zookeeper and the JVM's. When start spawning additional JVM's, for example an indexing job, this might cause issues:
```
2017-01-20T15:59:58,445 INFO [forking-task-runner-0-[index_transactions_2017-01-20T15:59:50.637Z]] io.druid.indexing.overlord.ForkingTaskRunner - Process exited with status[137] for task: index_transactions_2017-01-20T15:59:50.637Z
```
From the log we observe that the process receives an 137 (=128+9) SIGKILL signal. Because it hit the memory limit, the application is killed instantly. To avoid this you might want to give more resources to the Docker hypervisor under Docker > Preferences.