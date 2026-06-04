#!/bin/bash

export DISPLAY=:1
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

echo "→ Setting GPU mode: Battery Saving (Intel only)"
sudo envycontrol -s integrated

# ASUS specific power profile (Quiet / Power Saver)
if command -v asusctl >/dev/null; then
    asusctl profile -P Quiet
fi

# Set CPU governor and Intel Energy Performance Preference (EPP)
for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave | sudo tee "$gov" >/dev/null
done
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [ -f "$epp" ] && echo power | sudo tee "$epp" >/dev/null
done

# Powertop auto-tune (Note: if your USB mouse lags, remove this)
if command -v powertop >/dev/null; then
    sudo powertop --auto-tune
fi

# Force TLP to Battery mode
if command -v tlp >/dev/null; then
    sudo tlp bat
fi

hyprctl keyword monitor eDP-1,1920x1080@60,auto,1

hyprctl --batch "\
    keyword animations:enabled 0;\
    keyword decoration:shadow:enabled 0;\
    keyword decoration:blur:enabled 0;\
    keyword general:gaps_in 0;\
    keyword general:gaps_out 0;\
    keyword general:border_size 1;\
    keyword decoration:rounding 0"

echo "source = ~/.config/hypr/conf/environments/default.conf" > ~/.config/hypr/conf/environment.conf

notify-send -u normal -i battery "🔋 Battery Mode Enabled" "Profile: Quiet, GPU: Integrated\nRestart/logout for GPU changes to apply."

