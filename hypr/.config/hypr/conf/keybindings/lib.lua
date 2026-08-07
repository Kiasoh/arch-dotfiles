local M = {}

local function keys(modifiers, key)
    return modifiers == "" and key or modifiers .. " + " .. key
end

function M.exec(modifiers, key, command, options)
    hl.bind(keys(modifiers, key), hl.dsp.exec_cmd(command), options)
end

local directions = { l = "left", r = "right", u = "up", d = "down" }

local function native_dispatch(command)
    local action, argument = command:match("^(%S+)%s*(.-)$")

    if action == "killactive" then return hl.dsp.window.close() end
    if action == "togglefloating" then return hl.dsp.window.float({ action = "toggle" }) end
    if action == "fullscreen" then
        return hl.dsp.window.fullscreen({
            mode = argument == "1" and "maximized" or "fullscreen",
            action = "toggle",
        })
    end
    if action == "layoutmsg" or action == "togglesplit" or action == "swapsplit" then
        return hl.dsp.layout(action == "layoutmsg" and argument or action)
    end
    if action == "movefocus" then return hl.dsp.focus({ direction = directions[argument] or argument }) end
    if action == "resizeactive" then
        local x, y = argument:match("^(-?%d+)%s+(-?%d+)$")
        return hl.dsp.window.resize({ x = tonumber(x), y = tonumber(y), relative = true })
    end
    if action == "togglegroup" then return hl.dsp.group.toggle() end
    if action == "swapwindow" then return hl.dsp.window.swap({ direction = directions[argument] or argument }) end
    if action == "workspace" then return hl.dsp.focus({ workspace = argument }) end
    if action == "movetoworkspace" then return hl.dsp.window.move({ workspace = argument }) end
    if action == "cyclenext" then return hl.dsp.window.cycle_next({ next = true }) end
    if action == "bringactivetotop" then return hl.dsp.window.alter_zorder({ mode = "top" }) end
    if action == "movewindow" then return hl.dsp.window.drag() end
    if action == "resizewindow" then return hl.dsp.window.resize() end

    -- workspaceopt is the only retained legacy dispatcher in the selected
    -- configurations; Hyprland currently has no equivalent Lua dispatcher.
    return hl.dsp.exec_cmd("hyprctl dispatch " .. command)
end

function M.dispatch(modifiers, key, command, options)
    hl.bind(keys(modifiers, key), native_dispatch(command), options)
end

return M
