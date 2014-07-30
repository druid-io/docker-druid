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
export DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375
```

Is it running?

```
docker info
```

Build Base image

```sh
cd base
docker build -t druid/base .
```

## Build Druid Docker Image

Build Coordinator image

```sh
cd ../coordinator
docker build -t druid/coordinator .
```

## Run Druid

```sh
docker run -i --rm -p 3000:8080 -t druid/coordinator
```

Assuming `boot2docker ip` returns `192.168.59.103`, you should be able to access the coordinator console at: http://192.168.59.103:3000/
