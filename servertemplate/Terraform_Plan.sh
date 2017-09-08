#!/bin/bash
# ---
# RightScript Name: Terraform Plan
# Description: Installs Terraform
# Inputs:
#   BRANCH_NAME:
#     Category: Application
#     Description: Branch to be used from git repo
#     Input Type: single
#     Required: true
#     Advanced: false
#   COST_CENTER:
#     Category: Application
#     Description: Cost Center to be used for accounting purposes
#     Input Type: single
#     Required: true
#     Advanced: false
#   GIT_REPO:
#     Category: Application
#     Description: Link to repository containing the Terraform configuration
#     Input Type: single
#     Required: true
#     Advanced: false
# Attachments: []
# ...
set -euo pipefail
IFS=$'\n\t'

echo "Running terraform plan..."
echo $GIT_REPO
echo $BRANCH_NAME
echo $COST_CENTER

cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=${test}
aws_secret_access_key=${test2}

EOF
