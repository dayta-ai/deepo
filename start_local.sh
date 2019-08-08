#!/bin/bash

# User defined variables
DEVELOPER_NAME="" # set your name when multiple developers using same linux user account
SOURCE_CODE_DIR="github"
PROJECT="DaytaBase"
GPU="0" # set GPU device, separate ids by,
JUPYTER_PORT=8888

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


# Copy project requirements.txt to context
cp ${HOME}/${SOURCE_CODE_DIR}/${PROJECT}/requirements.txt ./requirements.txt

# Build the image
docker build \
    -t ${ML_IMAGE_NAME} \
    --build-arg USERNAME=${ML_CONTAINER_USERNAME} \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    --build-arg REQUIREMENTS=requirements.txt .

rm ./requirements.txt

#check number of camera device
NUM_CAM=$(ls -dl /dev/video* | grep '^c' | wc -l)

# Launch the container
if [ $NUM_CAM = 2 ]
then
    docker run -it --rm \
        --name ${ML_CONTAINER_NAME} \
        --hostname ${ML_CONTAINER_NAME} \
        --runtime nvidia \
        --device /dev/video0:/dev/video0 \
        --device /dev/video1:/dev/video1 \
        -h ${ML_CONTAINER_NAME} \
        -e QT_X11_NO_MITSHM=1 \
        -e DISPLAY=unix${DISPLAY} \
        -e CUDA_VISIBLE_DEVICES=${GPU} \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
        -v ${HOME}/.cache/torch/checkpoints:/home/${ML_CONTAINER_USERNAME}/.cache/torch/checkpoints \
        -p ${JUPYTER_PORT}:8888 \
        -w /home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR}/${PROJECT}  \
        ${ML_IMAGE_NAME} bash
elif [ $NUM_CAM = 1 ]
then
    docker run -it --rm \
        --name ${ML_CONTAINER_NAME} \
        --hostname ${ML_CONTAINER_NAME} \
        --runtime nvidia \
        --device /dev/video0:/dev/video0 \
        -h ${ML_CONTAINER_NAME} \
        -e QT_X11_NO_MITSHM=1 \
        -e DISPLAY=unix${DISPLAY} \
        -e CUDA_VISIBLE_DEVICES=${GPU} \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
        -v ${HOME}/.cache/torch/checkpoints:/home/${ML_CONTAINER_USERNAME}/.cache/torch/checkpoints \
        -p ${JUPYTER_PORT}:8888 \
        -w /home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR}/${PROJECT} \
        ${ML_IMAGE_NAME} bash    
else
    docker run -it --rm \
        --name ${ML_CONTAINER_NAME} \
        --hostname ${ML_CONTAINER_NAME} \
        --runtime nvidia \
        -h ${ML_CONTAINER_NAME} \
        -e QT_X11_NO_MITSHM=1 \
        -e DISPLAY=unix${DISPLAY} \
        -e CUDA_VISIBLE_DEVICES=${GPU} \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
        -v ${HOME}/.cache/torch/checkpoints:/home/${ML_CONTAINER_USERNAME}/.cache/torch/checkpoints \
        -p ${JUPYTER_PORT}:8888 \
        -w /home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR}/${PROJECT}  \
        ${ML_IMAGE_NAME} bash
fi