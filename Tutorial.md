# Tutorial

## Install Docker (Mac)

[Install Homebrew](http://brew.sh/#install)

```sh
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
```

[Install Cask](http://caskroom.io/)

```sh
brew install caskroom/cask/brew-cask
```

Install Virtualbox

```sh
brew update
brew cask install virtualbox
```

Boot2Docker

```sh
brew update
brew install boot2docker
boot2docker init
boot2docker up
eval "$(boot2docker shellinit)"
```

Is it running?

```
docker info
```

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

Assuming `boot2docker ip` returns `192.168.59.103`, you should be able to
   - access the coordinator console at: http://192.168.59.103:3001/
   - list data-sources on the broker http://192.168.59.103:3000/druid/v2/datasources
