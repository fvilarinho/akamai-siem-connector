#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  cd .. || exit 1

  source functions.sh
}

# Gets the auth0.com credentials.
function getAuth0Credentials() {
  SECTION_NAME=auth0

  # Required attributes.
  DOMAIN=$(getCredential "$SECTION_NAME" "domain")
  API_ID=$(getCredential "$SECTION_NAME" "api_id")
  API_SECRET=$(getCredential "$SECTION_NAME" "api_secret")

  # Starts the JSON.
  echo "{"
  echo "\"domain\": \"$DOMAIN\","
  echo "\"api_id\": \"$API_ID\","
  echo "\"api_secret\": \"$API_SECRET\""
  echo "}"
  # Ends the JSON.
}

# Main function.
function main() {
  prepareToExecute
  getAuth0Credentials
}

main