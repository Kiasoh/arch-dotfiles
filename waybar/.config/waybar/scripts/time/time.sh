#!/bin/bash

STATE_FILE="/tmp/waybar_clock_state"

# Initialize state if missing
if [ ! -f "$STATE_FILE" ]; then
  echo "time" > "$STATE_FILE"
fi

if [ "$1" == "toggle" ]; then
  # Toggle state between time/date
  if [ "$(cat "$STATE_FILE")" = "time" ]; then
    echo "date" > "$STATE_FILE"
  else
    echo "time" > "$STATE_FILE"
  fi
  exit 0
fi

# Display based on current state
if [ "$(cat "$STATE_FILE")" = "time" ]; then
  date +"%H:%M %a"
else
  date +"%Y-%m-%d"
fi
