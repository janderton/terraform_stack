#!/bin/bash
# ---
# RightScript Name: Terraform Destroy
# Description: Runs terraform destroy
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
# Attachments: []
# ...
set -euo pipefail
IFS=$'\n\t'
cd ~

echo "Cost Center: $COST_CENTER"

auth_git_repo=${GIT_REPO:0:8}adamalex:${GITHUB_TOKEN}@${GIT_REPO:8}
git clone --depth=10 --branch="$BRANCH_NAME" "$auth_git_repo" terraform

(
  cd terraform || exit 1
  terraform init -no-color
  terraform validate -no-color
  terraform refresh -no-color
  terraform destroy -force -no-color

  git add .
  git commit -m "Update Terraform state after destroy"
  git push origin "$BRANCH_NAME"
)

rm -rf terraform
