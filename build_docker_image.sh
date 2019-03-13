#!/bin/bash
docker build -t amazon-linux-ffmpeg -f Dockerfile.ffmpeg .
docker create -ti --name amazon-linux-ffmpeg-dummy amazon-linux-ffmpeg bash
docker cp amazon-linux-ffmpeg-dummy:/root/bin.tar ./
docker rm -fv amazon-linux-ffmpeg-dummy
tar -xvf ./bin.tar
rm -rf ./bin.tar