ML_CONTIANER_USERNAME="docker"
ML_IMAGE_NAME="my_ml_dev"
ML_CONTIANER_NAME="ml_container"
ML_CONTIANER_NAME=$ML_CONTIANER_NAME\_$(docker ps -a --format '{{.Names}}' | grep "^$ML_CONTIANER_NAME" | wc -l)
SOURCE_CODE_DIR="github"
PROJECT="DaytaBase"

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

# Launch the container
docker run -it --rm \
    --name ${ML_CONTIANER_NAME} \
    --hostname ${ML_CONTIANER_NAME} \
    --runtime nvidia \
    --device /dev/video0:/dev/video0 \
    --device /dev/video1:/dev/video1 \
    -h ${ML_CONTIANER_NAME} \
    -e QT_X11_NO_MITSHM=1 \
    -e DISPLAY=unix${DISPLAY} \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${HOME}/${SOURCE_CODE_DIR}:/home/${ML_CONTIANER_USERNAME}/${SOURCE_CODE_DIR} \
    ${ML_IMAGE_NAME} bash