#!/bin/bash
# ---
# RightScript Name: Terraform Execute
# Description: Executes a controlled terraform action, preserving state and recording for auditing purposes
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
#   GITHUB_USER:
#     Category: Application
#     Input Type: single
#     Required: true
#     Advanced: false
#     Default: cred:GITHUB_USER
#   GITHUB_TOKEN:
#     Category: Application
#     Input Type: single
#     Required: true
#     Advanced: false
#     Default: cred:GITHUB_TOKEN
#   TERRAFORM_ACTION:
#     Category: Application
#     Description: Terraform action to be executed
#     Input Type: single
#     Required: true
#     Advanced: false
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
# Attachments:
# - functions.sh
# ...
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=attachments/functions.sh
source "$RS_ATTACH_DIR/functions.sh"

# Policy-related or other custom variables may be used from within terraform
echo "Cost Center: $COST_CENTER"

# Execute terraform action
log_start
terraform_action "$TERRAFORM_ACTION"
log_end

# Create gist and store in an instance tag
instance_tag "rs:terraform_out_url=$(gist_create "$TERRAFORM_ACTION")"