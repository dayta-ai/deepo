This repo is a fork to the modular docker machine learning environment [deepo](https://github.com/ufoym/deepo) which add extra functions include ffmpeg support to opencv, remote server x11 forwarding, better user permission management and more python modules. Keep in mind that not all functions are tested.

### Prerequisite (docker host os)
1. Socat (For remote usage)
```bash
sudo apt install -y socat
```
2. Edit sshd settings (For remote usage)
use your text editor to edit /etc/ssh/sshd_config
set X11Forwarding to yes
set X11UseLocalhost to no


### How to use it (TLDR)
1. Clone the repo
```bash
git clone https://github.com/dayta-ai/deepo.git
```
#### Run container locally
2. add execution permission to start_local.sh
```bash
cd deepo
chmod u+x start_local.sh
```
3. Build docker image and run the container, the container will be removed after you exit from bash
```bash
./start_local.sh
```
#### Run container remotely
2. add execution permission to start_remote.sh
```bash
cd deepo
chmod u+x start_remote.sh
```
3. Build docker image and run the container, the container will be removed after you exit from bash
```bash
./start_remote.sh
```

### Base image
By default, the base docker image is prebuild by us and host by [dockerhub](https://hub.docker.com/r/dayta/ml_development), here are the included libraries and tools
1. python 3.7
2. opencv with ffmpeg support
3. cuda 10.0 and cudnn 7
4. pytorch & apex
5. jupyer
6. tensorflow
7. sklearn
8. onnx
9. vim and nano

#### Use your own base image
Please follow the guide from original deepo repo

### Other info
1. Container name
The suffix of container name indicate the index of container, you can multiple containers at the same time by run start.sh multiple times
2. User password
The default password is docker, feel free to change it in the outer Dockerfile

### Reference
1. [Running a graphical app in a Docker container, on a remote server](https://blog.yadutaf.fr/2017/09/10/running-a-graphical-app-in-a-docker-container-on-a-remote-server/)
2. [Docker tutorial](https://github.com/dayta-ai/Resource/tree/master/docker/tutorial)
3. [Running a Container With a Non Root User](https://medium.com/better-programming/running-a-container-with-a-non-root-user-e35830d1f42a)

