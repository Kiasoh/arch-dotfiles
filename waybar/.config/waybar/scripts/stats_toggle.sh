#!/bin/bash

PIDFILE="/tmp/waybar_stats.pid"
DATAFILE="/tmp/waybar_stats.json"

if [ -f "$PIDFILE" ]; then
    # The poller is running. Kill it! (This closes the group)
    poller_pid=$(cat "$PIDFILE")
    kill "$poller_pid"
    rm "$PIDFILE"
else
    # The poller is NOT running. Start it! (This opens the group)
    # Run it in the background
    ~/.config/waybar/scripts/stats_poller.sh &
    # Save the Process ID so we can kill it later
    echo $! > "$PIDFILE"
    
    # Give it a split second to generate the first batch of data
    sleep 0.2 
fi
