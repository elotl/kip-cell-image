#!/usr/bin/env bash

set -euxo pipefail

DIST=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -sfL https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -sfL https://nvidia.github.io/libnvidia-container/$DIST/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/libnvidia-container.list
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-get update -y
sudo apt-get install -y iproute2 ipset iptables nfs-common ssl-cert libnvidia-container-tools
sudo apt-get install -y --no-install-recommends nvidia-cuda-toolkit nvidia-430

curl -sfLO https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb && rm amazon-cloudwatch-agent.deb
sudo cp /tmp/aws-cloudwatch-agent.conf /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sudo dpkg -i /tmp/$KIP_PACKAGE

sudo apt-get autoremove -y

sudo mkdir -p /var/lib/docker/containers

sudo mkdir -p /var/log/journal

sudo rm -rf /root/.ssh
sudo rm -rf /home/packer/.ssh
sudo rm -rf /home/ubuntu/.ssh

itzo --version
