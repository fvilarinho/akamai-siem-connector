#!/bin/bash

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1

  export KUBECONFIG="$KUBECONFIG_FILENAME"
}

# Check dependencies of this script.
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
    echo "Kubectl is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Undeploys the LKE stack storages.
function undeployLkeStackStorages() {
  $KUBECTL_CMD delete pvc --all -n "$IDENTIFIER"
}

# Undeploys the LKE stack deployments.
function undeployLkeStackDeployments() {
  $KUBECTL_CMD delete deployment --all -n "$IDENTIFIER"
  $KUBECTL_CMD delete statefulset --all -n "$IDENTIFIER"
}

# Undeploys the LKE stack services.
function undeployLkeStackServices() {
  $KUBECTL_CMD delete service --all -n "$IDENTIFIER"
}

# Undeploys the LKE stack settings.
function undeployLkeStackSettings() {
  $KUBECTL_CMD delete secret images-registry -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap consumer-credentials -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap consumer-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap converter-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap converter-templates -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap exporter-plugins-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap exporter-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap ingress-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap ingress-settings-object -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap ingress-tls-certificate -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap ingress-tls-private-key -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap kafka-broker-init -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap kafka-broker-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap oauth2-proxy-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap processor-kafka-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap scheduler-queues-settings -n "$IDENTIFIER"
  $KUBECTL_CMD delete configmap scheduler-settings -n "$IDENTIFIER"
}

# Undeploys the LKE stack.
function undeployLkeStack() {
  undeployLkeStackServices
  undeployLkeStackDeployments
  undeployLkeStackStorages
  undeployLkeStackSettings
}

# Undeploys the provisioned infrastructure.
function undeploy() {
  if [ -f "$KUBECONFIG_FILENAME" ]; then
    undeployLkeStack
  fi

  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD destroy \
                 -auto-approve
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  undeploy
}

main