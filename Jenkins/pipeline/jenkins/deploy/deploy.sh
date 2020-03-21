#!/bin/bash

echo maven-project > /tmp/.auth
echo $BUILD_TAG >> /tmp/.auth
echo $DOCKER_USER >> /tmp/.auth
echo $DOCKER_PASS >> /tmp/.auth

scp -i jenkins/deploy/key /tmp/.auth prod-user@prod-server:/tmp/.auth
scp -i jenkins/deploy/key jenkins/deploy/publish.sh prod-user@prod-server:/tmp/publish.sh
ssh -i jenkins/deploy/key prod-user@prod-server "bash /tmp/publish.sh && docker logs -f maven-app"
