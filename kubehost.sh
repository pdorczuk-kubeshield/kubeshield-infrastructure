#!/bin/bash

#######################################################################################################################
#   KVM Hypervisor Setup                                                                                              #
#   Run this on a fresh install of Ubuntu 20.04                                                                       #
#######################################################################################################################

#######################################################################################################################
#   Update and install utility packages                                                                                          #
#######################################################################################################################
sudo apt update
sudo apt upgrade -y
sudo apt install -y \
vim \
git \
fish \
apt-transport-https \
ca-certificates \
curl
nfs-common \
gnupg \
lsb-release

chsh -s `which fish`


#######################################################################################################################
#   Install Docker                                                                                                #
#######################################################################################################################
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose


#######################################################################################################################
#   Install kubeadm                                                                                                   #
#######################################################################################################################
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

#Download the Google Cloud public signing key:
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

#Add the Kubernetes apt repository:
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudo apt-get update
sudo apt-get install -y kubeadm=1.20.7-00 kubelet=1.20.7-00 kubectl=1.20.7-00
sudo apt-mark hold kubelet kubeadm kubectl

 --hostname localhost --rm \
  --entrypoint=/bin/sh \
  -v ~/teleport/config:/etc/teleport \
  quay.io/gravitational/teleport:6 -c "./teleport/teleport.yaml"



#######################################################################################################################
#   Install teleport                                                                                                  #
#######################################################################################################################
# start teleport with mounted config and data directories, plus all ports
docker run --hostname localhost --name teleport \
  -v ~/teleport/config:/etc/teleport \
  -v ~/teleport/data:/var/lib/teleport \
  -p 3023:3023 -p 3025:3025 -p 3080:3080 \
  quay.io/gravitational/teleport:6


#######################################################################################################################
#   Install helm                                                                                                      #
#######################################################################################################################
wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz
tar -zxvf helm-v*
sudo mv linux-amd64/helm /usr/local/bin/helm
rm helm-v*
rm -rf linux-amd64