#!/usr/bin/env bash

set -euxo pipefail

DIST=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -sfL https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -sfL https://nvidia.github.io/libnvidia-container/$DIST/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/libnvidia-container.list
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-get update -y
sudo apt-get install -y iproute2 ipset iptables nfs-common ssl-cert libnvidia-container-tools
sudo apt-get install -y --no-install-recommends nvidia-cuda-toolkit nvidia-430

curl -sfL https://toolbelt.treasuredata.com/sh/install-ubuntu-xenial-td-agent3.sh | sh
sudo /opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-cloudwatch-logs
sudo /opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-kubernetes_metadata_filter
sudo mv /tmp/aws-fluentd-cell.conf /etc/td-agent/td-agent.conf
sudo systemctl enable td-agent

sudo dpkg -i /tmp/$KIP_PACKAGE

sudo rm -rf /root/.ssh
sudo rm -rf /home/packer/.ssh
sudo rm -rf /home/ubuntu/.ssh

itzo --version
