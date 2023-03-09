#!/bin/bash

# This bash script is part of the COSItools setup procedure.
# It is licenced under the Apache 2.0 license
#
# Development lead: Andreas Zoglauer
#
# Description:
# This script creates and launches the COSItools docker.
# It assumes that you can run docker without sudo.
#

# Check if docker is installed
type docker >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "Error: Cannot find docker"
  exit 1
fi

# Check if the docker daemon is running and accessible as user
STATUS=$(docker info 2>&1)
if [[ ${STATUS} == *ERROR* ]]; then
  if [[ ${STATUS} == *Cannot\ connect\ to\ the\ Docker\ daemon* ]]; then
    echo "Error: The docker daemon is not running"
    exit 1;
  fi

  if [[ ${STATUS} == *permission\ denied* ]]; then
    echo "Error: The docker daemon requires sudo, please set it up to not require sudo"
    exit 1;
  fi

  # Unknown error
  echo "Error: Something is up with docker:"
  docker info
  exit 1
fi


# Check if we need to rebuild the docker
echo "Checking if container rebuild is required"
docker build -t cosi-main - < Dockerfile


# Setup the exchange directory
EXCHANGE_DIRECTORY="${HOME}/COSIDockerData"
if [[ ! -d ${EXCHANGE_DIRECTORY} ]]; then 
  mkdir ${EXCHANGE_DIRECTORY}
fi


# Run docker
echo ""
echo ""
echo "Starting up docker, please wait..."
echo ""
if [[ $(uname -a) == *inux* ]]; then
  XSOCK=/tmp/.X11-unix.${USER}
  XAUTH=/tmp/.docker.xauth.${USER}
  xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -
  docker run -v ${EXCHANGE_DIRECTORY}:/home/cosi/COSIDockerData -e DISPLAY=${DISPLAY} -v ${XSOCK}:${XSOCK} -v ${XAUTH}:${XAUTH} --net=host -e USERID=`id -u ${USER}` -e GROUPID=`id -g ${USER}` -it cosi-main
elif [[ $(uname -a) == *arwin* ]]; then
  XSOCK=/tmp/.X11-unix.${USER}
  YOUR_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }')
  xhost +${YOUR_IP}
  docker run -v ${EXCHANGE_DIRECTORY}:/home/cosi/COSIDockerData -e DISPLAY=${YOUR_IP}:0 -v ${XSOCK}:${XSOCK} -it cosi-main
else
  echo "Unsupported OS"
fi

