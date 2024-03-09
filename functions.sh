#!/bin/bash

# Shows the labels.
function showLabel() {
  if [[ "$0" == *"build.sh"* ]]; then
    echo "*** COMPILE & BUILD ***"
  elif [[ "$0" == *"package.sh"* ]]; then
    echo "*** PACKAGING ***"
  elif [[ "$0" == *"publish.sh"* ]]; then
    echo "*** PUBLISH ***"
  elif [[ "$0" == *"undeploy.sh"* ]]; then
    echo "*** UNDEPLOY ***"
  elif [[ "$0" == *"deploy.sh"* ]]; then
    echo "*** DEPLOY ***"
  elif [[ "$0" == *"setup.sh"* ]]; then
    echo "*** SETUP ***"
  fi

  echo
}

# Shows the banner.
function showBanner() {
  if [ -f banner.txt ]; then
    cat banner.txt
  fi

  showLabel $1
}

# Gets a setting value.
function getSetting() {
  if [ -f "$SETTINGS_FILENAME" ]; then
    result=$($JQ_CMD -r ".$1" < "$SETTINGS_FILENAME")

    if [ "$result" == "null" ]; then
      result=
    fi
  else
    result=
  fi

  echo "$result"
}

# Gets a credential value.
function getCredential() {
  if [ -f "$CREDENTIALS_FILENAME" ]; then
    value=$(awk -F'=' '/'$1'/,/^\s*$/{ if($1~/'$2'/) { print substr($0, length($1) + 2) } }' "$CREDENTIALS_FILENAME" | tr -d '"' | tr -d ' ')
  else
    value=
  fi

  echo "$value"
}

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  # Mandatory binaries.
  export CURL_CMD=$(which curl)
  export JQ_CMD=$(which jq)
  export YQ_CMD=$(which yq)
  export NPM_CMD=$(which npm)
  export JAVA_CMD=$(which java)
  export DOCKER_CMD=$(which docker)
  export TERRAFORM_CMD=$(which terraform)
  export KUBECTL_CMD=$(which kubectl)

  # Mandatory files/paths.
  export WORK_DIR="$PWD"/iac
  export BUILD_ENV_FILENAME="$WORK_DIR"/.env
  export CREDENTIALS_FILENAME="$WORK_DIR"/.credentials
  export SETTINGS_FILENAME="$WORK_DIR"/settings.json
  export KUBECONFIG_FILENAME="$WORK_DIR"/.kubeconfig

  # Mandatory environment variables.
  source "$BUILD_ENV_FILENAME"

  export TF_VAR_credentialsFilename="$CREDENTIALS_FILENAME"
  export TF_VAR_settingsFilename="$SETTINGS_FILENAME"
  export TF_VAR_kubeconfigFilename="$KUBECONFIG_FILENAME"
  export TF_VAR_identifier="$IDENTIFIER"
}

prepareToExecute