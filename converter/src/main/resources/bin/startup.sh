#!/bin/bash

# Setup the startup.
"$BIN_DIR"/setup.sh

# Show banner.
if [ -f "$ETC_DIR/banner.txt" ]; then
  cat "$ETC_DIR"/banner.txt
fi

# Execute the main application.
"${BIN_DIR}"/run.sh