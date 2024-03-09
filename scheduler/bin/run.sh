#!/bin/bash

# Required binaries.
JQ_CMD=$(which jq)
MOSQUITTO_PUB=$(which mosquitto_pub)

# Read settings.
SETTINGS_FILENAME="$ETC_DIR"/settings.json
JOBS_PER_MINUTE=$($JQ_CMD -r .jobsPerMinute < "$SETTINGS_FILENAME")
MAX_EVENTS_PER_JOB=$($JQ_CMD -r .maxEventsPerJob < "$SETTINGS_FILENAME")
OUTPUT_QUEUE=$($JQ_CMD -r .outputQueue < "$SETTINGS_FILENAME")
TIMEFRAME=$((60 / JOBS_PER_MINUTE))
NOW=$(date +%s)

# Publish the jobs.
i=0

while [ $i -lt $((JOBS_PER_MINUTE)) ]; do
  OFFSET1=$((i * TIMEFRAME))
  OFFSET2=$(((i + 1) * TIMEFRAME))
  TO=$((NOW - OFFSET1))
  FROM=$((NOW - OFFSET2))
  MESSAGE="{\"job\": \"$NOW-$((i + 1))\", \"from\": $FROM, \"to\": $TO, \"maxEventsPerJob\": $MAX_EVENTS_PER_JOB}"

  $MOSQUITTO_PUB -I "$HOSTNAME" -t "$OUTPUT_QUEUE" -m "$MESSAGE" -d >> "$LOGS_DIR"/scheduler.log

  echo "[$(date)][job created][$MESSAGE]" >> "$LOGS_DIR"/scheduler.log

  ((i++))
done