#!/bin/bash
# ---
# RightScript Name: Terraform Apply
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

echo "Running terraform apply..."
echo $GIT_REPO
echo $BRANCH_NAME
echo $COST_CENTER
