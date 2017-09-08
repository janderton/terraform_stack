#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

log_start() {
  exec 6>&1
  exec > >(tee -i "/tmp/terraform_out.txt")
  exec 2>&1
}

log_end() {
  exec 1>&6 6>&-
}

rs_tag() {
  echo "Applying tag [$1] to instance..."
  while true; do
    rsc --rl10 cm15 multi_add /api/tags/multi_add "resource_hrefs[]=$RS_SELF_HREF" "tags[]=$1"

    tag=$(rsc --rl10 --xm ".name:val(\"$1\")" cm15 by_resource /api/tags/by_resource "resource_hrefs[]=$RS_SELF_HREF")

    if [[ "$tag" = "" ]]; then
      sleep 1
    else
      break
    fi
 done
}

terraform_action() {
  cd ~
  rm -rf terraform
  auth_git_repo=${GIT_REPO:0:8}adamalex:${GITHUB_TOKEN}@${GIT_REPO:8}
  git clone --depth=10 --branch="$BRANCH_NAME" "$auth_git_repo" terraform

  (
    cd terraform || exit 1
    terraform init -no-color
    terraform validate -no-color
    terraform refresh -no-color
    terraform "$1" "$2" -no-color

    if [ ! -z "$(git status --porcelain)" ]; then 
      git add .
      git commit -m "Update Terraform state after $1"
      git push origin "$BRANCH_NAME"
    fi
  )

  rm -rf terraform
}

gist_create() {
jq -n --arg action "$1" --arg log "$(cat "/tmp/terraform_out.txt")" "$(cat <<'END'
{
  "description": "Output from Terraform $action",
  "public": false,
  "files": {
    "terraform_out.txt": {
      "content": $log
    }
  }
}
END
)" | curl -sSX POST "https://api.github.com/gists" -d "@-" | jq -r '.html_url'
}