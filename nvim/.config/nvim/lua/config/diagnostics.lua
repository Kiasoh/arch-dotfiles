local M = {}

M.presets = {
    Virtual = {
        virtual_text = true,
        signs = true,
        underline = true,
        float = { border = "rounded", wrap = true },
    },
    Signs = {
        virtual_text = false,
        signs = true,
        underline = true,
    },
    Float = {
        virtual_text = false,
        signs = false,
        underline = false,
        float = { border = "rounded" },
    },
    On_Insert_Virtual = {
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = true,
    },
    Virtual_but_peacefull = {
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
    },
    On_Insert_Signs = {
        virtual_text = false,
        signs = true,
        underline = true,
        update_in_insert = true,
    },
}

function M.set_preset(name)
    local cfg = M.presets[name]
    if not cfg then
        vim.notify("No such preset: " .. name, vim.log.levels.ERROR)
        return
    end
    vim.diagnostic.config(cfg)
    vim.notify("Diagnostics style → " .. name, vim.log.levels.INFO)
end

return M
