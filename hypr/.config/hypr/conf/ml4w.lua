local function rule(match, properties)
    properties.match = match
    hl.window_rule(properties)
end

rule({ class = ".*org.pulseaudio.pavucontrol.*" }, { float = true, size = "700 600", center = true, pin = true })
rule({ class = ".*waypaper.*" }, { float = true, size = "900 700", center = true, pin = true })
rule({ class = "blueman-manager" }, { float = true, size = "800 600", center = true })
rule({ class = "nwg-look" }, { float = true, size = "700 600", move = "(monitor_w*0.10) (monitor_h*0.20)", pin = true })
rule({ class = "nwg-displays" }, { float = true, size = "900 600", move = "(monitor_w*0.10) (monitor_h*0.20)", pin = true })
rule({ class = "io.missioncenter.MissionCenter" }, { float = true, size = "900 600", center = true, pin = true })
rule({ class = "missioncenter", title = "^(Preferences)$" }, { float = true, center = true, pin = true })
rule({ class = "org.gnome.Calculator" }, { float = true, size = "700 600", center = true })
rule({ class = "it.mijorus.smile" }, { float = true, pin = true, move = "(monitor_w-window_w-40) 90" })
rule({ class = "hyprland-share-picker" }, { float = true, pin = true, size = "600 400", center = true })
rule({ class = "dotfiles-floating" }, { float = true, size = "1000 700", center = true })
rule({ class = "ml4w.dotfiles.floating" }, { float = true, size = "1000 700", center = true, pin = true })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.5 })

local environment = {
    XDG_CURRENT_DESKTOP = "Hyprland", XDG_SESSION_TYPE = "wayland", XDG_SESSION_DESKTOP = "Hyprland",
    QT_QPA_PLATFORM = "wayland;xcb", QT_QPA_PLATFORMTHEME = "qt5ct", QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
    QT_AUTO_SCREEN_SCALE_FACTOR = "1", GDK_SCALE = "1", GDK_BACKEND = "wayland,x11,*",
    CLUTTER_BACKEND = "wayland", MOZ_ENABLE_WAYLAND = "1", XCURSOR_SIZE = "24",
    OZONE_PLATFORM = "wayland", ELECTRON_OZONE_PLATFORM_HINT = "wayland",
}
for name, value in pairs(environment) do hl.env(name, value) end
