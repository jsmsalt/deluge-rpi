#!/bin/sh

docker login && \
docker build . -t deluge-rpi --no-cache && \
docker tag deluge-rpi jsmsalt/deluge-rpi:latest && \
docker push jsmsalt/deluge-rpi:latest