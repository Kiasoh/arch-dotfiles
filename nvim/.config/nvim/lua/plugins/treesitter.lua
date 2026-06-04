return {
    "nvim-treesitter/nvim-treesitter",
    branch = 'main',
    lazy = false,
    build = ":TSUpdate",
    init = function()
        local ensure_installed = {
            "c",
            "cpp",
            "lua",
            "go",
            "python",
            "typescript",
            "yaml",
            "json",
        }

        local installed = require("nvim-treesitter.config").get_installed()

        local missing = vim.iter(ensure_installed)
            :filter(function(lang)
                return not vim.tbl_contains(installed, lang)
            end)
            :totable()

        if #missing > 0 then
            require("nvim-treesitter").install(missing)
        end

        vim.api.nvim_create_autocmd("FileType", {
            callback = function()
                pcall(vim.treesitter.start)
                vim.bo.indentexpr =
                "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end
}
