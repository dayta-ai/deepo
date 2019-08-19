#!/bin/bash

help(){
    printf "script usage: $(basename $0) [-d name] [-s dir] [-p project] [-g IDs] [-j port] \n \
    -d name : Name of developer(container username) (required) \n \
    -s dir : Root path of source code (default: ~/github) \n \
    -p project : Project name (directory) (default: DaytaBase) \n \
    -g IDs : IDs of GPUs which are exposed to container , seperated by comma (default: 0) \n \
    " >&2
    exit 1
}

find_next_available(){
    find_next_available_ret=$1
    checked=false
    shift
    for item in $(printf '%s\n' "$@" | grep '^[0-9]\+$' | sort)
    do
        if [ "$checked" = true ]
        then
            if [ "$find_next_available_ret" = "$item" ]
            then
                ((find_next_available_ret++))
            else
                break            
            fi
        elif [ "$item" = "$find_next_available_ret" ]
        then
            checked=true
            ((find_next_available_ret++))
        fi
    done
}

# Default values
SOURCE_CODE_DIR=${HOME}/github
PROJECT=DaytaBase
GPU=0

# Constants
TENSORBOARD_PORT=6006
JUPYTER_PORT=8888

while getopts 'd:s:p:g:' OPTION; do
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

# Define image name, conatiner name and container username, container display number
ML_CONTAINER_DISPLAY="0"
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
find_next_available 0 $(docker ps -a --format '{{.Names}}' | \
                      grep "^$ML_CONTAINER_NAME" | \
                      sed -e "s/^$ML_CONTAINER_NAME\_//")
CURRENT_INDEX=$find_next_available_ret
ML_CONTAINER_NAME=$ML_CONTAINER_NAME\_$CURRENT_INDEX

# Get the DISPLAY slot
DISPLAY_NUMBER=$(echo $DISPLAY | cut -d. -f1 | cut -d: -f2)

# Remove and create a directory for the x11 socket
rm -rf .display_${DISPLAY_NUMBER}
mkdir -p .display_${DISPLAY_NUMBER}/socket
touch .display_${DISPLAY_NUMBER}/Xauthority

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
    --build-arg REQUIREMENTS=requirements.txt \
    --build-arg INIT_SCRIPT=scripts/init.sh .

rm ./requirements.txt

# Extract current authentication cookie
AUTH_COOKIE=$(xauth list | grep "^$(hostname):${DISPLAY_NUMBER} " | awk '{print $3}')
if [ -z "$AUTH_COOKIE" ]
then
    AUTH_COOKIE=$(xauth list | grep "^$(hostname)/unix:${DISPLAY_NUMBER} " | awk '{print $3}')
fi

# Create the new X Authority file
xauth -v -f .display_${DISPLAY_NUMBER}/Xauthority add ${ML_CONTAINER_NAME}/unix:${ML_CONTAINER_DISPLAY} MIT-MAGIC-COOKIE-1 ${AUTH_COOKIE}

# Proxy with the :0 DISPLAY
socat -d -d -d TCP4:localhost:60${DISPLAY_NUMBER} UNIX-LISTEN:.display_${DISPLAY_NUMBER}/socket/X${ML_CONTAINER_DISPLAY} > socat.log 2>&1 &

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

# Get jupyter port
find_next_available $JUPYTER_PORT $(docker ps --format {{.Ports}} | \
                         tr , '\n' | \
                         awk '{$1=$1};1'| \
                         sed "s/\(.*\)->\(.*\)\/tcp/\2/" )
JUPYTER_PORT=$find_next_available_ret
echo "The Jupyter Notebook is running at: http://localhost:${JUPYTER_PORT}?token=daytaai"

# Get tensorboard port
find_next_available $TENSORBOARD_PORT $(docker ps --format {{.Ports}} | \
                         tr , '\n' | \
                         awk '{$1=$1};1'| \
                         sed "s/\(.*\)->\(.*\)\/tcp/\2/" )
TENSORBOARD_PORT=$find_next_available_ret

# Launch the container
docker run -it --rm \
    --name ${ML_CONTAINER_NAME} \
    --hostname ${ML_CONTAINER_NAME} \
    --runtime nvidia \
    ${CAMS} \
    -h ${ML_CONTAINER_NAME} \
    -e QT_X11_NO_MITSHM=1 \
    -e DISPLAY=:${ML_CONTAINER_DISPLAY} \
    -e CUDA_VISIBLE_DEVICES=${GPU} \
    -e TENSORBOARD_PORT=${TENSORBOARD_PORT} \
    -e JUPYTER_PORT=${JUPYTER_PORT} \
    -v ${SOURCE_CODE_DIR}:/home/${ML_CONTAINER_USERNAME}/workspace \
    -v ${HOME}/.cache/torch/checkpoints:/home/${ML_CONTAINER_USERNAME}/.cache/torch/checkpoints \
    -v ${PWD}/.display_${DISPLAY_NUMBER}/socket:/tmp/.X11-unix \
    -v ${PWD}/.display_${DISPLAY_NUMBER}/Xauthority:/home/${ML_CONTAINER_USERNAME}/.Xauthority \
    ${N_DRIVES} \
    -p ${TENSORBOARD_PORT}:${TENSORBOARD_PORT} \
    -p ${JUPYTER_PORT}:${JUPYTER_PORT} \
    -w /home/${ML_CONTAINER_USERNAME}/workspace/${PROJECT} \
    ${ML_IMAGE_NAME} /home/${ML_CONTAINER_USERNAME}/init.sh