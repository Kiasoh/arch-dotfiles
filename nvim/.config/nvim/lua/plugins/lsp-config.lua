local servers = {
    "lua_ls",
    "rust_analyzer",
    "gopls",
    "clangd",
    "bashls",
    "pylsp",
    "jsonls",
    "marksman",
    "yamlls",
    "sqls",
    "dockerls"
}

return {
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "mason-org/mason-lspconfig.nvim",
        config = function()
            -- local caps = require("cmp_nvim_lsp").default_capabilities()
            local caps = require("blink.cmp").get_lsp_capabilities()
            vim.lsp.config("*", {
                capabilities = caps,
            })
            vim.lsp.config("clangd", {
                capabilities = caps,
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--query-driver=/home/kiasoh/.platformio/packages/toolchain-xtensa-esp32/bin/xtensa-esp32-elf-*",
                },
            })
            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_enable = true,
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local opts = {}

            -- global LSP keymaps
            vim.keymap.set('n', 'H', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        end
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup {
                extensions = {
                    ["ui-select"] = require("telescope.themes").get_dropdown {}
                }
            }
            require("telescope").load_extension("ui-select")
        end
    }
}
