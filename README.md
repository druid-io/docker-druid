# Deploy Druid Cluster with Docker

For an all-in-one Docker container(all Druid services running in one single container), look at [here](all-in-one/README.md)

### Prerequisites:
1. Install docker and docker-machine on you development machine
1. Register a docker hub account if you don't have one. You are going to need to pull and push your docker images from there
1. Install Jinja2 using pip  
  `$ pip install jinja2`
1. For Mac OSX users only: install virtualbox

### Directories:
1. `templates/scripts` has all the templates for docker management scripts:  
  - `build-all.sh.template`: the script to build all images and push to docker hub
  - `build-conf.sh.template`: the script to build only the image that contains conf files
  - `provision.sh.template`: the script to provision nodes
  - `deploy.sh.template`: the script to deploy all nodes
1. `templates/dockerfiles` has all the Dockerfile templates that define images
1. `templates/conf` has all the configuration templates for druid nodes
1. When running `pre_build.py`, the Dockerfile templates and conf file templates will read `config.json` and render into `generated/`
  **Always remember to change template files instead of those in the `generated/` directory as those will be overwritten once you run `pre_build.py`**

### Usage:
1. For Mac OSX users only: Create a docker-machine dedicated for building images and setting up environment  
  `$ docker-machine create --driver virtualbox local && eval $(docker-machine env local)`
1. Change `config.json` accordingly
1. Prebuild  
  `$ python pre_build.py`
1. Run `$ ./provision.sh` to provision nodes
1. Build images accordingly by running either `build-all.sh` or `build-conf.sh`  
1. Run `$ ./deploy.sh`

### Container Lifecycle management:
1. To see the status of all containers, run `$ eval $(docker-machine env --swarm d-druid-swarm-master) && docker ps -a`

### Notes:
1. To switch docker-machine, run `$ eval $(docker-machine env <the machine name>)`.   
  To switch to the swarm master, run `$ eval $(docker-machine env --swarm <the swarm master machine name>)`
1. To attach a new session to a running container, run `docker exec -it <container_name> /bin/bash`
1. To view the logs for a druid node, run `docker logs <container_name>`, or attach a new session and go to the actual log path to view the logs.
