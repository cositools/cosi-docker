# cosi-docker

This repository contains a Dockerfile to install the COSItools in an Ubuntu docker container.

## Installation:

This installation assumes you have docker installed and configured. Please see the docker documentation on how to do that.
It also assumes you have set it up to run without sudo. On Linux you just have to add the user to the docker group and logout and login again.

Then clone this repository:
```
git clone https://github.com/cositools/cosi-docker
cd cosi-docker
```


## Running it:

### Via start.sh script:

The repository contain a bash script called "start.sh". On Ubuntu and macOS this script will build and start your docker container.
It will also create a directory ~/COSIDockerData, where you can exchange files between your container and your home directory.


### Manually

First create your container via:
```
docker build -t cosi-main - < Dockerfile
```


We assume that you want to keep all you data on your host system and not in your docker container. 
For this tutorial, this directory is named:
```
EXCHANGE_DIRECTORY="${HOME}/COSIDockerData"
```
Please create this directory if it does not yet exist.

How to start up the container and use the UI depends on your OS.

#### Ubuntu and probably most Linux versions::

Perform the following preparations to see X applications:
```
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
```

Then start your docker:
```
docker run -v ${EXCHANGE_DIRECTORY}:/home/cosi/COSIDockerData -e DISPLAY=${DISPLAY} -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH --net=host -e USERID=`id -u ${USER}` -e GROUPID=`id -g ${USER}` -it cosi-main
```

This leaves you in a bash prompt from where you can run any COSItools app.

In some cases, it takes a very long time until the docker images starts. Then you have encountered a bug/inefficiency in Docker's storage driver. You can switch the storage driver to "aufs" to avoid that issue by editing the file /etc/docker/daemon.json. If the file does not yet exist, just create it. If the file is empty, add the following:

```
{ "storage-driver": "aufs" }
```

Restart Docker afterwards.

```
sudo systemctl restart docker
```


#### macOS:

First, make sure the directory, you have chosen to exchange data with, is known to Docker, i.e. in the docker menu, click Preferences, and make sure it is listed under File Sharing.

Second, make sure you have XQuartz installed: <a href="https://www.xquartz.org" target=_blank>https://www.xquartz.org</a>.
When ZQuarts is installed, open it. In the menu, go to Preferences, select the Security tab, and tick the box "Allow connections from network clients". Important: Then restart XQuartz!

Third, find out your IP address. There are many ways to do this. Here is one possibility to do that:
```
  YOUR_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }'); echo "Your IP: ${YOURIP}"
```

You need your IP to enable X11 connections via XQuartz. You do this via:
```
  xhost +${YOUR_IP}
```

Then you are finally ready to launch the docker:
```
  docker run --rm -it -v ${EXCHANGE_DIRECTORY}:/home/cosi/COSIDockerData -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=${YOUR_IP}:0  cosi-main
```

#### Windows:

Make sure you have an Xserver installed, Xming is the one we have tested everything on. Then open a power shell and type (obviously replace "YourComputerNameOrIP" with either your computer's name or IP):

```
&amp; 'C:/Program Files (x86)/Xming/Xming.exe' :0 -ac -clipboard -multiwindow
docker run -v C:/path/to/exchange/directory:/home/cosi/exchange -e DISPLAY=YourComputerNameOrIP:0 -it cosi-main
```



## Start up:

After it has started up, your are in a bash prompt with all the COSItools installed.





