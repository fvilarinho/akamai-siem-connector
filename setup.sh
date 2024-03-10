#!/bin/bash

# Opens the license dialog.
function licenseDialog() {
  TITLE="LICENSE"
  CURRENT_MENU="6. LICENSE"

  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --textbox LICENSE 20 90
}

# Deploys the stack in Akamai Connected Cloud.
function deploy() {
  CURRENT_MENU="4. DEPLOY"

  ./deploy.sh infrastructure

  sleep 1
}

# Undeploys the stack from Akamai Connected Cloud.
function undeploy() {
  CURRENT_MENU="5. UNDEPLOY"

  ./undeploy.sh

  sleep 1
}

# Saves the Scheduler settings file.
function saveSchedulerSettings() {
  SCHEDULER_SETTINGS_FILENAME=scheduler/etc/settings.json

  # Create the settings file using a JSON format.
  echo "{" > "$SCHEDULER_SETTINGS_FILENAME".tmp
  echo "\"outputQueue\": \"jobsToBeProcessed\"," >> "$SCHEDULER_SETTINGS_FILENAME".tmp
  echo "\"jobsPerMinute\": $JOBS_PER_MINUTE," >> "$SCHEDULER_SETTINGS_FILENAME".tmp
  echo "\"maxEventsPerJob\": $MAX_EVENTS_PER_JOB" >> "$SCHEDULER_SETTINGS_FILENAME".tmp
  echo "}" >> "$SCHEDULER_SETTINGS_FILENAME".tmp

  # Indent the settings file.
  $JQ_CMD -r . "$SCHEDULER_SETTINGS_FILENAME".tmp > "$SCHEDULER_SETTINGS_FILENAME"

  # Clean-up.
  rm -f "$SCHEDULER_SETTINGS_FILENAME".tmp
}

# Saves the scheduler queues settings file.
function saveSchedulerQueuesSettings() {
  SCHEDULER_QUEUES_SETTINGS_FILENAME=scheduler/etc/settings.conf

  # Check if the settings file exists. If don't, create it with a base content.
  if [ ! -f "$SCHEDULER_QUEUES_SETTINGS_FILENAME" ]; then
    cp -f "$SCHEDULER_QUEUES_SETTINGS_FILENAME.original" "$SCHEDULER_QUEUES_SETTINGS_FILENAME"
  fi
}

# Saves the processor-kafka settings file.
function saveProcessorKafkaSettings() {
  PROCESSOR_KAFKA_SETTINGS_FILENAME=processor-kafka/etc/settings.json

  # Create the settings file using a JSON format.
  echo "{" > "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
  echo "\"scheduler\": \"scheduler\"," >> "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
  echo "\"inputQueue\": \"eventsToBeStored\"," >> "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
  echo "\"kafka\": {" >> "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
  echo "\"brokers\": [ \"kafka-broker:9092\" ]," >> "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
  echo "\"topic\": \"eventsCollected\"," >> "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
  echo "\"maxMessageSize\": $MAX_EVENTS_COLLECTION_SIZE" >> "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
  echo "}" >> "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
  echo "}" >> "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp

  # Indent the settings file.
  $JQ_CMD -r . "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp > "$PROCESSOR_KAFKA_SETTINGS_FILENAME"

  # Clean-up.
  rm -f "$PROCESSOR_KAFKA_SETTINGS_FILENAME".tmp
}

# Save the OAuth2 settings settings file.
function saveOAuth2Settings() {
  OAUTH2_SETTINGS_FILENAME=oauth2-proxy/etc/settings.conf

  if [ ! -f "$OAUTH2_SETTINGS_FILENAME" ]; then
    cp -f "$OAUTH2_SETTINGS_FILENAME.original" "$OAUTH2_SETTINGS_FILENAME"
  fi

  cp -f "$OAUTH2_SETTINGS_FILENAME" "$OAUTH2_SETTINGS_FILENAME".tmp

  searchString=$(grep 'oidc_issuer_url=.*' < "$OAUTH2_SETTINGS_FILENAME".tmp)
  replaceString="oidc_issuer_url=\"https://$AUTH0_DOMAIN/\""

  sed -i -e 's|'"$searchString"'|'"$replaceString"'|g' "$OAUTH2_SETTINGS_FILENAME".tmp

  searchString=$(grep 'client_id=.*' < "$OAUTH2_SETTINGS_FILENAME".tmp)
  replaceString="client_id=\"$AUTH0_CLIENT_ID\""

  sed -i -e 's|'"$searchString"'|'"$replaceString"'|g' "$OAUTH2_SETTINGS_FILENAME".tmp

  searchString=$(grep 'client_secret=.*' < "$OAUTH2_SETTINGS_FILENAME".tmp)
  replaceString="client_secret=\"$AUTH0_CLIENT_SECRET\""

  sed -i -e 's|'"$searchString"'|'"$replaceString"'|g' "$OAUTH2_SETTINGS_FILENAME".tmp

  OAUTH2_COOKIE_SECRET=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | tr -d -- '\n' | tr -- '+/' '-_'; echo)

  searchString=$(grep 'cookie_secret=.*' < "$OAUTH2_SETTINGS_FILENAME".tmp)
  replaceString="cookie_secret=\"$OAUTH2_COOKIE_SECRET\""

  sed -i -e 's|'"$searchString"'|'"$replaceString"'|g' "$OAUTH2_SETTINGS_FILENAME".tmp

  cp "$OAUTH2_SETTINGS_FILENAME".tmp "$OAUTH2_SETTINGS_FILENAME"

  # Clean-up.
  rm -f "$OAUTH2_SETTINGS_FILENAME".tmp
  rm -f "$OAUTH2_SETTINGS_FILENAME".tmp-e
}

