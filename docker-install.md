# Tutorial

## Install Docker (Mac)

[Install Homebrew](http://brew.sh/#install)

```sh
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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

Docker Machine

```sh
brew update
brew install docker-machine docker
docker-machine create --driver virtualbox default
eval "$(docker-machine env default)"
```

Is it working?

```
docker run hello-world
```

[build druid-docker](README.md)
