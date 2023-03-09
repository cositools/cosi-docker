#!/bin/bash

if [[ $( sudo docker ps -a | grep cosi-main) == "" ]]; then
  echo "Rebuilding docker"
  sudo docker build -t cosi-main - < Dockerfile 
fi

EXCHANGE_DIRECTORY=${COSITOOLSDIR}
if [[ ${EXCHANGE_DIRECTORY} == "" ]]; then 
  EXCHANGE_DIRECTORY="~${USER}"
fi

if [[ $(uname -a) == *inux* ]]; then
  XSOCK=/tmp/.X11-unix.${USER}
  XAUTH=/tmp/.docker.xauth.${USER}
  xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -
  sudo docker run -v ${EXCHANGE_DIRECTORY}:/home/cosi/exchange -e DISPLAY=${DISPLAY} -v ${XSOCK}:${XSOCK} -v ${XAUTH}:${XAUTH} --net=host -e USERID=`id -u ${USER}` -e GROUPID=`id -g ${USER}` -it cosi-main
elif [[ $(uname -a) == *arwin* ]]; then
  YOUR_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }'); echo "Your IP: ${YOUR_IP}"
  xhost +${YOUR_IP}
  docker run --rm -it -v ${EXCHANGE_DIRECTORY}:/home/cosi/exchange -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=${YOUR_IP}:0  cosi-main
else
  echo "Unsupported OS"
fi