# Save the kafka-broker settings file.
function saveKafkaBrokerSettings() {
  KAFKA_BROKER_SETTINGS_FILENAME=kafka-broker/etc/settings.conf

  # Check if the settings file exists. If don't, create it with a base content.
  if [ ! -f "$KAFKA_BROKER_SETTINGS_FILENAME" ]; then
    cp -f "$KAFKA_BROKER_SETTINGS_FILENAME.original" "$KAFKA_BROKER_SETTINGS_FILENAME"
  fi

  # Prepare the settings file with the defined parameters.
  cp -f "$KAFKA_BROKER_SETTINGS_FILENAME" "$KAFKA_BROKER_SETTINGS_FILENAME".tmp

  searchString=$(grep 'message.max.bytes=.*' < "$KAFKA_BROKER_SETTINGS_FILENAME".tmp)
  replaceString="message.max.bytes=$MAX_EVENTS_COLLECTION_SIZE"

  sed -i -e 's|'"$searchString"'|'"$replaceString"'|g' "$KAFKA_BROKER_SETTINGS_FILENAME".tmp

  searchString=$(grep 'replica.fetch.max.bytes=.*' < "$KAFKA_BROKER_SETTINGS_FILENAME".tmp)
  replaceString="replica.fetch.max.bytes=$MAX_EVENTS_COLLECTION_SIZE"

  sed -i -e 's|'"$searchString"'|'"$replaceString"'|g' "$KAFKA_BROKER_SETTINGS_FILENAME".tmp

  searchString=$(grep 'log.retention.minutes=.*' < "$KAFKA_BROKER_SETTINGS_FILENAME".tmp)
  replaceString="log.retention.minutes=$RETENTION_INTERVAL"

  sed -i -e 's|'"$searchString"'|'"$replaceString"'|g' "$KAFKA_BROKER_SETTINGS_FILENAME".tmp

  cp "$KAFKA_BROKER_SETTINGS_FILENAME".tmp "$KAFKA_BROKER_SETTINGS_FILENAME"

  # Clean-up.
  rm -f "$KAFKA_BROKER_SETTINGS_FILENAME".tmp
  rm -f "$KAFKA_BROKER_SETTINGS_FILENAME".tmp-e
}

# Saves the Zookeeper settings file.
function saveZookeeperSettings() {
  ZOOKEEPER_SETTINGS_FILENAME=kafka/zookeeper/etc/settings.conf

  # Check if the settings file exists. If don't, create it with a base content.
  if [ ! -f "$ZOOKEEPER_SETTINGS_FILENAME" ]; then
    cp -f "$ZOOKEEPER_SETTINGS_FILENAME.original" "$ZOOKEEPER_SETTINGS_FILENAME"
  fi
}

# Saves the ingress settings file.
function saveIngressSettings() {
  INGRESS_SETTINGS_FILENAME=ingress/etc/nginx/http.d/settings.conf
  INGRESS_SETTINGS_OBJECT_FILENAME=ingress/htdocs/settings.js

  # Check if it will use an external storage.
  if [ "$USE_EXTERNAL_STORAGE" == "true" ]; then
    cp -f ingress/etc/nginx/templates/externalStorage.conf "$INGRESS_SETTINGS_FILENAME"

    echo "var dashboardsUrl = \"$EXTERNAL_STORAGE_URL\";" > $INGRESS_SETTINGS_OBJECT_FILENAME
  else
    cp -f ingress/etc/nginx/templates/defaultStorage.conf "$INGRESS_SETTINGS_FILENAME"
    cp -f "$INGRESS_SETTINGS_OBJECT_FILENAME".original "$INGRESS_SETTINGS_OBJECT_FILENAME"
  fi
}

# Save the exporter settings file.
function saveExporterSettings() {
  EXPORTER_SETTINGS_FILENAME=exporter/etc/settings.conf

  # Define the input source.
  echo "input {" > "$EXPORTER_SETTINGS_FILENAME".tmp
  echo -e "\tkafka {" >> "$EXPORTER_SETTINGS_FILENAME".tmp
  echo -e "\t\tclient_id => \"exporter\"" >> "$EXPORTER_SETTINGS_FILENAME".tmp
  echo -e "\t\tbootstrap_servers => \"kafka-broker:9092\"" >> "$EXPORTER_SETTINGS_FILENAME".tmp
  echo -e "\t\ttopics => \"eventsProcessed\"" >> "$EXPORTER_SETTINGS_FILENAME".tmp
  echo -e "\t}" >> "$EXPORTER_SETTINGS_FILENAME".tmp
  echo "}" >> "$EXPORTER_SETTINGS_FILENAME".tmp
  echo >> "$EXPORTER_SETTINGS_FILENAME".tmp

  # Define how to filter the input.
  cat exporter/etc/templates/"$STORAGE_FORMAT_ID"-filter.conf >> "$EXPORTER_SETTINGS_FILENAME".tmp

  echo >> "$EXPORTER_SETTINGS_FILENAME".tmp
  echo >> "$EXPORTER_SETTINGS_FILENAME".tmp

  # Define the output source.
  if [ "$USE_EXTERNAL_STORAGE" == "true" ]; then
    # Check for custom storage parameters. If don't use the selected storage template.
    if [ -z "$EXTERNAL_STORAGE_OUTPUT" ]; then
      cat exporter/etc/templates/"$STORAGE_TYPE_ID"-output.conf >> "$EXPORTER_SETTINGS_FILENAME".tmp
    else
      echo "$EXTERNAL_STORAGE_OUTPUT" >> "$EXPORTER_SETTINGS_FILENAME".tmp
    fi
  else
    # Define the local storage parameters.
    echo "output {" >> "$EXPORTER_SETTINGS_FILENAME".tmp
    echo -e "\topensearch {" >> "$EXPORTER_SETTINGS_FILENAME".tmp
    echo -e "\t\thosts => [\"http://opensearch:9200\"]" >> "$EXPORTER_SETTINGS_FILENAME".tmp
    echo -e "\t\tindex => \"akamai-siem\"" >> "$EXPORTER_SETTINGS_FILENAME".tmp
    echo -e "\t}" >> "$EXPORTER_SETTINGS_FILENAME".tmp
    echo "}" >> "$EXPORTER_SETTINGS_FILENAME".tmp
    echo >> "$EXPORTER_SETTINGS_FILENAME".tmp
  fi

  cp "$EXPORTER_SETTINGS_FILENAME".tmp "$EXPORTER_SETTINGS_FILENAME"

  # Clean-up.
  rm -f "$EXPORTER_SETTINGS_FILENAME".tmp
}

