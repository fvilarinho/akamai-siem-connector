#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  cd .. || exit 1

  source functions.sh

  cd iac || exit 1

  export KUBECONFIG="$KUBECONFIG_FILENAME"

  # Required variables.
  NODE_COUNT=$(getSetting "infrastructure.nodeCount")
  JOBS_PER_MINUTE=$(getSetting "dataCollection.jobsPerMinute")
}

# Applies the LKE stack storages.
function applyLkeStackStorages() {
  manifestFilename="lke-stack-storages.yml"

  # Prepares the manifest.
  cp -f "$manifestFilename" "$manifestFilename".tmp
  sed -i -e 's|${IDENTIFIER}|'"$IDENTIFIER"'|g' "$manifestFilename".tmp

  # Applies the manifest.
  $KUBECTL_CMD apply -f "$manifestFilename".tmp
}

# Applies the LKE stack deployments.
function applyLkeStackDeployments() {
  manifestFilename="lke-stack-deployments.yml"

  # Prepares the manifest.
  cp -f "$manifestFilename" "$manifestFilename".tmp
  sed -i -e 's|${DOCKER_REGISTRY_URL}|'"$DOCKER_REGISTRY_URL"'|g' "$manifestFilename".tmp
  sed -i -e 's|${DOCKER_REGISTRY_ID}|'"$DOCKER_REGISTRY_ID"'|g' "$manifestFilename".tmp
  sed -i -e 's|${IDENTIFIER}|'"$IDENTIFIER"'|g' "$manifestFilename".tmp
  sed -i -e 's|${BUILD_VERSION}|'"$BUILD_VERSION"'|g' "$manifestFilename".tmp
  sed -i -e 's|${NODE_COUNT}|'"$NODE_COUNT"'|g' "$manifestFilename".tmp
  sed -i -e 's|${JOBS_PER_MINUTE}|'"$JOBS_PER_MINUTE"'|g' "$manifestFilename".tmp

  # Applies the manifest.
  $KUBECTL_CMD apply -f "$manifestFilename".tmp
}

# Applies the LKE stack services.
function applyLkeStackServices() {
  manifestFilename="lke-stack-services.yml"

  # Prepares the manifest.
  cp -f "$manifestFilename" "$manifestFilename".tmp
  sed -i -e 's|${IDENTIFIER}|'"$IDENTIFIER"'|g' "$manifestFilename".tmp

  # Applies the manifest.
  $KUBECTL_CMD apply -f "$manifestFilename".tmp
}

# Clean-up.
function cleanUp() {
  rm -f ./*.tmp*
}

# Main function.
function main() {
  prepareToExecute
  applyLkeStackStorages
  applyLkeStackDeployments
  applyLkeStackServices
  cleanUp
}

main