#!/bin/bash

#cd docker
#docker build -t packerbuilder .
#cd ../packer
cd packer
docker run -v $PWD:/mnt --privileged -it packerbuilder /mnt/buildimage.sh
