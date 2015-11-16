# Druid Docker Image

## Run a simple Druid cluster

[Install Docker](docker-install.md)

Download and launch the docker image

```sh
docker pull druidio/example-cluster
docker run --rm -i -p 3000:8082 -p 3001:8081 -p 3090:8090 example-cluster
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
