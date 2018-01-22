#!/bin/bash
# ---
# RightScript Name: Terraform Install
# Description: Installs Terraform
# Inputs:
#   AWS_ACCESS_KEY_ID:
#     Category: Application
#     Input Type: single
#     Required: false
#     Advanced: false
#     Default: cred:AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY:
#     Category: Application
#     Input Type: single
#     Required: false
#     Advanced: false
#     Default: cred:AWS_SECRET_ACCESS_KEY
#   ARM_CLIENT_ID:
#     Category: Application
#     Input Type: single
#     Required: false
#     Advanced: false
#     Default: cred:ARM_CLIENT_ID
#   ARM_CLIENT_SECRET:
#     Category: Application
#     Input Type: single
#     Required: false
#     Advanced: false
#     Default: cred:ARM_CLIENT_SECRET
#   ARM_SUBSCRIPTION_ID:
#     Category: Application
#     Input Type: single
#     Required: false
#     Advanced: false
#     Default: cred:ARM_SUBSCRIPTION_ID
#   ARM_TENANT_ID:
#     Category: Application
#     Input Type: single
#     Required: false
#     Advanced: false
#     Default: cred:ARM_TENANT_ID
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

#choose which cli to install for which cloud
if [[ $ARM_CLIENT_ID ]]; then
    #Install Azure ENV variables for terraform provider
    echo "Configuring Azure Authentication ENV Variables"
    mkdir -p ~/.azure
    cat > ~/.azure/credentials.env <<EOF
export ARM_CLIENT_ID=${ARM_CLIENT_ID}
export ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET}
export ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}
export ARM_TENANT_ID=${ARM_TENANT_ID}
EOF
    chmod 550 ~/.azure/credentials.env
    source ~/.azure/credentials.env

elif [[ $AWS_ACCESS_KEY_ID ]];then
    echo "Configuring AWS authentication..."
    mkdir -p ~/.aws
    cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF
fi

echo "Configuring git..."
git config --global user.email ${GITHUB_USER}
git config --global user.name "RightScale"