# Save the converter settings file.
function saveConverterSettings() {
  CONVERTER_SETTINGS_FILENAME=converter/src/main/resources/etc/settings.json

  # Create the settings file using a JSON format.
  echo "{" > "$CONVERTER_SETTINGS_FILENAME".tmp
  echo "\"storageFormatId\": \"$STORAGE_FORMAT_ID\"," >> "$CONVERTER_SETTINGS_FILENAME".tmp
  echo "\"workers\": $WORKERS," >> "$CONVERTER_SETTINGS_FILENAME".tmp
  echo "\"kafka\": {" >> "$CONVERTER_SETTINGS_FILENAME".tmp
  echo "\"brokers\": [ \"kafka-broker:9092\" ]," >> "$CONVERTER_SETTINGS_FILENAME".tmp
  echo "\"inboundTopic\": \"eventsCollected\"," >> "$CONVERTER_SETTINGS_FILENAME".tmp
  echo "\"outboundTopic\": \"eventsProcessed\"" >> "$CONVERTER_SETTINGS_FILENAME".tmp
  echo "}" >> "$CONVERTER_SETTINGS_FILENAME".tmp
  echo "}" >> "$CONVERTER_SETTINGS_FILENAME".tmp

  # Indent the settings file.
  $JQ_CMD -r . "$CONVERTER_SETTINGS_FILENAME".tmp > "$CONVERTER_SETTINGS_FILENAME"

  # Clean-up.
  rm -f "$CONVERTER_SETTINGS_FILENAME".tmp
}

# Save the consumer settings file.
function saveConsumerSettings() {
  CONSUMER_SETTINGS_FILENAME=consumer/etc/settings.json

  # Create the settings file using a JSON format.
  echo "{" > "$CONSUMER_SETTINGS_FILENAME".tmp
  echo "\"scheduler\": \"scheduler\"," >> "$CONSUMER_SETTINGS_FILENAME".tmp
  echo "\"inputQueue\": \"jobsToBeProcessed\"," >> "$CONSUMER_SETTINGS_FILENAME".tmp
  echo "\"outputQueue\": \"eventsToBeStored\"," >> "$CONSUMER_SETTINGS_FILENAME".tmp
  echo "\"edgercFilename\": \"/home/consumer/etc/.edgerc\"," >> "$CONSUMER_SETTINGS_FILENAME".tmp
  echo "\"edgercSectionName\": \"$EDGEGRID_SECTION_NAME\"," >> "$CONSUMER_SETTINGS_FILENAME".tmp
  echo "\"configsIds\": \"$CONFIGS_IDS\"" >> "$CONSUMER_SETTINGS_FILENAME".tmp
  echo "}" >> "$CONSUMER_SETTINGS_FILENAME".tmp

  # Indent the settings file.
  $JQ_CMD -r . "$CONSUMER_SETTINGS_FILENAME".tmp > "$CONSUMER_SETTINGS_FILENAME"

  # Clean-up.
  rm -f "$CONSUMER_SETTINGS_FILENAME".tmp
}

# Save the credentials.
function saveCredentials() {
  echo "[$EDGEGRID_SECTION_NAME]" > "$CREDENTIALS_FILENAME"

  if [ -n "$EDGEGRID_ACCOUNT_KEY" ]; then
    echo "account_key = $EDGEGRID_ACCOUNT_KEY" >> "$CREDENTIALS_FILENAME"
  fi

  echo "host = $EDGEGRID_HOST" >> "$CREDENTIALS_FILENAME"
  echo "access_token = $EDGEGRID_ACCESS_TOKEN" >> "$CREDENTIALS_FILENAME"
  echo "client_token = $EDGEGRID_CLIENT_TOKEN" >> "$CREDENTIALS_FILENAME"
  echo "client_secret = $EDGEGRID_CLIENT_SECRET" >> "$CREDENTIALS_FILENAME"

  echo >> "$CREDENTIALS_FILENAME"

  echo "[$LINODE_SECTION_NAME]" >> "$CREDENTIALS_FILENAME"
  echo "token = $LINODE_TOKEN" >> "$CREDENTIALS_FILENAME"

  echo >> "$CREDENTIALS_FILENAME"

  echo "[$AUTH0_SECTION_NAME]" >> "$CREDENTIALS_FILENAME"
  echo "domain = $AUTH0_DOMAIN" >> "$CREDENTIALS_FILENAME"
  echo "api_id = $AUTH0_API_ID" >> "$CREDENTIALS_FILENAME"
  echo "api_secret = $AUTH0_API_SECRET" >> "$CREDENTIALS_FILENAME"
  echo "client_id = $AUTH0_CLIENT_ID" >> "$CREDENTIALS_FILENAME"
  echo "client_secret = $AUTH0_CLIENT_SECRET" >> "$CREDENTIALS_FILENAME"
}

# Save the settings.
function saveSettings() {
  # Create the settings file using a JSON format.
  saveConsumerSettings
  saveConverterSettings
  saveExporterSettings
  saveIngressSettings
  saveKafkaBrokerSettings
  saveOAuth2Settings
  saveProcessorKafkaSettings
  saveSchedulerSettings
  saveSchedulerQueuesSettings

  echo "{" > "$SETTINGS_FILENAME".tmp
  echo "\"dataCollection\": {" >> "$SETTINGS_FILENAME".tmp
  echo "\"jobsPerMinute\": $JOBS_PER_MINUTE, " >> "$SETTINGS_FILENAME".tmp
  echo "\"maxEventsPerJob\": $MAX_EVENTS_PER_JOB, " >> "$SETTINGS_FILENAME".tmp
  echo "\"maxEventsCollectionSize\": $MAX_EVENTS_COLLECTION_SIZE, " >> "$SETTINGS_FILENAME".tmp
  echo "\"configsIds\": \"$CONFIGS_IDS\"" >> "$SETTINGS_FILENAME".tmp
  echo "}," >> "$SETTINGS_FILENAME".tmp
  echo "\"dataStorage\": {" >>  "$SETTINGS_FILENAME".tmp
  echo "\"useExternalStorage\": $USE_EXTERNAL_STORAGE, " >> "$SETTINGS_FILENAME".tmp

  if [ "$USE_EXTERNAL_STORAGE" == "true" ]; then
    echo "\"externalStorageUrl\": \"$EXTERNAL_STORAGE_URL\", " >> "$SETTINGS_FILENAME".tmp
    echo "\"storageTypeId\": \"$STORAGE_TYPE_ID\", " >> "$SETTINGS_FILENAME".tmp
  fi

  echo "\"storageFormatId\": \"$STORAGE_FORMAT_ID\"," >> "$SETTINGS_FILENAME".tmp
  echo "\"workers\": $WORKERS," >> "$SETTINGS_FILENAME".tmp
  echo "\"retentionInterval\": $RETENTION_INTERVAL" >> "$SETTINGS_FILENAME".tmp
  echo "}," >> "$SETTINGS_FILENAME".tmp
  echo "\"infrastructure\": {" >> "$SETTINGS_FILENAME".tmp
  echo "\"nodeTypeId\": \"$NODE_TYPE_ID\"," >> "$SETTINGS_FILENAME".tmp
  echo "\"nodeCount\": $NODE_COUNT," >> "$SETTINGS_FILENAME".tmp
  echo "\"regionId\": \"$REGION_ID\"" >> "$SETTINGS_FILENAME".tmp
  echo "}" >> "$SETTINGS_FILENAME".tmp
  echo "}" >> "$SETTINGS_FILENAME".tmp

  # Indent the settings file.
  $JQ_CMD -r . "$SETTINGS_FILENAME".tmp > "$SETTINGS_FILENAME"

  # Clean-up.
  rm -f "$SETTINGS_FILENAME".tmp
}

