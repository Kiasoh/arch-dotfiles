local commands = {
    "~/.config/hypr/scripts/xdg.sh",
    "systemctl --user start hyprpolkitagent",
    "hyprpaper",
    "~/.config/hypr/scripts/my-wallpaper.sh",
    "swaync",
    "hypridle",
    "wl-paste --watch cliphist store",
    "~/.config/hypr/scripts/cleanup.sh",
    "env HYPRLAND_INSTANCE_SIGNATURE=$HYPRLAND_INSTANCE_SIGNATURE swaykbdd",
}

-- Ensure applications launched by Hyprland (including Waybar) can reach its
-- IPC socket even when the session was started through greetd/UWSM.
local signature = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
if signature then hl.env("HYPRLAND_INSTANCE_SIGNATURE", signature) end

hl.on("hyprland.start", function()
    for _, command in ipairs(commands) do hl.exec_cmd(command) end
end)
