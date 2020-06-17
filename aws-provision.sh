#!/usr/bin/env bash

set -euxo pipefail

DIST=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$DIST/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/libnvidia-container.list
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-get update -y
sudo apt-get install -y iproute2 ipset iptables nfs-common ssl-cert libnvidia-container-tools
sudo apt-get install -y --no-install-recommends nvidia-cuda-toolkit nvidia-430

sudo dpkg -i /tmp/$KIP_PACKAGE

sudo rm -rf /root/.ssh
sudo rm -rf /home/packer/.ssh
sudo rm -rf /home/ubuntu/.ssh

itzo --version