# Check if the credentials were defined properly.
function checkCredentials() {
  # Check for the auth0.com credentials.
  if [ -z "$AUTH0_DOMAIN" ] || [ -z "$AUTH0_API_ID" ] || [ -z "$AUTH0_API_SECRET" ] || [ -z "$AUTH0_CLIENT_ID" ] || [ -z "$AUTH0_CLIENT_SECRET" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nThe auth0.com credentials were NOT defined!\n\nPlease go to SECURITY settings!" 8 50

      menuDialog
    else
      echo "The auth0.com credentials were NOT defined!"

      exit 1
    fi
  # Check for the Akamai Connected Cloud token.
  elif [ -z "$LINODE_TOKEN" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nThe Akamai Connected Cloud credentials were NOT defined!\n\nPlease go to SECURITY settings!" 9 60

      menuDialog
    else
      echo "The Akamai Connected Cloud credentials were NOT defined!"

      exit 1
    fi
  # Check for the Akamai EdgeGrid credentials.
  elif [ -z "$EDGEGRID_HOST" ] || [ -z "$EDGEGRID_ACCESS_TOKEN" ] || [ -z "$EDGEGRID_CLIENT_TOKEN" ] || [ -z "$EDGEGRID_CLIENT_SECRET" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nThe Akamai EdgeGrid credentials were NOT defined!\n\nPlease go to SECURITY settings!" 9 50

      menuDialog
    else
      echo "The Akamai EdgeGrid credentials were NOT defined!"

      exit 1
    fi
  fi
}

# Check if the settings were defined properly.
function checkSettings() {
  # Check for the data collection parameters.
  if [ -z "$JOBS_PER_MINUTE" ] || [ -z "$MAX_EVENTS_PER_JOB" ] || [ -z "$MAX_EVENTS_COLLECTION_SIZE" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nThe data collection parameters were NOT defined!\n\nPlease go to DATA COLLECTION settings!" 9 50

      menuDialog
    else
      echo "The data collection parameters were NOT defined!"

      exit 1
    fi
  elif [ -z "$CONFIGS_IDS" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nThe Akamai Security Configurations were NOT defined!\n\nPlease go to DATA COLLECTION settings!" 9 60

      menuDialog
    else
      echo "The Akamai Security Configurations to be collected were NOT defined!"

      exit 1
    fi
  # Check for the data storage parameters.
  elif [ -z "$USE_EXTERNAL_STORAGE" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must define where the data will be stored!\n\nPlease go to DATA STORAGE settings!" 9 50

      menuDialog
    else
      echo "You must define where the data will be stored!"

      exit 1
    fi
  elif [ "$USE_EXTERNAL_STORAGE" == "true" ] && [ -z "$STORAGE_TYPE_ID" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must define the data storage type!\n\nPlease go to DATA STORAGE settings!" 9 50

      menuDialog
    else
      echo "You must define the data storage type!"

      exit 1
    fi
  elif [ -z "$STORAGE_FORMAT_ID" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must define the data storage format!\n\nPlease go to DATA STORAGE settings!" 9 50

      menuDialog
    else
      echo "You must define the data storage format!"

      exit 1
    fi
  elif [ -z "$WORKERS" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must define the number of workers that will be used to store the data!\n\nPlease go to DATA STORAGE settings!" 10 70

      menuDialog
    else
      echo "You must define the number of workers that will be used to store the data!"

      exit 1
    fi
  elif [ -z "$RETENTION_INTERVAL" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must define how the data will be temporarily persisted in case of storage unavailability!\n\nPlease go to DATA STORAGE settings!" 10 75

      menuDialog
    else
      echo "You must define how the data will be temporarily persisted in case of storage unavailability!"

      exit 1
    fi
  # Check for the deploy parameters.
  elif [ -z "$NODE_TYPE_ID" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must define the infrastructure node type!\n\nPlease go to INFRASTRUCTURE settings!" 9 50

      menuDialog
    else
      echo "You must define the infrastructure node type!"

      exit 1
    fi
  elif [ -z "$REGION_ID" ]; then
    if [ -z "$UNATTENDED" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must define the infrastructure region!\n\nPlease go to INFRASTRUCTURE settings!" 9 50

      menuDialog
    else
      echo "You must define the infrastructure region!"

      exit 1
    fi
  fi
}

# Open the dialog to select the Akamai Connected Cloud region.
function regionSelectionDialog() {
  REGIONS_FILENAME=/tmp/.linode-regions

  # Call the Akamai Connected Cloud API to list the available regions.
  $CURL_CMD -s -H "Authorization: Bearer $LINODE_TOKEN" https://api.linode.com/v4/regions | $JQ_CMD -r '.data[] | [ .id, .label ] | @csv' > "$REGIONS_FILENAME"

  # Prepare the dialog options based on the result of the API call.
  options=()
  i=0

  while IFS=, read -r id name
  do
    options[$i]="$(echo "$id" | sed 's/\"//g')"

    ((i++))

    options[$i]=$(echo "$name" | sed 's/\"//g')

    ((i++))
  done < "$REGIONS_FILENAME"

  # Clean-up.
  rm -f "$REGIONS_FILENAME"

  # Open the dialog.
  while "true"; do
    REGION_ID=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                            --title "$TITLE" \
                            --default-item "$REGION_ID" \
                            --menu "\nPlease select the region that fits with your needs!" 0 0 10 \
                            "${options[@]}" 2>&1 > /dev/tty)

    # Check / validate the selected option.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$REGION_ID" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the region!" 7 45
    else
      break
    fi
  done
}

# Open the dialog to select the Akamai Connected Cloud node type.
function nodeTypeSelectionDialog() {
  NODE_TYPES_FILENAME=/tmp/.linode-node-types

  # Call the Akamai Connected Cloud API to list the available node types.
  $CURL_CMD -s -H "Authorization: Bearer $LINODE_TOKEN" https://api.linode.com/v4/linode/types | $JQ_CMD -r '.data[] | [ .id, .label, .vcpus, .memory, .disk, .transfer ] | @csv' > "$NODE_TYPES_FILENAME"

  # Prepare the dialog options based on the result of the API call.
  options=()
  i=0

  while IFS=, read -r id name vcpus memory disk transfer
  do
    options[$i]="$(echo "$id" | sed 's/\"//g')"

    ((i++))

    options[$i]=$(echo "$name (vCPUs: $vcpus Memory (MB): $memory Disk (MB): $disk Egress (MB): $transfer)" | sed 's/\"//g')

    ((i++))
  done < "$NODE_TYPES_FILENAME"

  # Clean-up.
  rm -f "$NODE_TYPES_FILENAME"

  # Open the dialog.
  while "true"; do
    NODE_TYPE_ID=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                               --title "$TITLE" \
                               --default-item "$NODE_TYPE_ID" \
                               --menu "\nPlease select the node type that fits with your needs!" 0 0 10 \
                               "${options[@]}" 2>&1 > /dev/tty)

    # Check / validate the selected option.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$NODE_TYPE_ID" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the node type!" 7 45
    else
      break
    fi
  done
}

# Open the dialog to deploy the connector in the Akamai Connected Cloud infrastructure based on the defined parameters.
function deployDialog() {
  TITLE="DEPLOY"
  CURRENT_MENU="6. DEPLOY"
  DEFINE_INFRASTRUCTURE=false

  # Check if the Akamai Connected Cloud infrastructure is already defined.
  if [ -z "$NODE_TYPE_ID" ] || [ -z "$REGION_ID" ]; then
    DEFINE_INFRASTRUCTURE=true
  fi

  if [ "$DEFINE_INFRASTRUCTURE" = "true" ]; then
    nodeTypeSelectionDialog
    regionSelectionDialog
  else
    # Check if the user wants to change the current Akamai Connected Cloud infrastructure.
    $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                --title "$TITLE" \
                --yesno "\nThe connector infrastructure is already defined! \n\nDo you want to change it?" 9 55

    if [ $? -ne 1 ]; then
      nodeTypeSelectionDialog
      regionSelectionDialog
    fi
  fi

  checkCredentials
  saveCredentials
  checkSettings
  saveSettings

  # Confirm the deployment.
  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --yesno "\nDo you want to proceed the deployment?" 7 45

  # Execute the deployment if it was confirmed.
  if [ $? -ne 1 ]; then
    deploy
  fi
}

# Open the dialog to define the data retention interval.
function retentionIntervalDialog() {
  # Open the dialog.
  while "true"; do
    RETENTION_INTERVAL=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                     --title "$TITLE" \
                                     --inputbox "\nWe use a temporary persistence to avoid data loss in case of the storage unavailability.\n\nPlease enter the retention interval (in minutes) of this temporary persistence:" 13 75 "$RETENTION_INTERVAL" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$RETENTION_INTERVAL" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the retention interval (in minutes) greater than 0!" 8 60
    elif [ "$RETENTION_INTERVAL" -lt 0 ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the retention interval (in minutes) greater than 0!" 8 60
    else
      break
    fi
  done
}

# Open the dialog to define the data storage workers.
function workersDialog() {
  # Open the dialog to define the number of workers.
  while "true"; do
    WORKERS=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                          --title "$TITLE" \
                          --inputbox "\nIn order to store the collected data, we need to define the number of workers. More workers, the faster is the storage but higher the processing consumption.\n\nPlease enter the number of workers based on what fits with your needs:" 14 75 "$WORKERS" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$WORKERS" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the number of workers greater than 0!" 7 60
    elif [ "$WORKERS" -lt 0 ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the number of workers greater than 0!" 7 60
    else
      break
    fi
  done
}

# Open the dialog to select the data storage format.
function storageFormatSelectionDialog() {
  # Open the dialog.
  STORAGE_FORMAT_ID=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                  --title "$TITLE" \
                                  --default-item "$STORAGE_FORMAT_ID" \
                                  --menu "\nPlease select the storage format:" 0 0 0 \
                                  "json" "JSON" \
                                  "cef" "CEF (Common Event Format)" 2>&1 > /dev/tty)

  # Check / validate the selected option.
  if [ $? -eq 1 ]; then
    menuDialog
  fi
}

# Open the dialog to define the external storage url.
function externalStorageUrlDialog() {
  while "true"; do
    EXTERNAL_STORAGE_URL=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                      --title "$TITLE" \
                                      --inputbox "\nPlease enter the external storage URL:" 9 60 "$EXTERNAL_STORAGE_URL" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$EXTERNAL_STORAGE_URL" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the external storage URL!" 7 60
    else
      break
    fi
  done

  externalStorageOutputDialog
}

# Open the dialog to define the external storage parameters.
function externalStorageOutputDialog() {
  EXTERNAL_STORAGE_FILENAME=exporter/etc/templates/"$STORAGE_TYPE_ID"-output.conf

  # Open the dialog.
  while "true"; do
    EXTERNAL_STORAGE_OUTPUT=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                          --title "$TITLE" \
                                          --editbox "$EXTERNAL_STORAGE_FILENAME" 20 75 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$EXTERNAL_STORAGE_OUTPUT" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nPlease enter the selected storage parameters!" 7 50
    else
      break
    fi
  done
}

# Open the dialog to select the external storage.
function externalStorageTypeDialog() {
  # Open the dialog.
  STORAGE_TYPE_ID=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                --title "$TITLE" \
                                --default-item "$STORAGE_TYPE_ID" \
                                --menu "\nPlease select the external storage type:" 0 0 5 \
                                "splunk" "Splunk" \
                                "sentinel" "Microsoft Sentinel" \
                                "elasticsearch" "Elasticsearch" \
                                "opensearch" "Amazon Opensearch" \
                                "s3" "Object Storage (AWS S3 Compliant)" \
                                "kafka" "Apache Kafka" \
                                "rsyslog" "Remote SysLog" \
                                "endpoint" "Custom HTTP(s) endpoint" 2>&1 > /dev/tty)

  # Check / validate the selected option.
  if [ $? -eq 1 ]; then
    menuDialog
  else
    externalStorageUrlDialog
  fi
}

# Open the dialog to select if the connector will use an external storage.
function dataStorageDialog() {
  TITLE="DATA STORAGE"
  CURRENT_MENU="3. DATA STORAGE"

  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --yesno "\nDo you want to use the default storage?" 7 45

  # Check / validate the selected option.
  if [ $? -ne 1 ]; then
    USE_EXTERNAL_STORAGE=false
  else
    USE_EXTERNAL_STORAGE=true

    externalStorageTypeDialog
  fi

  storageFormatSelectionDialog
  workersDialog
  retentionIntervalDialog

  # The minimum parameters were defined. Now you can process to deploy it in the Akamai Connected Cloud infrastructure.
  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --msgbox "\nThe parameters were defined successfully!\n\nNow you can deploy it in Akamai Connected Cloud!" 9 55

  deployDialog
}

# Open the dialog to select the Akamai Security Configurations to be used in the data connection.
function securityConfigurationsSelectionDialog() {
  # Open the dialog.
  while "true"; do
    CONFIGS_IDS=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                              --title "$TITLE" \
                              --inputbox "\nPlease enter the Akamai Security Configurations (separated by comma) that you want to collect the data:" 10 75 "$CONFIGS_IDS" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$CONFIGS_IDS" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify at least 1 Akamai Security Configuration!" 7 60
    else
      break
    fi
  done
}

# Open the dialog to define the events collection parameters.
function eventsCollectionDialog() {
  # Open the dialog.
  while "true"; do
    JOBS_PER_MINUTE=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                     --title "$TITLE" \
                                     --inputbox "\nPlease enter the number of jobs per minute:" 10 70 "$JOBS_PER_MINUTE" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$JOBS_PER_MINUTE" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify a valid number!" 7 60
    elif [ "$JOBS_PER_MINUTE" -lt 1 ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify a valid number!" 7 60
    else
      break
    fi
  done

  # Open the dialog.
  while "true"; do
    MAX_EVENTS_PER_JOB=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                     --title "$TITLE" \
                                     --inputbox "\nPlease enter the maximum number of events per job (1 - 10000) within a minute:" 10 70 "$MAX_EVENTS_PER_JOB" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$MAX_EVENTS_PER_JOB" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify a valid number between 1 and 10000!" 7 60
    elif [ "$MAX_EVENTS_PER_JOB" -lt 1 ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify a valid number between 1 and 10000!" 7 60
    elif [ "$MAX_EVENTS_PER_JOB" -gt 10000 ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify a valid number between 1 and 10000!" 7 60
    else
      break
    fi
  done

  # Open the dialog.
  while "true"; do
    MAX_EVENTS_COLLECTION_SIZE=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                             --title "$TITLE" \
                                             --inputbox "\nPlease enter the size (in bytes) of the events per job:" 9 60 "$MAX_EVENTS_COLLECTION_SIZE" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$MAX_EVENTS_COLLECTION_SIZE" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify a valid number greater than 0!" 7 55
    elif [ "$MAX_EVENTS_COLLECTION_SIZE" -lt 0 ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify a valid number greater than 0!" 7 55
    else
      break
    fi
  done
}

# Open the dialog to define the data collection parameters.
function dataCollectionDialog() {
  TITLE="DATA COLLECTION"
  CURRENT_MENU="2. DATA COLLECTION"

  eventsCollectionDialog
  securityConfigurationsSelectionDialog

  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --msgbox "\nThe parameters were defined successfully!\n\nNow lets define the DATA STORAGE settings!" 9 50

  dataStorageDialog
}

# Open the dialog to define the Akamai EdgeGrid credentials.
function edgeGridCredentialsDialog() {
  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --msgbox "\nThe connector uses the Akamai SIEM API, so we need to define the credentials to be able to fetch the data." 8 80

  # Open the dialog to define the Akamai account Key.
  EDGEGRID_ACCOUNT_KEY=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                     --title "$TITLE" \
                                     --inputbox "\nPlease enter the Akamai EdgeGrid account key:" 9 55 "$EDGEGRID_ACCOUNT_KEY" 2>&1 > /dev/tty)

  # Check / validate the input.
  if [ $? -eq 1 ]; then
    menuDialog
  fi

  # Open the dialog to define the Akamai EdgeGrid host.
  while "true"; do
    EDGEGRID_HOST=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                --title "$TITLE" \
                                --inputbox "\nPlease enter the Akamai EdgeGrid host:" 9 55 "$EDGEGRID_HOST" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$EDGEGRID_HOST" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the Akamai EdgeGrid Host!" 7 50
    else
      break
    fi
  done

  # Open the dialog to define the Akamai EdgeGrid access token.
  while "true"; do
    EDGEGRID_ACCESS_TOKEN=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                        --title "$TITLE" \
                                        --inputbox "\nPlease enter the Akamai EdgeGrid access token:" 9 55 "$EDGEGRID_ACCESS_TOKEN" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$EDGEGRID_ACCESS_TOKEN" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the Akamai EdgeGrid access token!" 7 55
    else
      break
    fi
  done

  # Open the dialog to define the Akamai EdgeGrid client token.
  while "true"; do
    EDGEGRID_CLIENT_TOKEN=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                        --title "$TITLE" \
                                        --inputbox "\nPlease enter the Akamai EdgeGrid client token:" 9 55 "$EDGEGRID_CLIENT_TOKEN" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$EDGEGRID_CLIENT_TOKEN" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the Akamai EdgeGrid client token!" 7 55
    else
      break
    fi
  done

  # Open the dialog to define the Akamai EdgeGrid client secret.
  while "true"; do
    EDGEGRID_CLIENT_SECRET=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                         --title "$TITLE" \
                                         --inputbox "\nPlease enter the Akamai EdgeGrid client secret:" 9 55 "$EDGEGRID_CLIENT_SECRET" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$EDGEGRID_CLIENT_SECRET" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the Akamai EdgeGrid client secret!" 7 55
    else
      break
    fi
  done

  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --msgbox "\nThe credentials were defined successfully!\n\nNow lets define the DATA COLLECTION settings!" 9 55

  dataCollectionDialog
}

# Open the dialog to define the Akamai Connected Cloud credentials.
function linodeCredentialsDialog() {
  TITLE="CREDENTIALS"

  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --msgbox "\nThe connector will be deployed in Akamai Connected Cloud, so we need to define the credentials to be able to provision the infrastructure." 8 80

  # Open the dialog.
  while "true"; do
    LINODE_TOKEN=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                               --title "$TITLE" \
                               --inputbox "\nPlease enter the Akamai Connected Cloud token:" 9 55 "$LINODE_TOKEN" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$LINODE_TOKEN" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the Akamai Connected Cloud token!" 7 55
    else
      break
    fi
  done
}

# Open the dialog to define the OAuth2 settings.
function oauth2Dialog() {
  $DIALOG_CMD --backtitle "$MAIN_TITLE" \
              --title "$TITLE" \
              --msgbox "\nNow, we'll set up the authentication with OAuth2 protocol in auth0.com!\n\nPlease create your account and application before start!" 9 75

  # Open the dialog to define the auth0.com domain.
  while "true"; do
    AUTH0_DOMAIN=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                               --title "$TITLE" \
                               --inputbox "\nPlease enter the auth0.com domain:" 9 50 "$AUTH0_DOMAIN" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$AUTH0_DOMAIN" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the auth0.com API domain!" 7 50
    else
      break
    fi
  done

  # Open the dialog to define the auth0.com API ID.
  while "true"; do
    AUTH0_API_ID=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                               --title "$TITLE" \
                               --inputbox "\nPlease enter the auth0.com API ID:" 9 50 "$AUTH0_API_ID" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$AUTH0_API_ID" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the auth0.com API ID!" 7 50
    else
      break
    fi
  done

  # Open the dialog to define the auth0.com API secret.
  while "true"; do
    AUTH0_API_SECRET=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                   --title "$TITLE" \
                                   --inputbox "\nPlease enter the auth0.com API secret:" 9 50 "$AUTH0_API_SECRET" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$AUTH0_API_SECRET" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the auth0.com API secret!" 7 50
    else
      break
    fi
  done

  # Open the dialog to define the auth0.com client ID.
  while "true"; do
    AUTH0_CLIENT_ID=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                  --title "$TITLE" \
                                  --inputbox "\nPlease enter the auth0.com client ID:" 9 50 "$AUTH0_CLIENT_ID" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$AUTH0_CLIENT_ID" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the auth0.com client ID!" 7 50
    else
      break
    fi
  done

  # Open the dialog to define the auth0.com client secret.
  while "true"; do
    AUTH0_CLIENT_SECRET=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                      --title "$TITLE" \
                                      --inputbox "\nPlease enter the auth0.com client secret:" 9 50 "$AUTH0_CLIENT_SECRET" 2>&1 > /dev/tty)

    # Check / validate the input.
    if [ $? -eq 1 ]; then
      menuDialog
    elif [ -z "$AUTH0_CLIENT_SECRET" ]; then
      $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                  --title "$TITLE" \
                  --msgbox "\nYou must specify the auth0.com client secret!" 7 50
    else
      break
    fi
  done
}

# Open the dialog to define the security parameters.
function securityDialog() {
  TITLE="CREDENTIALS"
  CURRENT_MENU="1. SECURITY"

  oauth2Dialog
  linodeCredentialsDialog
  edgeGridCredentialsDialog
}

# Open the menu dialog.
function menuDialog() {
  if [ -z "$UNATTENDED" ]; then
    TITLE="LET'S START!"
    OPTION=$($DIALOG_CMD --backtitle "$MAIN_TITLE" \
                         --title "$TITLE" \
                         --default-item "$CURRENT_MENU" \
                         --menu "\nPlease select an option to continue:" 0 90 7 \
                         "1. SECURITY" "Define the security settings to collect and store the data." \
                         "2. DATA COLLECTION" "Define the data collection settings." \
                         "3. DATA STORAGE" "Define the data storage settings." \
                         "4. DEPLOY" "Deploy it in the Akamai Connected Cloud." \
                         "5. UNDEPLOY" "Undeploy it from the Akamai Connected Cloud." \
                         "6. LICENSE" "Know more about licensing." \
                         "0. EXIT" "Exit this setup." 2>&1 > /dev/tty)

    # Check / validate the selected option.
    if [ $? -eq 1 ]; then
      clear

      exit 0
    else
      # Execute the selected option.
      case $OPTION in
        "1. SECURITY")
          securityDialog
          menuDialog
          ;;
        "2. DATA COLLECTION")
          dataCollectionDialog
          menuDialog
          ;;
        "3. DATA STORAGE")
        sto
          dataStorageDialog
          menuDialog
          ;;
        "4. DEPLOY")
          deployDialog
          infrastructureDialog
          menuDialog
          ;;
        "5. UNDEPLOY")
          undeploy
          menuDialog
          ;;
        "6. LICENSE")
          licenseDialog
          menuDialog
          ;;
        "0. EXIT")
          clear

          exit 0
          logout

          ;;
      esac
    fi
  fi
}

# Check the requirements for setup.
function checkRequirementsDialog() {
  if [ -z "$UNATTENDED" ]; then
    TITLE="CHECKING REQUIREMENTS"
    BINARIES="curl jq terraform kubectl"

    eval "BINARIES=($BINARIES)"

    counter=0
    length=${#BINARIES[@]}

    # Check if required binaries are installed in the OS.
    for BINARY in "${BINARIES[@]}"
    do
      BINARY_CMD=$(which "$BINARY")

      sleep 0.10

      # Check if it was found. If don't, exit the setup.
      if [ ! -f "$BINARY_CMD" ]; then
        $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                    --title "$TITLE" \
                    --msgbox "\n$BINARY is not installed! Please install it first to continue!" 7 70 > /dev/tty

        clear

        exit 1
      else
        counter=$((counter + (100 / length)))

        echo $counter | $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                                    --title "$TITLE" \
                                    --gauge "\nFinding required software installation..." 8 45
      fi
    done

    sleep 0.10

    $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                --title "$TITLE" \
                --msgbox "\nAll requirements found!" 7 35
  fi
}

# Opens the welcome dialog.
function welcomeDialog() {
  if [ -z "$UNATTENDED" ]; then
    MAIN_TITLE="Akamai SIEM Connector"
    TITLE="WELCOME!"
    ABOUT=$(cat about.txt)

    $DIALOG_CMD --backtitle "$MAIN_TITLE" \
                --title "$TITLE" \
                --msgbox "$ABOUT" 21 90
  fi
}

# Loads the credentials.
function loadCredentials() {
  AUTH0_SECTION_NAME=auth0

  if [ -z "$AUTH0_DOMAIN" ]; then
    AUTH0_DOMAIN=$(getCredential "$AUTH0_SECTION_NAME" "domain")
  fi

  if [ -z "$AUTH0_API_ID" ]; then
    AUTH0_API_ID=$(getCredential "$AUTH0_SECTION_NAME" "api_id")
  fi

  if [ -z "$AUTH0_API_SECRET" ]; then
    AUTH0_API_SECRET=$(getCredential "$AUTH0_SECTION_NAME" "api_secret")
  fi

  if [ -z "$AUTH0_CLIENT_ID" ]; then
    AUTH0_CLIENT_ID=$(getCredential "$AUTH0_SECTION_NAME" "client_id")
  fi

  if [ -z "$AUTH0_CLIENT_SECRET" ]; then
    AUTH0_CLIENT_SECRET=$(getCredential "$AUTH0_SECTION_NAME" "client_secret")
  fi

  EDGEGRID_SECTION_NAME="edgegrid"

  if [ -z "$EDGEGRID_ACCOUNT_KEY" ]; then
    EDGEGRID_ACCOUNT_KEY=$(getCredential "$EDGEGRID_SECTION_NAME" "account_key")
  fi

  if [ -z "$EDGEGRID_HOST" ]; then
    EDGEGRID_HOST=$(getCredential "$EDGEGRID_SECTION_NAME" "host")
  fi

  if [ -z "$EDGEGRID_ACCESS_TOKEN" ]; then
    EDGEGRID_ACCESS_TOKEN=$(getCredential "$EDGEGRID_SECTION_NAME" "access_token")
  fi

  if [ -z "$EDGEGRID_CLIENT_TOKEN" ]; then
    EDGEGRID_CLIENT_TOKEN=$(getCredential "$EDGEGRID_SECTION_NAME" "client_token")
  fi

  if [ -z "$EDGEGRID_CLIENT_SECRET" ]; then
    EDGEGRID_CLIENT_SECRET=$(getCredential "$EDGEGRID_SECTION_NAME" "client_secret")
  fi

  LINODE_SECTION_NAME="linode"

  if [ -z "$LINODE_TOKEN" ]; then
    LINODE_TOKEN=$(getCredential "$LINODE_SECTION_NAME" "token")
  fi
}

# Load the settings.
function loadSettings() {
  if [ -z "$JOBS_PER_MINUTE" ]; then
    JOBS_PER_MINUTE=$(getSetting "dataCollection.jobsPerMinute")

    if [ -z "$JOBS_PER_MINUTE" ]; then
      JOBS_PER_MINUTE=1
    fi
  fi

  if [ -z "$MAX_EVENTS_PER_JOB" ]; then
    MAX_EVENTS_PER_JOB=$(getSetting "dataCollection.maxEventsPerJob")

    if [ -z "$MAX_EVENTS_PER_JOB" ]; then
      MAX_EVENTS_PER_JOB=60
    fi
  fi

  if [ -z "$MAX_EVENTS_COLLECTION_SIZE" ]; then
    MAX_EVENTS_COLLECTION_SIZE=$(getSetting "dataCollection.maxEventsCollectionSize")

    if [ -z "$MAX_EVENTS_COLLECTION_SIZE" ]; then
      MAX_EVENTS_COLLECTION_SIZE=16777216
    fi
  fi

  if [ -z "$CONFIGS_IDS" ]; then
    CONFIGS_IDS=$(getSetting "dataCollection.configsIds")
  fi

  if [ -z "$USE_EXTERNAL_STORAGE" ]; then
    USE_EXTERNAL_STORAGE=$(getSetting "dataStorage.useExternalStorage")

    if [ -z "$USE_EXTERNAL_STORAGE" ]; then
      USE_EXTERNAL_STORAGE=false
    fi
  fi

  if [ -z "$EXTERNAL_STORAGE_URL" ]; then
    EXTERNAL_STORAGE_URL=$(getSetting "dataStorage.externalStorageUrl")
  fi

  if [ -z "$STORAGE_TYPE_ID" ]; then
    STORAGE_TYPE_ID=$(getSetting "dataStorage.storageId")

    if [ -z "$STORAGE_TYPE_ID" ]; then
      STORAGE_TYPE_ID=1
    fi
  fi

  if [ -z "$STORAGE_FORMAT_ID" ]; then
    STORAGE_FORMAT_ID=$(getSetting "dataStorage.storageFormatId")

    if [ -z "$STORAGE_FORMAT_ID" ]; then
      STORAGE_FORMAT_ID="json"
    fi
  fi

  if [ -z "$RETENTION_INTERVAL" ]; then
    RETENTION_INTERVAL=$(getSetting "dataStorage.retentionInterval")

    if [ -z "$RETENTION_INTERVAL" ]; then
      RETENTION_INTERVAL=10
    fi
  fi

  if [ -z "$WORKERS" ]; then
    WORKERS=$(getSetting "dataStorage.workers")

    if [ -z "$WORKERS" ]; then
      WORKERS=10
    fi
  fi

  if [ -z "$NODE_TYPE_ID" ]; then
    NODE_TYPE_ID=$(getSetting "infrastructure.nodeTypeId")

    if [ -z "$NODE_TYPE_ID" ]; then
      NODE_TYPE_ID="g7-premium-4"
    fi
  fi

  NODE_COUNT=3

  if [ -z "$REGION_ID" ]; then
    REGION_ID=$(getSetting "infrastructure.regionId")

    if [ -z "$REGION_ID" ]; then
      REGION_ID="us-iad"
    fi
  fi
}

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$UNATTENDED" ]; then
    DIALOG_CMD=$(which dialog)

    # Check if the requirements to start the setup exists.
    if [ -z "$DIALOG_CMD" ]; then
      echo "dialog is not installed! Please install it first to continue!"
      echo

      exit 1
    fi
  fi
}

# Prepare the environment to execute the commands of this script.
function prepareToExecute() {
  source functions.sh

  if [ -n "$UNATTENDED" ]; then
    showBanner
  fi
}

# Main function.
function main() {
  checkDependencies
  prepareToExecute
  welcomeDialog
  checkRequirementsDialog
  loadCredentials
  loadSettings
  menuDialog

  if [ -n "$UNATTENDED" ]; then
    if [ "$1" = "saveCredentials" ]; then
      checkCredentials
      saveCredentials

      echo "Credentials were saved!"
    fi

    if [ "$1" = "saveSettings" ]; then
      checkSettings
      saveSettings

      echo "Settings were saved!"
    fi
  fi
}

trap "" SIGTSTP
trap "" SIGINT

main "$1"

trap SIGINT
trap SIGTSTP