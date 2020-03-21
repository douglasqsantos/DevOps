#!/bin/bash


export DOCKER_IMAGE=$(sed -n '1p' /tmp/.auth)
export DOCKER_TAG=$(sed -n '2p' /tmp/.auth)
export DOCKER_PASS=$(sed -n '4p' /tmp/.auth)
export DOCKER_USER=$(sed -n '3p' /tmp/.auth)

docker login -u $DOCKER_USER -p $DOCKER_PASS

cd ~/maven && docker-compose up -d
