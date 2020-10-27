#!/usr/bin/env bash

set -euxo pipefail

sudo systemd disable apt-daily.timer || true
sudo systemd stop apt-daily.timer || true
sudo systemd disable apt-daily-upgrade.timer || true
sudo systemd stop apt-daily-upgrade.timer || true

DIST=$(. /etc/os-release; echo $ID$VERSION_ID)
VERSION_ID=$(. /etc/os-release; echo $VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$DIST/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/libnvidia-container.list
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh
sudo add-apt-repository -y ppa:graphics-drivers/ppa
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install -y iproute2 ipset iptables nfs-common ssl-cert google-fluentd google-fluentd-catch-all-config-structured stackdriver-agent libnvidia-container-tools
sudo apt-get install -y --no-install-recommends nvidia-cuda-toolkit nvidia-driver-430 podman
sudo systemctl enable podman.socket

sudo dpkg -i /tmp/$KIP_PACKAGE

sudo mv /tmp/google-fluentd-cell.conf /etc/google-fluentd/config.d/elotl-cell.conf
sudo /opt/google-fluentd/embedded/bin/fluentd --dry-run -c /etc/google-fluentd/config.d/elotl-cell.conf

echo -e '[IpForwarding]\nip_aliases = false\n' | sudo tee /etc/default/instance_configs.cfg.template

sudo mkdir -p /var/lib/docker/containers

sudo mkdir -p /var/log/journal

sudo rm -rf /root/.ssh
sudo rm -rf /home/packer/.ssh
sudo rm -rf /home/ubuntu/.ssh

podman system info
itzo --version
