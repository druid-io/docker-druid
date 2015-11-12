# Dockerfile for Druid

[Install Docker](docker-install.md)

## Build Druid Docker Image

```sh
git clone https://github.com/druid-io/docker-druid.git
docker build -t docker-druid docker-druid
```

## Run a simple Druid cluster

```sh
docker run --rm -i -p 3000:8082 -p 3001:8081 -p 3090:8090 docker-druid
```

Wait a minute or so for the Druid to download the sample data an start up.

## Check if things work

### on OS X

Assuming your default docker machine is called `default` and `docker-machine ip default` returns `192.168.99.100`, you should be able to
   - access the coordinator console http://192.168.99.100:3001/
   - list data-sources on the broker http://192.168.99.100:3000/druid/v2/datasources

### On Linux

   - access the coordinator console http://localhost:3001/
   - list data-sources on the broker http://localhost:3000/druid/v2/datasources
