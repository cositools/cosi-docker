# Dockerfile for COSItools
# 
# Build the docker with:
# docker build -t cosi-main - < Dockerfile

FROM ubuntu:24.04

MAINTAINER Andreas Zoglauer <zoglauer@berkeley.edu>

# Install all the COSItools prerequisites
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq gosu vim nano less gzip git git-lfs gawk dpkg-dev make g++ gcc gfortran gdb valgrind binutils libx11-dev libxpm-dev libxft-dev libxext-dev libssl-dev libpcre3-dev libglu1-mesa-dev libglew-dev libftgl-dev libmysqlclient-dev libfftw3-dev libgraphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python3 python3-pip python3-dev python3-tk python3-venv libxml2-dev libkrb5-dev libgsl-dev cmake libxmu-dev curl doxygen libblas-dev liblapack-dev expect dos2unix libncurses5-dev libboost-all-dev libcfitsio-dev libxerces-c-dev libhealpix-cxx-dev bc libhdf5-dev python3-matplotlib libbz2-dev

# Add COSI user
RUN groupadd -g 1111 cosi && useradd -u 1111 -g 1111 -ms /bin/bash cosi

# Switch to user cosi
USER cosi

# Setup 
RUN cd /home/cosi && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/cositools/cosi-setup/main/setup.sh)"
RUN echo . /home/cosi/COSItools/source.sh >> /home/cosi/.bashrc

# Create exchange directory
RUN mkdir /home/cosi/COSIDockerData

# Switch back to ROOT
USER root

# Create entry-point script - changes the UID of cosi to the local USER and group for full access to the exchange directory on all machines
RUN    cd /usr/local/bin \
    && echo '#!/bin/bash' >> entrypoint.sh \
    && echo 'if [ "${USERID}" != "" ]; then usermod -u ${USERID} cosi; fi' >> entrypoint.sh \
    && echo 'if [ "${GROUPID}" != "" ]; then groupmod -g ${GROUPID} cosi; fi' >> entrypoint.sh \
    && echo 'if [ "${USERID}" != "" ] || [ "${GROUPID}" != "" ]; then chown -R cosi:cosi /home/cosi; fi' >> entrypoint.sh \
    && echo 'gosu cosi bash' >> entrypoint.sh \
    && chmod a+rx /usr/local/bin/entrypoint.sh

# The working directory is the COSItools directory
WORKDIR /home/cosi/COSIDockerData

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
