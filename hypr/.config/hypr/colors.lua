-- Values are read from Matugen's generated Hyprland palette on every reload.
local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local palette_path = config_home .. "/hypr/colors.conf"
local palette, error_message = io.open(palette_path, "r")
if not palette then
    error("Unable to read Matugen palette " .. palette_path .. ": " .. (error_message or "unknown error"))
end

local colors = {}
for line in palette:lines() do
    local name, value = line:match("^%s*%$([%w_]+)%s*=%s*(%S+)")
    if name and value then colors[name] = value end
end
palette:close()

return colors
