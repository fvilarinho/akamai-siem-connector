#!/bin/bash

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

# Checks the dependencies of this script.
function checkDependencies() {
  if [ -z "$DOCKER_CMD" ]; then
    echo "Docker is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Builds the container images.
function package() {
  $DOCKER_CMD compose build || exit 1
}

# Clean-up.
function cleanUp() {
  echo Y | $DOCKER_CMD image prune > /dev/null 2>&1
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  package
  cleanUp
}

main