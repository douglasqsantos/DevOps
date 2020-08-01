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
# CentOS 7/Debian 9-10/Ubuntu 16.04-19.04/Fedora 28-30
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
DOCKER_COMPOSE_VERSION="1.26.2"

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
    CHECK_VER=$(echo ${DISTVER} | grep '.')
    [ ! -z "${CHECK_VER}" ] && DISTVER=$(echo ${DISTVER} | cut -d '.' -f 1)
    if [ "${DISTVER}" -lt "9" ]; then
      msg_error "CHECK_VERSION > This version of Debian are not supported by this script..."
    fi
  elif [ "${DEB_VARIANT}" == "Ubuntu" ]; then
    DISTNAME="ubuntu"
    DISTVER=$(lsb_release -r | awk '{print $2}')
    if [ "${DISTVER:0:2}" -lt "16" ]; then
      msg_error "CHECK_VERSION > This version of Ubuntu are not supported by this script..."
    fi 
  fi
  DOCKERCLI="/usr/bin/docker"
elif [ -f "/etc/redhat-release" ]; then
  if [ -f "/etc/fedora-release" ]; then
    REDHAT_VARIANT="Fedora"
    DISTNAME="fedora"
    REPO_MGR="dnf config-manager"
    PGK_MGR="dnf"
    DISTVER=$(cat /etc/fedora-release | awk '{ print $3}')
    DOCKERCLI="/usr/bin/docker"
    if [ "${DISTVER}" -lt "28" ]; then
      msg_error "CHECK_VERSION > This version of Fedora are not supported by this script..."
    fi 
  elif [ -f "/etc/centos-release" ]; then
    REDHAT_VARIANT="CentOS"
    DISTNAME="centos"
    REPO_MGR="yum-config-manager"
    PGK_MGR="yum"
    DISTVER=$(cat /etc/centos-release | awk '{ print $4 }' | cut -d "." -f 1)
    DOCKERCLI="/bin/docker"
    if [ "${DISTVER}" -ne "7" ]; then
      msg_error "CHECK_VERSION > This version of CentOS are not supported by this script..."
    fi 
  fi
fi

## Function to handle the installation on Red Hat Base Systems
__install_on_redhat_variants(){
  MSG_SECTION="${REDHAT_VARIANT} ${DISTVER} > "
  ## Removing the old docker packages
  msg_ok "Removing the old docker packages"
  if [ -f "/etc/centos-release" ]; then
    yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
  else 
    dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
  fi

  ## Installing the dependences
  msg_ok "Installing the dependences"
  if [ -f "/etc/centos-release" ]; then
    yum install -y yum-utils device-mapper-persistent-data lvm2 vim wget bash-completion
  else
    dnf -y install dnf-plugins-core vim bash-completion
  fi

  ## Installing the Docker Repository
  msg_ok "Installing the Docker Repository"
  ${REPO_MGR} --add-repo https://download.docker.com/linux/${DISTNAME}/docker-ce.repo

  ## Installing the Docker Pakages
  msg_ok "Installing the Docker Pakages"
  ${PGK_MGR} install -y docker-ce docker-ce-cli containerd.io
}

## Function to handle the installation on Debian Base Systems
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
  apt-get install -y apt-transport-https ca-certificates curl gnupg2 gnupg-agent software-properties-common vim bash-completion

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
[ -f "/etc/redhat-release" ] && __install_on_redhat_variants

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

  ## Getting the bash_completion for Docker
  msg_ok "Docker > Getting the bash_completion"
  curl https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh

  ## Getting the docker-compose
  msg_ok "Docker-Compose > Getting the docker-compose"
  [ -f "/etc/bash_completion.d/docker.sh" ] && cp -Rfa /etc/bash_completion.d/docker.sh{,.bkp}
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

    msg_ok "Docker-Compose > Getting the bash_completion"
    [ -f "/etc/bash_completion.d/docker-compose.sh" ] && cp -Rfa /etc/bash_completion.d/docker-compose.sh{,.bkp}
    curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose.sh
  else
    msg_error "Docker-Compose > Error > docker-compose was not downloaded. Please check your internet connection"
  fi

  # Backup the vimrc if exists
  msg_ok "[+] VIM > Configuration"
  curl -L https://raw.githubusercontent.com/douglasqsantos/DevOps/master/Misc/prep-vim.sh | bash


  ## Sending information about a not root user
  msg_ok "If you are using the Docker with your own user added it to the docker group"
  msg_warn "Use: usermod -aG docker douglas"
else
  msg_error "Docker was not installed. Please Check the logs..."
fi
