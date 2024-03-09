#!/bin/bash

# Prepare the environment to execute this script.
function prepareToExecute() {
  cd src || exit 1
}

# Build the service.
function build() {
  $NPM_CMD --no-fund --target_arch=x64 install
}

# Main function.
function main() {
  prepareToExecute
  build
}

main