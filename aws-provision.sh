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
sudo sed -i '/^User=.*$/d' /lib/systemd/system/td-agent.service
sudo sed -i '/^Group=.*$/d' /lib/systemd/system/td-agent.service
sudo apt-get install -y g++ make
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 0.7.4 fluent-plugin-cloudwatch-logs
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 2.3.0 fluent-plugin-concat
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 2.5.1 fluent-plugin-grok-parser
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 1.0.2 fluent-plugin-json-in-json-2
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 2.3.0 fluent-plugin-kubernetes_metadata_filter
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 1.0.0 fluent-plugin-multi-format-parser
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 1.5.0 fluent-plugin-prometheus
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 2.0.1 fluent-plugin-record-modifier
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 2.2.0 fluent-plugin-rewrite-tag-filter
sudo /opt/td-agent/embedded/bin/fluent-gem install --version 1.0.2 fluent-plugin-systemd
sudo apt-get remove -y g++ make
sudo mv /tmp/aws-fluentd-cell.conf /etc/td-agent/td-agent.conf
sudo systemctl daemon-reload
sudo systemctl enable td-agent
#curl -sfLO https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
#sudo dpkg -i amazon-cloudwatch-agent.deb && rm amazon-cloudwatch-agent.deb
#sudo cp /tmp/aws-cloudwatch-agent.conf /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sudo dpkg -i /tmp/$KIP_PACKAGE

sudo apt-get autoremove -y

sudo mkdir -p /usr/share/collectd
sudo touch /usr/share/collectd/types.db

sudo mkdir -p /var/lib/docker/containers

sudo mkdir -p /var/log/journal

sudo rm -rf /root/.ssh
sudo rm -rf /home/packer/.ssh
sudo rm -rf /home/ubuntu/.ssh

itzo --version
