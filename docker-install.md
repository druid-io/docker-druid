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

[build druid-docker](README.md)
