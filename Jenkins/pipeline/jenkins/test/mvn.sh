#!/bin/bash

echo "**************************"
echo "**** Testing the Code ****"
echo "**************************"


docker run --rm -v $PWD/java-app:/app -v /root/.m2:/root/.m2 -w /app maven:3-alpine "$@"
