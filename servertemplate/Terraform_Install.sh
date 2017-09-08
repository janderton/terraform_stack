#!/bin/bash
# ---
# RightScript Name: Terraform Install
# Description: Installs Terraform
# Inputs: {}
# Attachments: []
# ...
set -euo pipefail
IFS=$'\n\t'

echo "Installing Terraform..."
sudo apt-get update
sudo apt-get install unzip git
wget https://releases.hashicorp.com/terraform/0.10.4/terraform_0.10.4_linux_amd64.zip
unzip terraform_0.10.4_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin
terraform --version
