#!/bin/bash
#-------------------------------------------------------------------------
# ConfInicialCentOS6
#
# Site	: https://github.com/douglasqsantos/DevOps
# Author : Douglas Q. dos Santos <douglas.q.santos@gmail.com>
# Management: Douglas Q. dos Santos <douglas.q.santos@gmail.com>
#
#-------------------------------------------------------------------------
# Note: The Script install the Docker and Docker Compose for CentOS 7
#-------------------------------------------------------------------------
# History:
#
# Version 1:
# Data: 11/10/2019
# Description: Set up Docker and Docker Compose for CentOS 7
#
#--------------------------------------------------------------------------
#License: https://github.com/douglasqsantos/DevOps/blob/master/LICENSE
#
#--------------------------------------------------------------------------
clear


## Removing the old docker packages
yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

## Installing the dependences 
yum install -y yum-utils device-mapper-persistent-data lvm2 vim wget

## Installing the Docker Repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

## Installing the Docker Pakages
yum install docker-ce docker-ce-cli containerd.io

## Check if docker was installed
if [ -a "/bin/docker" ]; then
  ## Enabling Docker on boot time 
  systemctl enable docker

  ## Starting Docker 
  systemctl start docker

  ## Getting the docker-compose
  curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

  if [ -f "/usr/local/bin/docker-compose" ]; then
    ## Setting the permission
    chmod +x /usr/local/bin/docker-compose

    ## Creating the link
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  else 
    echo "Error > docker-compose was not downloaded. Please check your internet connection"
  fi

  # Backup the vimrc if exists
  [ -f "~/.vimrc" ] && mv ~/.vimrc ~/.vimrc.bkp

  ## Getting the vim configuration
  wget -c https://raw.githubusercontent.com/douglasqsantos/DevOps/master/Misc/vimrc -O ~/.vimrc

  ## Validating if the download is empty or not
  if [ -s "~/.vimrc" ]; then
    mv ~/.vimrc ~/.vimrc.bkp2
    if [ -f "~/.vimrc.bkp" ]; then
      mv ~/.vimrc.bkp ~/.vimrc
    fi
  fi

  ## Sending information about a not root user
  echo "If you are using the Docker with your own user added it to the docker group"
  echo "Use: usermod -aG docker douglas"
else 
  echo "Docker was not installed. Please Check the logs..." 1
fi


