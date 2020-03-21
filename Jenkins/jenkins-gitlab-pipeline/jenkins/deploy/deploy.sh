#!/bin/bash

DOCKER_USER="douglasqsantos"
PROD_SERVER="192.168.0.53"
PROD_USER="prod-user"
PROD_KEY="/opt/prod"

echo maven-project > /tmp/.auth
echo $BUILD_TAG >> /tmp/.auth
echo $DOCKER_USER >> /tmp/.auth
echo $DOCKER_PASS >> /tmp/.auth


ssh -i $PROD_KEY -oStrictHostKeyChecking=no $PROD_USER@$PROD_SERVER "[ ! -d '~/maven' ] && mkdir -p ~/maven"
scp -i $PROD_KEY -oStrictHostKeyChecking=no /tmp/.auth $PROD_USER@$PROD_SERVER:/tmp/.auth
scp -i $PROD_KEY -oStrictHostKeyChecking=no jenkins/deploy/docker-compose.yml $PROD_USER@$PROD_SERVER:~/maven/docker-compose.yml
scp -i $PROD_KEY -oStrictHostKeyChecking=no jenkins/deploy/publish.sh $PROD_USER@$PROD_SERVER:/tmp/publish.sh
ssh -i $PROD_KEY -oStrictHostKeyChecking=no $PROD_USER@$PROD_SERVER "bash /tmp/publish.sh && docker logs -f maven-app"
