#!/bin/bash

# Define the prompt.
echo "export CLICOLOR=1" > ~/.bashrc
echo "export PS1='[\u@\h:\W]$ '" >> ~/.bashrc

# List the plugins to be installed.
PLUGINS=$(cat "$HOME"/config/plugins.conf)

if [ -n "$PLUGINS" ]; then
  # Install the plugins.
  for PLUGIN in $PLUGINS
  do
    "$HOME"/bin/logstash-plugin install --no-verify --preserve "$PLUGIN"
  done
fi
