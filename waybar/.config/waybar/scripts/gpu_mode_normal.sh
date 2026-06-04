#!/bin/bash

export DISPLAY=:1
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

hyprctl reload
echo "→ Setting GPU mode: Normal (Hybrid)"
sudo envycontrol -s hybrid

# ASUS specific power profile (Balanced)
if command -v asusctl >/dev/null; then
    asusctl profile -P Balanced
fi

# Intel pstate uses 'powersave' as the base for balanced operation, 
# the EPP handles the actual balance scaling.
for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave | sudo tee "$gov" >/dev/null
done
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [ -f "$epp" ] && echo balance_performance | sudo tee "$epp" >/dev/null
done

# Force TLP to AC/Balanced mode
if command -v tlp >/dev/null; then
    sudo tlp ac
fi
hyprctl keyword monitor eDP-1,1920x1080@144,auto,1

echo "source = ~/.config/hypr/conf/environments/default.conf" > ~/.config/hypr/conf/environment.conf

notify-send -u normal -i computer "⚖️ Normal Mode Enabled" "Profile: Balanced, GPU: Hybrid\nRestart/logout for GPU changes to apply."
