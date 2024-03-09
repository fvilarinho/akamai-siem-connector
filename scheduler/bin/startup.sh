#!/bin/bash

# Setup the startup.
"$BIN_DIR"/setup.sh

# Show banner.
if [ -f "$ETC_DIR"/banner.txt ]; then
  cat "$ETC_DIR"/banner.txt
fi

# Start scheduler.
su-exec root crond

MODIFIED_FILE=/tmp/settings.conf
MOSQUITTO_CMD=$(which mosquitto)

$MOSQUITTO_CMD -c "$MODIFIED_FILE" &

echo "[$(date)][$HOSTNAME are now scheduling jobs]"

tail -f "$LOGS_DIR"/scheduler.log