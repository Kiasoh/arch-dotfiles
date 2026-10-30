-- Pick the Hyprland env file at startup from the live GPU mode (envycontrol),
-- so switching GPU modes without touching any config file just works after relogin.
-- fallback: default (iGPU-first) whenever the query fails for any reason.
local env = "default"
local ok, query = pcall(function()
    local f = io.popen("envycontrol --query 2>/dev/null")
    local out = f:read("*a")
    f:close()
    return out
end)
if ok and query and query:find("nvidia", 1, true) then
    env = "nvidia"
end
require("conf/environments/" .. env)
