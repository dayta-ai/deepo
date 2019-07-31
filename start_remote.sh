#!/bin/sh
ML_CONTAINER_DISPLAY="0"
ML_CONTAINER_USERNAME="docker"
ML_IMAGE_NAME="my_ml_dev"
ML_CONTAINER_NAME="ml_container"
CURRENT_INDEX=$(docker ps -a --format '{{.Names}}' | \
              grep "^$ML_CONTAINER_NAME" | \
              sed -e "s/^$ML_CONTAINER_NAME\_//" | \
              sort -r | head -n 1)
if [ -z "$CURRENT_INDEX" ]
then
    CURRENT_INDEX=0
else
    CURRENT_INDEX=$((CURRENT_INDEX+1))
fi
ML_CONTAINER_NAME=$ML_CONTAINER_NAME\_$CURRENT_INDEX
echo $ML_CONTAINER_NAME
SOURCE_CODE_DIR="github"
PROJECT="DaytaBase"

# Get the DISPLAY slot
DISPLAY_NUMBER=$(echo $DISPLAY | cut -d. -f1 | cut -d: -f2)

# Remove and create a directory for the x11 socket
rm -rf .display_${DISPLAY_NUMBER}
mkdir -p .display_${DISPLAY_NUMBER}/socket
touch .display_${DISPLAY_NUMBER}/Xauthority

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

# Extract current authentication cookie
AUTH_COOKIE=$(xauth list | grep "^$(hostname):${DISPLAY_NUMBER} " | awk '{print $3}')
if [ -z "$AUTH_COOKIE" ]
then
    AUTH_COOKIE=$(xauth list | grep "^$(hostname)/unix:${DISPLAY_NUMBER} " | awk '{print $3}')
fi
echo $AUTH_COOKIE

# Create the new X Authority file
xauth -v -f .display_${DISPLAY_NUMBER}/Xauthority add ${ML_CONTAINER_NAME}/unix:${ML_CONTAINER_DISPLAY} MIT-MAGIC-COOKIE-1 ${AUTH_COOKIE}

# Proxy with the :0 DISPLAY
socat -d -d -d TCP4:localhost:60${DISPLAY_NUMBER} UNIX-LISTEN:.display_${DISPLAY_NUMBER}/socket/X${ML_CONTAINER_DISPLAY} > socat.log 2>&1 &

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
        -e DISPLAY=:${ML_CONTAINER_DISPLAY} \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
        -v ${HOME}/.cache/torch/checkpoints:/home/${ML_CONTAINER_USERNAME}/.cache/torch/checkpoints \
        -v ${PWD}/.display_${DISPLAY_NUMBER}/socket:/tmp/.X11-unix \
        -v ${PWD}/.display_${DISPLAY_NUMBER}/Xauthority:/home/${ML_CONTAINER_USERNAME}/.Xauthority \
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
        -e DISPLAY=:${ML_CONTAINER_DISPLAY} \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
        -v ${HOME}/.cache/torch/checkpoints:/home/${ML_CONTAINER_USERNAME}/.cache/torch/checkpoints \
        -v ${PWD}/.display_${DISPLAY_NUMBER}/socket:/tmp/.X11-unix \
        -v ${PWD}/.display_${DISPLAY_NUMBER}/Xauthority:/home/${ML_CONTAINER_USERNAME}/.Xauthority \
        ${ML_IMAGE_NAME} bash
else
    docker run -it --rm \
        --name ${ML_CONTAINER_NAME} \
        --hostname ${ML_CONTAINER_NAME} \
        --runtime nvidia \
        -h ${ML_CONTAINER_NAME} \
        -e QT_X11_NO_MITSHM=1 \
        -e DISPLAY=:${ML_CONTAINER_DISPLAY} \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
        -v ${HOME}/.cache/torch/checkpoints:/home/${ML_CONTAINER_USERNAME}/.cache/torch/checkpoints \
        -v ${PWD}/.display_${DISPLAY_NUMBER}/socket:/tmp/.X11-unix \
        -v ${PWD}/.display_${DISPLAY_NUMBER}/Xauthority:/home/${ML_CONTAINER_USERNAME}/.Xauthority \
        ${ML_IMAGE_NAME} bash
fi                