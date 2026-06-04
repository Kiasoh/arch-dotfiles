#!/bin/bash

export DISPLAY=:1
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

hyprctl reload

echo "→ Setting GPU mode: Performance (NVIDIA only)"
sudo envycontrol -s nvidia

# ASUS specific power profile (Performance/Turbo)
if command -v asusctl >/dev/null; then
    asusctl profile -P Performance
fi

# Set CPU to max performance
for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee "$gov" >/dev/null
done
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [ -f "$epp" ] && echo performance | sudo tee "$epp" >/dev/null
done

# Force TLP to AC mode so it doesn't throttle
if command -v tlp >/dev/null; then
    sudo tlp ac
fi
hyprctl keyword monitor eDP-1,1920x1080@144,auto,1

echo "source = ~/.config/hypr/conf/environments/nvidia.conf" > ~/.config/hypr/conf/environment.conf

notify-send -u critical -i video-display "🚀 Performance Mode Enabled" "Profile: Performance, GPU: NVIDIA\nRestart/logout for GPU changes to apply."
