# Dockerfile for Druid

[Install Docker](docker-install.md)

## Build Druid Docker Image

```sh
git clone https://github.com/druid-io/docker-druid.git
docker build -t druid/cluster docker-druid
```

## Run a simple Druid cluster

```sh
docker run --rm -i -p 3000:8082 -p 3001:8081 druid/cluster
```

Wait a minute or so for the Druid to download the sample data an start up.

## Check if things work

### on OS X

Assuming `boot2docker ip` returns `192.168.59.103`, you should be able to
   - access the coordinator console http://192.168.59.103:3001/
   - list data-sources on the broker http://192.168.59.103:3000/druid/v2/datasources

### On Linux

   - access the coordinator console http://localhost:3001/
   - list data-sources on the broker http://localhost:3000/druid/v2/datasources
