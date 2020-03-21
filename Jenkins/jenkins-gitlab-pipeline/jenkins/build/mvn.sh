#!/bin/bash

echo "**************************"
echo "**** Building Jar ********"
echo "**************************"

# The full path to the workspace outside of the jenkins container.
WORKSPACE="/DevOps/Jenkins/jenkins_data/workspace/pipeline-docker-maven"

docker run --rm -v $WORKSPACE/java-app:/app -v /root/.m2:/root/.m2 -w /app maven:3-alpine "$@"
