#!/bin/sh
ML_CONTIANER_DISPLAY="0"
ML_CONTIANER_USERNAME="docker"
ML_IMAGE_NAME="my_ml_dev"
ML_CONTIANER_HOSTNAME="ml_container"
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
    --build-arg USERNAME=${ML_CONTIANER_USERNAME} \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    --build-arg REQUIREMENTS=requirements.txt .

rm ./requirements.txt

# Extract current authentication cookie
AUTH_COOKIE=$(xauth list | grep "^$(hostname):${DISPLAY_NUMBER} " | awk '{print $3}')

# Create the new X Authority file
xauth -v -f .display_${DISPLAY_NUMBER}/Xauthority add ${ML_CONTIANER_HOSTNAME}/unix:${ML_CONTIANER_DISPLAY} MIT-MAGIC-COOKIE-1 ${AUTH_COOKIE}

# Proxy with the :0 DISPLAY
socat -d -d -d TCP4:localhost:60${DISPLAY_NUMBER} UNIX-LISTEN:.display_${DISPLAY_NUMBER}/socket/X${ML_CONTIANER_DISPLAY} > socat.log 2>&1 &

# Launch the container
docker run -it --rm \
    --name ${ML_CONTIANER_HOSTNAME} \
    -h ${ML_CONTIANER_HOSTNAME} \
    --runtime nvidia \
    -e QT_X11_NO_MITSHM=1 \
    -e DISPLAY=:${ML_CONTIANER_DISPLAY} \
    -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTIANER_USERNAME}/${SOURCE_CODE_DIR} \
    -v /dev/video0:/dev/video0 \
    -v /dev/video1:/dev/video1 \
    -v ${PWD}/.display_${DISPLAY_NUMBER}/socket:/tmp/.X11-unix \
    -v ${PWD}/.display_${DISPLAY_NUMBER}/Xauthority:/home/${ML_CONTIANER_USERNAME}/.Xauthority \
    --hostname ${ML_CONTIANER_HOSTNAME} \
    ${ML_IMAGE_NAME} bash
