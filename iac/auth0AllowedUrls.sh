#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  cd .. || exit 1

  source functions.sh

  cd iac || exit 1

  export KUBECONFIG="$KUBECONFIG_FILENAME"
}

# Gets an auth0.com token.
function getAuth0Token() {
  # Required attributes definition.
  SECTION_NAME=auth0

  DOMAIN=$(getCredential "$SECTION_NAME" "domain")
  URL="https://$DOMAIN/oauth/token"
  AUDIENCE="https://$DOMAIN/api/v2/"
  CLIENT_ID=$(getCredential "$SECTION_NAME" "api_id")
  CLIENT_SECRET=$(getCredential "$SECTION_NAME" "api_secret")

  # Call the API.
  RESPONSE=$($CURL_CMD --silent \
                       --request POST \
                       --url "$URL" \
                       --header "Content-Type: application/json" \
                       --data '{"client_id": "'"$CLIENT_ID"'", "client_secret": "'"$CLIENT_SECRET"'", "audience": "'"$AUDIENCE"'", "grant_type": "client_credentials"}')

  # Parse the response.
  echo "$RESPONSE" | $JQ_CMD -r '.access_token'
}

# Updates the auth0.com client with the allowed URLs.
function updateAuth0ClientWithAllowedUrls() {
  TOKEN=$(getAuth0Token)

  # Checks if the token was created.
  if [ -z "$TOKEN" ]; then
      echo "Failed to obtain auth0 token! Please check the auth0 credentials!"

      exit 1
  fi

  # Required attributes definition.
  SECTION_NAME=auth0

  DOMAIN=$(getCredential "$SECTION_NAME" "domain")
  CLIENT_ID=$(getCredential "$SECTION_NAME" "client_id")
  URL="https://$DOMAIN/api/v2/clients/$CLIENT_ID"
  HOSTNAME=$($KUBECTL_CMD get service ingress -n "$IDENTIFIER" -o json | $JQ_CMD -r ".status.loadBalancer.ingress[0].hostname")
  WEB_ORIGINS="[\"http://$HOSTNAME\", \"https://$HOSTNAME\"]"
  ALLOWED_ORIGINS="[\"http://$HOSTNAME\", \"https://$HOSTNAME\"]"
  CALLBACKS="[\"http://$HOSTNAME/oauth2/callback\", \"https://$HOSTNAME/oauth2/callback\"]"

  # Call the API.
  RESPONSE=$($CURL_CMD --silent \
                       --output /dev/null \
                       --write-out "%{http_code}" \
                       --request PATCH \
                       --url "$URL" \
                       --header "Authorization: Bearer $TOKEN" \
                       --header "Content-Type: application/json" \
                       --data '{"web_origins": '"$WEB_ORIGINS"', "allowed_origins": '"$ALLOWED_ORIGINS"', "callbacks": '"$CALLBACKS"'}')

  # Check if the call got errors.
  if [ "$RESPONSE" -ne 200 ]; then
    echo "Failed to update auth0.com client allowed URLs! Please check the credentials and settings!"

    exit 1
  fi
}

# Main function.
function main() {
  prepareToExecute
  updateAuth0ClientWithAllowedUrls
}

main