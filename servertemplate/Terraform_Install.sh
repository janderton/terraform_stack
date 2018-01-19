#!/bin/bash
# ---
# RightScript Name: Terraform Install
# Description: Installs Terraform
# Inputs:
#   AWS_ACCESS_KEY_ID:
#     Category: Application
#     Input Type: single
#     Required: true
#     Advanced: false
#     Default: cred:AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY:
#     Category: Application
#     Input Type: single
#     Required: true
#     Advanced: false
#     Default: cred:AWS_SECRET_ACCESS_KEY
#   GITHUB_USER:
#     Category: Application
#     Input Type: single
#     Required: true
#     Advanced: false
#     Default: cred:GITHUB_USER
# Attachments: []
# ...
set -euo pipefail
IFS=$'\n\t'

echo "Installing Terraform..."
sudo apt-get update
sudo apt-get install unzip git jq -y
wget https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
unzip terraform_0.11.1_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin
terraform --version

echo "Configuring AWS authentication..."
mkdir -p ~/.aws
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF

echo "Configuring git..."
git config --global user.email ${GITHUB_USER}
git config --global user.name "RightScale"