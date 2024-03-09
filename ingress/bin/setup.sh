#!/bin/bash

# Define the prompt.
echo "export CLICOLOR=1" > ~/.bashrc
echo "export PS1='[\u@\h:\W]$ '" >> ~/.bashrc

# Define/Prepare the ingress configurations.
for FILE in "$ETC_DIR"/nginx/http.d/*.conf; do
  BASENAME="$TMPDIR"/$(basename -- "$FILE")

  cp "$FILE" "$BASENAME"
  sed -i -e 's|${HOME_DIR}|'"$HOME_DIR"'|g' "$BASENAME"
  sed -i -e 's|${BIN_DIR}|'"$BIN_DIR"'|g' "$BASENAME"
  sed -i -e 's|${ETC_DIR}|'"$ETC_DIR"'|g' "$BASENAME"
  sed -i -e 's|${HTDOCS_DIR}|'"$HTDOCS_DIR"'|g' "$BASENAME"
  sed -i -e 's|${LOGS_DIR}|'"$LOGS_DIR"'|g' "$BASENAME"
  cp -f "$BASENAME" /etc/nginx/http.d/"$(basename -- "$FILE")"
  rm -f "$BASENAME"
done