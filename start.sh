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

# Check if the docker daemon is running
STATUS=$(docker info 2>&1)
if [[ ${STATUS} == *ERROR* ]]; then
  if [[ ${STATUS} == *Cannot\ connect\ to\ the\ Docker\ daemon* ]]; then
    echo "Error: The docker daemon is not running"
    exit 1;
  fi

  # Unknown error
  echo "Error: Something is up with docker:"
  docker info
  exit 1
fi

# Check if we can access docker without sudo
if [[ $(uname -s) == *inux* ]]; then
  DOCKERDIR+$(docker info | grep "Docker Root Dir" | awk -F: '{ print $2 }' | xargs)
  echo "Test missing"
fi

# Check if we need to rebuild the docker
if [[ $( docker ps -a | grep cosi-main) == "" ]]; then
  echo "Rebuilding docker"
  docker build -t cosi-main - < Dockerfile
fi

# Setup the exchange directory
EXCHANGE_DIRECTORY=${COSITOOLSDIR}
if [[ ${EXCHANGE_DIRECTORY} == "" ]]; then 
  EXCHANGE_DIRECTORY="~${USER}"
fi

# Run docker
if [[ $(uname -a) == *inux* ]]; then
  XSOCK=/tmp/.X11-unix.${USER}
  XAUTH=/tmp/.docker.xauth.${USER}
  xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -
  docker run -v ${EXCHANGE_DIRECTORY}:/home/cosi/exchange -e DISPLAY=${DISPLAY} -v ${XSOCK}:${XSOCK} -v ${XAUTH}:${XAUTH} --net=host -e USERID=`id -u ${USER}` -e GROUPID=`id -g ${USER}` -it cosi-main
elif [[ $(uname -a) == *arwin* ]]; then
  YOUR_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }'); echo "Your IP: ${YOUR_IP}"
  xhost +${YOUR_IP}
  docker run --rm -it -v ${EXCHANGE_DIRECTORY}:/home/cosi/exchange -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=${YOUR_IP}:0  cosi-main
else
  echo "Unsupported OS"
fi

