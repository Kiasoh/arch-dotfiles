-- Hyprland Lua configuration.  Split modules keep the previous variation layout.
require("conf/monitor")
require("conf/cursor")
require("conf/environment")
require("conf/keyboard")
require("conf/autostart")
require("conf/window")
require("conf/decoration")
require("conf/layout")
require("conf/workspace")
require("conf/misc")
require("conf/keybinding")
require("conf/windowrule")
require("conf/animation")

-- Environment needed by xdg-desktop-portal-hyprland.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

require("conf/ml4w")
require("conf/custom")
