#!/bin/bash
# ---
# RightScript Name: Terraform Install
# Description: Installs Terraform
# Inputs:
#   AWS_ACCESS_KEY_ID:
#     Category: Application
#     Input Type: single
#     Required: true
#     Advanced: true
#     Default: cred:AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY:
#     Category: Application
#     Input Type: single
#     Required: true
#     Advanced: true
#     Default: cred:AWS_SECRET_ACCESS_KEY
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

echo "Configuring AWS authentication..."
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}

EOF