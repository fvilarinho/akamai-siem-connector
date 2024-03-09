#!/bin/bash

# Setup the startup.
"$BIN_DIR"/setup.sh

# Show banner.
if [ -f "$ETC_DIR"/banner.txt ]; then
  cat "$ETC_DIR"/banner.txt
fi

# Start nginx in foreground mode.
echo
echo "[$(date)][ingress started]"

NGINX_CMD=$(which nginx)

$NGINX_CMD -g "daemon off;"