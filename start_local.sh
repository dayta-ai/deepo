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
SOURCE_CODE_DIR="github"
PROJECT="DaytaBase"

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
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
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
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
        ${ML_IMAGE_NAME} bash    
else
    docker run -it --rm \
        --name ${ML_CONTAINER_NAME} \
        --hostname ${ML_CONTAINER_NAME} \
        --runtime nvidia \
        -h ${ML_CONTAINER_NAME} \
        -e QT_X11_NO_MITSHM=1 \
        -e DISPLAY=unix${DISPLAY} \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/${SOURCE_CODE_DIR} \
        ${ML_IMAGE_NAME} bash
fi