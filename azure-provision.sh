#!/usr/bin/env bash

set -euxo pipefail

sudo systemd disable apt-daily.timer || true
sudo systemd stop apt-daily.timer || true
sudo systemd disable apt-daily-upgrade.timer || true
sudo systemd stop apt-daily-upgrade.timer || true

DIST=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$DIST/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/libnvidia-container.list
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-get update -y
sudo apt-get install -y iproute2 ipset iptables nfs-common ssl-cert libnvidia-container-tools snapd
sudo apt-get install -y --no-install-recommends nvidia-cuda-toolkit nvidia-430
sudo snap install podman --edge --devmode
sudo systemd-path search-binaries
sudo podman system info
sudo which podman
sudo systemctl list-sockets --all
sudo systemctl enable podman.socket

sudo dpkg -i /tmp/$KIP_PACKAGE

echo -e '[IpForwarding]\nip_aliases = false\n' | sudo tee /etc/default/instance_configs.cfg.template

sudo mkdir -p /var/lib/docker/containers

sudo mkdir -p /var/log/journal

sudo rm -rf /root/.ssh
sudo rm -rf /home/packer/.ssh
sudo rm -rf /home/ubuntu/.ssh

itzo --version