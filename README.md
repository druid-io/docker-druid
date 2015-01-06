# Dockerfile for Druid

## Install Docker

[Install Docker](docker-install.md)


## Build Druid Docker Image

Build Druid image

```sh
git clone https://github.com/druid-io/docker-druid.git
cd docker-druid
```

```sh
docker build -t druid/cluster .
```

## Run Druid

```sh
docker run --rm -i -p 3000:8082 -p 3001:8081 druid/cluster
```

Wait a minute or so for the Druid to download the sample data an start up.

## Check if things work

### When running Docker on OS X

Assuming `boot2docker ip` returns `192.168.59.103`, you should be able to
   - access the coordinator console at: http://192.168.59.103:3001/
   - list data-sources on the broker http://192.168.59.103:3000/druid/v2/datasources

### On Linux

   - access the coordinator console at: http://localhost:3001/
   - list data-sources on the broker http://localhost:3000/druid/v2/datasources
