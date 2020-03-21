#!/bin/bash


echo "*****************************"
echo "****** Pushing image ********"
echo "*****************************"

DOCKER_IMAGE="maven-project"
DOCKER_USER="douglasqsantos"

echo "*** Logging in ***"
docker login -u $DOCKER_USER -p $DOCKER_PASS

echo "*** Tagging image ***"
docker tag $DOCKER_IMAGE:$BUILD_TAG $DOCKER_USER/$DOCKER_IMAGE:$BUILD_TAG

echo "*** Pushing Image ***"
docker push $DOCKER_USER/$DOCKER_IMAGE:$BUILD_TAG
