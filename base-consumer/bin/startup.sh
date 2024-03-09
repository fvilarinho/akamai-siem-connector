#!/bin/bash

# Setup the startup.
"$BIN_DIR"/setup.sh

# Show banner.
if [ -f "$ETC_DIR"/banner.txt ]; then
  cat "$ETC_DIR"/banner.txt
fi

# Execute the main script using NodeJS.
NODE_CMD=$(which node)

$NODE_CMD "$BIN_DIR"/main.js | tee -a "$LOGS_DIR"/consumer.log