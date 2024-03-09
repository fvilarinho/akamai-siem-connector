#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  cd .. || exit 1

  source functions.sh

  cd iac || exit 1

  export KUBECONFIG="$KUBECONFIG_FILENAME"

  NODE_COUNT=$(getSetting "infrastructure.nodeCount")
}

# Checks if there are not ready nodes before start labeling for affinity purposes.
function waitForLkeClusterNodesBeReady() {
  echo "Waiting for all LKE cluster nodes to be ready..."

  # Waits until all nodes be in ready state.
  while "true"; do
    CURRENT_NODE_COUNT=$($KUBECTL_CMD get nodes -o name | wc -l | tr -d '[:space:]')

    if [ "$CURRENT_NODE_COUNT" -ge "$NODE_COUNT" ]; then
      NOT_READY_NODE_COUNT=$($KUBECTL_CMD get nodes 2>&1 | grep NotReady)

      if [ -z "$NOT_READY_NODE_COUNT" ]; then
        break
      fi
    fi

    sleep 1
  done
}

# Prepares LKE stack credentials.
function prepareLkeStackCredentials() {
  EDGEGRID_FILENAME=/tmp/.edgerc

  echo "$(awk '/\[/{count++} count==2{exit} 1' "$CREDENTIALS_FILENAME")" > "$EDGEGRID_FILENAME"
}

# Applies the LKE stack settings.
function applyLkeStackSettings() {
  # Namespace definition.
  $KUBECTL_CMD create namespace "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -

  # Images registry definition.
  $KUBECTL_CMD create secret docker-registry images-registry --docker-server="$DOCKER_REGISTRY_URL" --docker-username="$DOCKER_REGISTRY_ID" --docker-password="$DOCKER_REGISTRY_PASSWORD" -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -

  # Credentials and settings definition.
  $KUBECTL_CMD create configmap consumer-credentials --from-file="$EDGEGRID_FILENAME" -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap consumer-settings --from-file=../consumer/etc/settings.json -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap converter-settings --from-file=../converter/src/main/resources/etc/settings.json -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap converter-templates --from-file=../converter/src/main/resources/etc/templates.json -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap exporter-plugins-settings --from-file=../exporter/etc/plugins.conf -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap exporter-settings --from-file=../exporter/etc/settings.conf -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap ingress-settings --from-file=../ingress/etc/nginx/http.d/settings.conf -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap ingress-settings-object --from-file=../ingress/htdocs/settings.js -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap ingress-tls-certificate --from-file=../ingress/etc/ssl/certs/cert.crt -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap ingress-tls-private-key --from-file=../ingress/etc/ssl/private/cert.key -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap kafka-broker-init --from-file=../kafka-broker/bin/init.sh -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap kafka-broker-settings --from-file=../kafka-broker/etc/settings.conf -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap oauth2-proxy-settings --from-file=../oauth2-proxy/etc/settings.conf -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap processor-kafka-settings --from-file=../processor-kafka/etc/settings.json -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap scheduler-queues-settings --from-file=../scheduler/etc/settings.conf -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap scheduler-settings --from-file=../scheduler/etc/settings.json -n "$IDENTIFIER" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
}

# Clean-up.
function cleanUp() {
  rm -f "$EDGEGRID_FILENAME"
}

# Main function.
function main(){
  prepareToExecute
  waitForLkeClusterNodesBeReady
  prepareLkeStackCredentials
  applyLkeStackSettings
  cleanUp
}

main