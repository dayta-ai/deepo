#!/bin/bash

help(){
    printf "script usage: $(basename $0) [-d name] [-s dir] [-p project] [-g IDs] [-j port] \n \
    -d name : Name of developer(container username) (required) \n \
    -s dir : Root path of source code (default: ~/github) \n \
    -p project : Project name (directory) (default: DaytaBase) \n \
    -g IDs : IDs of GPUs which are exposed to container , seperated by comma (default: 0) \n \
    -j port : Port of jupyter notebook (default: 8888) \n \
    " >&2
    exit 1
}

# Default values
SOURCE_CODE_DIR=${HOME}/github
PROJECT=DaytaBase
GPU=0
JUPYTER_PORT=8888

while getopts 'd:s:p:g:j:' OPTION; do
    case "$OPTION" in
    d)
        DEVELOPER_NAME=$OPTARG
        ;;
    s)
        SOURCE_CODE_DIR=$OPTARG
        ;;
    p)
        PROJECT=$OPTARG
        ;;
    g)
        GPU=$OPTARG
        ;;
    j)
        JUPYTER_PORT=$OPTARG
        ;;
    ?)
        help
        ;;
    esac
done

# Check if required argument is provided
if [ -z $DEVELOPER_NAME ]
then
    echo "Missing argument -d name"
    help
fi

# Check if project folder exists
if [ ! -d "${SOURCE_CODE_DIR}/${PROJECT}/" ]
then
    printf "Project folder ${SOURCE_CODE_DIR}/${PROJECT}/ does not exist, please check the arguments \n"
    help
fi

# Define image name, conatiner name and container username
if [ -z "$DEVELOPER_NAME" ]
then
    ML_IMAGE_NAME=$PROJECT\_ENVIRONMENT
    ML_CONTAINER_NAME=$PROJECT
    ML_CONTAINER_USERNAME="docker"
else
    ML_IMAGE_NAME=$DEVELOPER_NAME\_$PROJECT\_ENVIRONMENT
    ML_CONTAINER_NAME=$DEVELOPER_NAME\_$PROJECT
    ML_CONTAINER_USERNAME=$DEVELOPER_NAME
fi
ML_IMAGE_NAME=${ML_IMAGE_NAME,,}

# Add suffix to contain name
CURRENT_INDEX=$(docker ps -a --format '{{.Names}}' | \
              grep "^$ML_CONTAINER_NAME" | \
              sed -e "s/^$ML_CONTAINER_NAME\_//" | \
              sort -r | head -n 1)
if [ -z "$CURRENT_INDEX" ]
then
    CURRENT_INDEX=0
else
    $((CURRENT_INDEX++))
fi
ML_CONTAINER_NAME=$ML_CONTAINER_NAME\_$CURRENT_INDEX


# Copy project requirements.txt to context, if it does not exist, create an empty requirements.txt
if [ -f "${SOURCE_CODE_DIR}/${PROJECT}/requirements.txt" ]
then
    cp ${SOURCE_CODE_DIR}/${PROJECT}/requirements.txt ./requirements.txt
else
    touch ./requirements.txt
fi

# Build the image
docker build \
    -t ${ML_IMAGE_NAME} \
    --build-arg USERNAME=${ML_CONTAINER_USERNAME} \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    --build-arg REQUIREMENTS=requirements.txt .

rm ./requirements.txt

# Get all cameras
CAMS=""
for CAM in /dev/video*
do
    [ -e "$CAM" ] || continue
    CAMS="$CAMS --device $CAM:$CAM"
done
echo "Available cameras: $CAMS"

# Get network drives
N_DRIVES=""
for N_DRIVE in /mnt/network_drive*
do
    [ -e "$N_DRIVE" ] || continue
    N_DRIVES="$N_DRIVES -v $N_DRIVE:$N_DRIVE"
done

# Launch the container
docker run -it --rm \
    --name ${ML_CONTAINER_NAME} \
    --hostname ${ML_CONTAINER_NAME} \
    --runtime nvidia \
    ${CAMS} \
    -h ${ML_CONTAINER_NAME} \
    -e QT_X11_NO_MITSHM=1 \
    -e DISPLAY=unix${DISPLAY} \
    -e CUDA_VISIBLE_DEVICES=${GPU} \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/workspace \
    -v ${HOME}/.cache/torch/checkpoints:/home/${ML_CONTAINER_USERNAME}/.cache/torch/checkpoints \
    ${N_DRIVES} \
    -p ${JUPYTER_PORT}:8888 \
    -w /home/${ML_CONTAINER_USERNAME}/workspace/${PROJECT}  \
    ${ML_IMAGE_NAME} bash