#!/bin/bash

# Copy the new jar to the build location
echo "**************************************"
echo "***** Copying the new Jar ************"
echo "**************************************"
cp -f java-app/target/*.jar  jenkins/build/

# Copy the new jar to the build location
echo "**************************************"
echo "***** Building Docker Image **********"
echo "**************************************"
cd jenkins/build/ && docker-compose -f docker-compose-build.yml build --no-cache

