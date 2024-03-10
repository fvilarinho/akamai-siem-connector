#!/bin/bash

# Checks the dependencies of this script.
function checkDependencies() {
  if [ ! -f "$CREDENTIALS_FILENAME" ]; then
    echo "The credentials filename was not found! Please finish the setup!"

    exit 1
  fi

  if [ ! -f "$SETTINGS_FILENAME" ]; then
    echo "The settings filename was not found! Please finish the setup!"

    exit 1
  fi

  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$KUBECTL_CMD" ]; then
    echo "kubectl is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$CURL_CMD" ]; then
    echo "curl is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$JQ_CMD" ]; then
    echo "Jq is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

# Executes the provisioning of the infrastructure based on the IaC files.
function deploy() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD apply \
                 -auto-approve
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  deploy
}

main