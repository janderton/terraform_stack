#!/bin/bash
# ---
# RightScript Name: Terraform Apply
# Description: Runs terraform apply
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
#   GITHUB_TOKEN:
#     Category: Application
#     Input Type: single
#     Required: true
#     Advanced: true
#     Default: cred:GITHUB_TOKEN
# Attachments:
# - functions.sh
# ...
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=attachments/functions.sh
source "$RS_ATTACH_DIR/functions.sh"

# policy variables may be passed into terraform
echo "Cost Center: $COST_CENTER"

# Execute terraform action
log_start
terraform_action "apply" ""
log_end

rs_tag "rs:terraform_out_url=$(gist_create "apply")"
