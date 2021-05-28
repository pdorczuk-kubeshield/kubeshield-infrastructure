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

chsh -s `which fish`


#######################################################################################################################
#   Install containerd                                                                                                #
#######################################################################################################################
sudo apt-get install containerd -y
sudo mkdir -p /etc/containerd

sudo cat ./kubeadm/containerd-config.toml > /etc/containerd/config.toml
sudo systemctl restart containerd



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

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#Download the Google Cloud public signing key:
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

#Add the Kubernetes apt repository:
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
