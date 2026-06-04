local M = {}

local path =
    vim.fn.stdpath("config") .. "/theme.json"

function M.save(cfg)
    local fd = io.open(path, "w")

    if not fd then
        return
    end

    fd:write(vim.json.encode(cfg))
    fd:close()
end

function M.load()
    local fd = io.open(path, "r")

    if not fd then
        return {
            theme = "kanagawa",
            variant = "wave",
            transparent = false,
        }
    end

    local content = fd:read("*a")
    fd:close()

    local ok, decoded =
        pcall(vim.json.decode, content)

    if ok then
        return decoded
    end

    return {
        theme = "kanagawa",
        variant = "wave",
        transparent = false,
    }
end

return M
