#!/bin/bash

# Configuring Rancher with 3 Nodes

## NTP
```bash
apt update && apt install ntpdate 
ntpdate -u a.ntp.br 
```

## Docker
```bash
apt-get remove docker docker-engine docker.io containerd runc -y 
apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common unzip lvm2 rsync screen -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
systemctl enable docker
systemctl start docker
```
 
## Add user to docker group
```bash
sudo usermod -aG docker douglas
```

## RKE
```bash
curl -LO https://github.com/rancher/rke/releases/download/v1.1.3/rke_linux-amd64
mv rke_linux-amd64 /usr/bin/rke
chmod +x /usr/bin/rke
rke -version
```
 
## Kubectl
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

## Vault

```bash
apt install -y unzip
curl -LO https://releases.hashicorp.com/vault/1.4.3/vault_1.4.3_linux_amd64.zip
unzip vault_1.4.3_linux_amd64.zip
chmod +x ./vault
mv ./vault /usr/local/bin/vault
```

## SSH
```bash
cd rke
ssh-keygen -o -a 100 -t ed25519 -f ./cluster-key -C rke
```

## Copy the Keys
```bash
ssh-copy-id -i ./cluster-key.pub douglas@node01
ssh-copy-id -i ./cluster-key.pub douglas@node02
ssh-copy-id -i ./cluster-key.pub douglas@node03
```

## Configure the cluster-rke.yaml before run the command below

```bash
rke up --config ./cluster-rke.yaml
```

## Configuring the kubectl access
```bash
mkdir ~/.kube 
cp ./kube_config_cluster-rke.yaml ~/.kube/config
```

## Configure LVM for Docker
```bash
pvcreate -v /dev/sdc
vgcreate vg_docker /dev/sdc
lvcreate -l 100%FREE -n lv_docker vg_docker
mkfs.xfs /dev/mapper/vg_docker-lv_docker
mkdir /mnt/docker
mount /dev/mapper/vg_docker-lv_docker /mnt/docker
cd /mnt/docker
rsync -aAvzPh /var/lib/docker/* .
blkid
mount -a
```

## Create the directory for Rancher
```bash
mkdir -p /var/lib/docker/data/rancher
```

## Create the configuration for Rancher
```bash
# kubectl create namespace rancher
kubectl apply -f structure/rancher 
```

```bash
# curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl 
# curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
# https://github.com/rancher/rancher/releases
```

## References
- https://rancher.com/docs/rke/latest/en/example-yamls/
- https://rancher.com/support-maintenance-terms/all-supported-versions/rancher-v2.4.5/
- https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/
- https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/kubernetes-rke/
- https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/helm-rancher/
- https://rancher.com/docs/rancher/v2.x/en/upgrades/upgrades/
- https://rancher.com/docs/rke/latest/en/config-options/
- https://rancher.com/docs/rke/latest/en/upgrades/
- https://rancher.com/docs/rke/latest/en/upgrades/#listing-supported-kubernetes-versions