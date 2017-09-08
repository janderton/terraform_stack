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

echo "Cost Center: $COST_CENTER"
echo "Running terraform plan..."

git clone --depth=10 --branch="$BRANCH_NAME" "$GIT_REPO" terraform

(
  cd terraform || exit
  terraform validate
  terraform init
  terraform refresh
  terraform plan
)

rm -rf terraform
