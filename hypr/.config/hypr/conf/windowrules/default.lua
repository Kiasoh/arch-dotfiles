local function rule(match, properties)
    properties.match = match
    hl.window_rule(properties)
end

rule({ title = "^(pavucontrol)$" }, { float = true })
rule({ title = "^(blueman-manager)$" }, { float = true })
rule({ title = "^(nm-connection-editor)$" }, { float = true })
rule({ class = "^(qalculate-gtk)$" }, { float = true })
rule({ title = "^(Picture-in-Picture)$" }, { float = true, pin = true, move = "69.5% 4%" })
rule({ class = "([window])", fullscreen = true }, { idle_inhibit = "fullscreen" })
