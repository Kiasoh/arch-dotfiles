#!/bin/bash

DATAFILE="/tmp/waybar_stats.json"

# Clean up and reset Waybar when this script is killed
#󰾆
#
#󰹑
# 
#󰻠 󰍜 
trap 'echo "{\"text\": \"󰾆 \", \"tooltip\": \"Click to expand stats\"}" > "$DATAFILE"; pkill -RTMIN+8 waybar; exit 0' SIGTERM SIGINT

while true; do
    # 1. CPU Usage
    cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    
    # 2. Temperature (Catches both AMD 'Tctl' and Intel 'Package id 0')
    sensors_data=$(sensors)
    temp=$(echo "$sensors_data" | grep 'Package id 0' | awk '{print $4}' | tr -d '+' | head -n 1)
    
    # 3. Fan Speeds (Gets both CPU and GPU fans if spinning)
    # fans=$(echo "$sensors_data" | awk '/fan[1-2]/ {print $2}' | tr '\n' '/' | sed 's/\/$//')
    # [ -z "$fans" ] && fans="0"
    # 4. Fans (Updated to catch ASUS 'cpu_fan')
    fans=$(echo "$sensors_data" | awk '/fan/ {print $2}' | tr '\n' '/' | sed 's/\/$//')
    if [ -z "$fans" ]; then
        fans="0"
    fi
    
    # 4. RAM Usage
    ram=$(free -h | awk '/^Mem:/ {print $3 "/" $2}' | sed 's/Gi/G/g')
    
    # 5. Disk Usage (Root partition)
    disk=$(df -h / | awk '/\// {print $5}')
    
    # 6. iGPU Usage (Intel specific - Fixed hang issue)
    igpu="N/A"
    if command -v intel_gpu_top &> /dev/null; then
        # timeout ensures it dies, grep -m 1 forces it to exit after the first read
        # igpu_res=$(timeout 1 sudo intel_gpu_top)
        # igpu_val=$(echo "$igpu_res" | grep -m 1 "Render/3D" | awk '{print $2}')
        igpu_val=$(timeout 1 sudo intel_gpu_top 2>/dev/null | awk '/^[ \t]*[0-9]+/ { val=$9 } END { print val }')       
        if [ -n "$igpu_val" ]; then
            # The output already includes the % sign, so we just use the value
            igpu="${igpu_val}%"
        else
            igpu="0%"
        fi
    else
        sleep 1
    fi
    
    # 7. dGPU Usage (Only wakes dGPU if driver is loaded)
    dgpu="Off"
    if lsmod | grep -q "^nvidia"; then
        dgpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
        if [ -n "$dgpu_util" ]; then
            dgpu="${dgpu_util}%"
        fi
    fi

    # Format the output string. Adjust the icons to your liking!
    text="  $cpu ($temp) |  $ram |   $disk | 󰢮 i:$igpu | 󰢮 d:$dgpu | 󰈐  ${fans}RPM"
    
    # Write JSON for Waybar
    echo "{\"text\": \"$text\", \"class\": \"expanded\"}" > "$DATAFILE"
    
    # Signal Waybar to read the new data instantly
    pkill -RTMIN+8 waybar
    
    # Update interval
    # sleep 1
done
