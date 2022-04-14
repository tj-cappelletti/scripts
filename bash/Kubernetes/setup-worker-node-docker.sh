#!/bin/bash

YELLOW='\033[1;33m'
NO_COLOR='\033[0m'

echo -e "${YELLOW}Disabling sawp for performance reasons...${NO_COLOR}\n"
sudo swapoff -a
sudo sed -e '/swap/ s/^#*/#/g' -i /etc/fstab
echo -e "\n"

echo -e "${YELLOW}Add Kubernetes repositories...${NO_COLOR}\n"
sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list"
echo -e "\n"

echo -e "${YELLOW}Install Docker GPG Key...${NO_COLOR}\n"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo -e "\n"

echo -e "${YELLOW}Install Kubernetes GPG Key...${NO_COLOR}\n"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo -e "\n"

echo -e "${YELLOW}Updating package sources and upgrading packages...${NO_COLOR}\n"
sudo apt update && sudo apt upgrade -y
echo -e "\n"

echo -e "${YELLOW}Installing editors...${NO_COLOR}\n"
sudo apt-get install -y vim nano libseccomp2
echo -e "\n"

echo -e "${YELLOW}Installing tools to work with Kubernetes...${NO_COLOR}\n"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
echo -e "\n"

echo -e "${YELLOW}Installing Docker...${NO_COLOR}\n"
sudo apt-get install -y docker.io
sleep 3
echo -e "\n"

echo -e "${YELLOW}Installing Kubernetes...${NO_COLOR}\n"
sudo apt-get install -y kubeadm kubelet kubectl kubernetes-cni
echo -e "\n"

echo -e "${YELLOW}Configuring networking...${NO_COLOR}\n"
sudo modprobe br_netfilter
sudo sysctl net.bridge.bridge-nf-call-iptables=1
echo -e "\n"

echo -e "${YELLOW}Changing Docker cgroup driver...${NO_COLOR}\n"
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": { "max-size": "100m" },
    "storage-driver": "overlay2"
}
EOF
echo -e "\n"

echo -e "${YELLOW}Restart Docker...${NO_COLOR}\n"
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
echo -e "\n"
