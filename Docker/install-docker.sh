#!/bin/bash
#-------------------------------------------------------------------------
# install-docker.sh
#
# Site	: https://github.com/douglasqsantos/DevOps
# Author : Douglas Q. dos Santos <douglas.q.santos@gmail.com>
# Management: Douglas Q. dos Santos <douglas.q.santos@gmail.com>
#
#-------------------------------------------------------------------------
# Note: The Script install the Docker and Docker Compose for:
# CentOS 7/Debian 9-10/Ubuntu 16.04-19.04/Fedora 28-29
#-------------------------------------------------------------------------
# History:
#
# Version 1:
# Data: 11/10/2019
# Description: Set up Docker and Docker Compose for CentOS 7
#
# Version 2:
# Data: 13/10/2019
# Description: Set up Docker and Docker Compose for:
# CentOS 7/Debian 9-10/Ubuntu 16.04-19.04/Fedora 28-29
#
#--------------------------------------------------------------------------
#License: https://github.com/douglasqsantos/DevOps/blob/master/LICENSE
#
#--------------------------------------------------------------------------
clear

### COLORS
RED="\033[01;31m"
GREEN="\033[01;32m"
YELLOW="\033[01;33m"
WHITE="\033[01;37m"
CLOSE="\033[m"

# Global Variables
DOCKER_COMPOSE_VERSION="1.24.1"

## Functions to check
__check_ok(){
  is_ok=$1
  [ ! -z "$2" ] && msg=$2
  if [ "${is_ok}" != "0" ]; then
    if [ -z "${msg}" ]; then
      msg_erro "CHECK > There was an error in the command execution. Stopping..."
    else
      msg_erro "CHECK > ${msg}"
    fi
    exit 0
  fi
}

# Functions to show messages 
msg_cab(){
  echo -e "${RED}[${CLOSE}${WHITE}$(date +%d/%m/%y) - $(date +%H:%M:%S)${CLOSE}${RED}] Docker${CLOSE} ${WHITE}>${CLOSE}"
}

### Show error messages
msg_error(){
  MSG="${MSG_SECTION} ${1}"
  [ ! -z "${MSG}" ] && echo -e "$(msg_cab)${RED} ${MSG} ${CLOSE}" >&2 ; exit 1
}

### Show success messages
msg_ok(){
  MSG="${MSG_SECTION} ${1}"
  [ ! -z "${MSG}" ] && echo -e "$(msg_cab)${GREEN} ${MSG} ${CLOSE}" >&2
}

### Show warning messages
msg_warn(){
  MSG="${MSG_SECTION} ${1}"
  [ ! -z "${MSG}" ] && echo -e "$(msg_cab)${YELLOW} ${MSG} ${CLOSE}" >&2
}

### Get the OS Version
if [ -f "/etc/debian_version" ]; then
  DEB_VARIANT=$(lsb_release -i | awk '{print $3}')
  if [ "${DEB_VARIANT}" == "Debian" ]; then
    DISTNAME="debian"
    DISTVER=$(lsb_release -r | awk '{print $2}')
    if [ "${DISTVER}" -lt "9" ]; then
      msg_error "CHECK_VERSION > This version of Debian are not supported by this script..."
    fi 
  elif [ "${DEB_VARIANT}" == "Ubuntu" ]; then
    DISTNAME="ubuntu"
    DISTVER=$(lsb_release -r | awk '{print $2}')
    if [ "${DISTVER:0:2}" -lt "16" ]; then
      msg_error "CHECK_VERSION > This version of Debian are not supported by this script..."
    fi 
  fi
  DOCKERCLI="/usr/bin/docker"
elif [ -f "/etc/redhat-release" ]; then
  CENTOS_VER=$(cat /etc/redhat-release | awk '{ print $4 }' | cut -d "." -f 1)
  DOCKERCLI="/bin/docker"
fi


__install_on_centos(){
  MSG_SECTION="Centos ${CENTOS_VER} > "
  ## Removing the old docker packages
  msg_ok "Removing the old docker packages"
  yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

  ## Installing the dependences
  msg_ok "Installing the dependences"
  yum install -y yum-utils device-mapper-persistent-data lvm2 vim wget

  ## Installing the Docker Repository
  msg_ok "Installing the Docker Repository"
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  ## Installing the Docker Pakages
  msg_ok "Installing the Docker Pakages"
  yum install -y docker-ce docker-ce-cli containerd.io
}

__install_on_debian_variants(){
   MSG_SECTION="${DEB_VARIANT} ${DISTVER} > "
  ## Removing the old docker packages
  msg_ok "Removing the old docker packages"
  apt-get -y remove docker docker-engine docker.io containerd runc

  # Updating the repositories 
  msg_ok "Updating the repositories"
  apt-get update

  ## Installing the dependences
  msg_ok "Installing the dependences"
  apt-get install -y apt-transport-https ca-certificates curl gnupg2 gnupg-agent software-properties-common

  ## Adding the gpg key for the docker repository 
  msg_ok "Adding the gpg key for the docker repository"
  curl -fsSL https://download.docker.com/linux/${DISTNAME}/gpg | apt-key add -

  ## Installing the Docker Repository
  msg_ok "Installing the Docker Repository"
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${DISTNAME} $(lsb_release -cs) stable"

  # Updating the repositories 
  msg_ok "Updating the repositories"
  apt-get update

  ## Installing the Docker Pakages
  msg_ok "Installing the Docker Pakages"
  apt-get install -y docker-ce docker-ce-cli containerd.io
}

## Install on CentOS
[ -f "/etc/redhat-release" ] && __install_on_centos

## Install on Debian 
[ -f "/etc/debian_version" ] && __install_on_debian_variants

## Check if docker was installed
if [ -a "${DOCKERCLI}" ]; then
  ## Enabling Docker on boot time
  msg_ok "Enabling Docker on boot time"
  systemctl enable docker

  ## Starting Docker
  msg_ok "Starting Docker"
  systemctl start docker

  ## Getting the docker-compose
  msg_ok "Docker-Compose > Getting the docker-compose"
  curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

  if [ -f "/usr/local/bin/docker-compose" ]; then
    ## Setting the permission
    msg_ok "Docker-Compose > Getting the docker-compose"
    chmod +x /usr/local/bin/docker-compose

    ## Creating the link
    msg_ok "Docker-Compose > Creating the link"
    if [ ! -L "/usr/bin/docker-compose" ]; then
      ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    else 
      msg_warn "Docker-Compose > Updating the link"
      rm -f /usr/bin/docker-compose
      ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
  else
    msg_error "Docker-Compose > Error > docker-compose was not downloaded. Please check your internet connection"
  fi

  # Backup the vimrc if exists
  msg_ok "VIM > Backup the vimrc if exists"
  [ -f "~/.vimrc" ] && mv ~/.vimrc ~/.vimrc.bkp

  ## Getting the vim configuration
  msg_ok "VIM > Getting the vim configuration"
  curl -L https://raw.githubusercontent.com/douglasqsantos/DevOps/master/Misc/vimrc -o ~/.vimrc

  ## Validating if the download is empty or not
  if [ -s "~/.vimrc" ]; then
    msg_warn "VIM > Rollback the vim configuration"
    mv ~/.vimrc ~/.vimrc.bkp2
    if [ -f "~/.vimrc.bkp" ]; then
      mv ~/.vimrc.bkp ~/.vimrc
    fi
  fi

  ## Sending information about a not root user
  msg_ok "If you are using the Docker with your own user added it to the docker group"
  msg_warn "Use: usermod -aG docker douglas"
else
  msg_error "Docker was not installed. Please Check the logs..."
fi