#!/bin/bash

# Define the prompt.
echo "export CLICOLOR=1" > ~/.bashrc
echo "export PS1='[\u@\h:\W]$ '" >> ~/.bashrc

# Prepare the configuration file.
ORIGINAL_FILE="$ETC_DIR"/settings.conf
MODIFIED_FILE=/tmp/settings.conf

cp "$ORIGINAL_FILE" "$MODIFIED_FILE"
sed -i -e 's|${HOME_DIR}|'"$HOME_DIR"'|g' "$MODIFIED_FILE"
sed -i -e 's|${BIN_DIR}|'"$BIN_DIR"'|g' "$MODIFIED_FILE"
sed -i -e 's|${ETC_DIR}|'"$ETC_DIR"'|g' "$MODIFIED_FILE"
sed -i -e 's|${DATA_DIR}|'"$DATA_DIR"'|g' "$MODIFIED_FILE"
sed -i -e 's|${LOGS_DIR}|'"$LOGS_DIR"'|g' "$MODIFIED_FILE"

# Create log file.
if [ ! -f "$LOGS_DIR"/scheduler.log ]; then
  touch "$LOGS_DIR"/scheduler.log
fi

# Clean-up.
rm -rf "$DATA_DIR"/lost+found