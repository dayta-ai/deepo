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

3. Clone the repo
```bash
git clone https://github.com/dayta-ai/deepo.git
```
4. Check variables in start.sh
    1. Put your projects(code) in ```bash~/github``` folder or change the variable SOURCE_CODE_DIR
    2. Check if PROJECT variable is set to your desire project name

### Prerequisite (Client)

1. Install [XQuartz](https://www.xquartz.org/) (For Mac only)

### How to use it in headless mode(TLDR)
1. add execution permission to start_local.sh
```bash
cd deepo
chmod u+x start_local.sh
```
2. Build docker image and run the container, the container will be removed after you exit from bash
```bash
./start_local.sh
```

### How to use it locally with GUI(TLDR)
1. add execution permission to start_local.sh
```bash
cd deepo
chmod u+x start_local.sh
```
2. Build docker image and run the container, the container will be removed after you exit from bash
```bash
./start_local.sh
```
### How to use it remotely with GUI(TLDR)
1. ssh to your remote workstation with x11 forwarding flags
```bash
ssh -XY my_workstation
```
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
1. ubuntu 18.04
2. cuda 10.0 and cudnn 7
3. python 3.7
4. opencv with ffmpeg support
5. pytorch 1.1 & apex
6. jupyer
7. tensorflow 1.14 & keras
8. mxnet
9. sklearn
10. onnx
11. vim and nano

#### Update base image
```bash
docker pull dayta/ml_developmen:latest
```

#### Build your own base image (Optional)
Please follow the guide from original deepo repo
```bash
cd generator
python generate.py Dockerfile python==3.7 pytorch==1.1 apex jupyter tensorflow==1.14 keras onnx opencv sklearn pylint mxnet --ubuntu-ver 18.04 --cuda-ver 10.0 --cudnn-ver 7
docker build -t daytabase/ml_development .
```

### Other info
1. Container name

The suffix of container name indicate the index of container, you can multiple containers at the same time by run start.sh multiple times. ~~To do: make container index incremental~~

2. User password

The default password is docker, feel free to change it in the outer Dockerfile

3. Webcam

~~Currently you have to add --privileged argument to docker run command in start.sh in order to use webcam~~
Updated: no privileged is needed to access webcam from container

### Reference
1. [Running a graphical app in a Docker container, on a remote server](https://blog.yadutaf.fr/2017/09/10/running-a-graphical-app-in-a-docker-container-on-a-remote-server/)
2. [Docker tutorial](https://github.com/dayta-ai/Resource/tree/master/docker/tutorial)
3. [Running a Container With a Non Root User](https://medium.com/better-programming/running-a-container-with-a-non-root-user-e35830d1f42a)
4. [Docker — using webcam](https://medium.com/@zwinny/docker-using-webcam-9fafb26cf1e6)

