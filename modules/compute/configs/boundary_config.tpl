#!/usr/bin/env bash

#Utils
sudo apt install -y unzip vim jq

#Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce
sudo usermod -aG docker $USER
sudo systemctl enable docker


#Boundary
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install boundary

sleep 10
#public_ipv4=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
#sudo boundary dev -api-listen-address=0.0.0.0 -cluster-listen-address=0.0.0.0 -proxy-listen-address=0.0.0.0 -worker-public-address=$PUBLIC_IP > boundary.log

#Systemd
sudo bash -c 'cat <<EOF> /etc/systemd/system/boundary.service
[Unit]
Description="HashiCorp Boundary"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/boundary dev -api-listen-address=0.0.0.0 -cluster-listen-address=0.0.0.0 -proxy-listen-address=0.0.0.0 -worker-public-address=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl enable boundary
sudo systemctl start boundary
