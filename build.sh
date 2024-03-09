#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner
}

# Checks the dependencies of this script.
function checkDependencies() {
  if [ -z "$NPM_CMD" ]; then
    echo "Npm is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$JAVA_CMD" ]; then
    echo "Java is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Builds the services.
function build() {
  echo Building base-consumer...
  cd base-consumer || exit 1
  ./build.sh || exit 1

  echo
  echo Building base-processor...
  cd ../base-processor || exit 1
  ./build.sh || exit 1

  echo
  echo Building consumer...
  cd ../consumer || exit 1
  ./build.sh || exit 1

  echo
  echo Building processor-kafka...
  cd ../processor-kafka || exit 1
  ./build.sh || exit 1
  cd ..

  echo
  echo Building converter...
  ./gradlew build --warning-mode all || exit 1
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  build
}

main