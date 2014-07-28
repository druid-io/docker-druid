# Tutorial

## Install Docker (Mac)

[Install Homebrew](http://brew.sh/#install)

```sh
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
```

Virtualbox

```sh
brew tap caskroom/cask
brew install brew-cask
brew cask install virtualbox
```

Boot2Docker

```sh
brew install boot2docker
boot2docker init
boot2docker up
export DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375
```

Is it running?

```
docker info
```

# Run Druid

Build Druid image

```sh
docker build -t druid/coordinator .
```

Run Druid

```sh
docker run -t druid/coordinator
```
