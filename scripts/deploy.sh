#!/bin/bash

set -euo pipefail

# Check if a .env exists in the root
if [ ! -f .env ]; then
    echo -e "\e[31mPlease create an .env file in the root directory! You should use the .env.example as a template.\e[0m"
    exit 1
fi

# Check the user is logged into Azure
if ! az account show 1>/dev/null; then
    echo "You must log into Azure first!"
    az login
    az account set -s $TF_VAR_subscription_id
fi

# Check the logged in user has AAD permission "Application Administrator"
if ! az ad signed-in-user show --query "appRoleAssignments[?principalRole=='ApplicationAdministrator']" -o tsv; then
    echo -e "\e[31mYou must have the AAD permission 'Application Administrator' to deploy this solution because we create assets in AAD.\e[0m"
    # TODO: Switch the AAD creation off within Terraform rather than failing.
    exit 1
fi

cd infrastructure

terraform init

echo -e "\e[33mDeploying infrastructure - this will take a few minutes\e[0m"
terraform apply --auto-approve -lock=false

echo -e "\e[33mAdding environment variables to .env\e[0m"
terraform output -json > terraform_output.json
../scripts/json-to-env.sh < terraform_output.json > terraform.env
  # Remove everything after a pattern and then merge our .env file with the terraform output
  sed -i '0,/^# =================================================/I!d' ../.env
  sed -i '/^# =================================================/ r terraform.env' ../.env

echo -e "\e[33mWriting kubeconfig\e[0m" 
mkdir -p ~/.kube
terraform output -raw kube_config > ~/.kube/config