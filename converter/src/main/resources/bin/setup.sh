#!/bin/bash

# Define the prompt.
echo "export CLICOLOR=1" > ~/.bashrc
echo "export PS1='[\u@\h:\W]$ '" >> ~/.bashrc

# Create log file.
if [ ! -f "$LOGS_DIR"/converter.log ]; then
  touch "$LOGS_DIR"/converter.log
fi