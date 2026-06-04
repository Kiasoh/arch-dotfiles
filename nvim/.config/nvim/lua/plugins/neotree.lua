return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- optional, but recommended
        },
        lazy = false,                -- neo-tree will lazily load itself
        opts = {
            filesystem = {
                filtered_items = {
                    visible = true, -- This enables showing hidden files
                    show_hidden = true, -- This specifically shows hidden files
                    hide_dotfiles = false, -- This ensures dotfiles are not hidden
                    hide_gitignore = false, -- This shows gitignored files
                },
                -- visible = true,
                -- show_hidden_count = true,
                -- hide_dotfiles = false,
                -- hide_gitignore = false,
                window = {
                    mappings = {
                        ["<CR>"] = "open",
                        ["s"] = "open_split",
                        ["v"] = "open_vsplit",
                        ["t"] = "open_tabnew",
                    },
                }
            },
        },
        config = function(_, opts)
            require("neo-tree").setup(opts)
            vim.cmd([[
      hi NeoTreeNormal guibg=NONE
      hi NeoTreeNormalNC guibg=NONE
      hi NeoTreeEndOfBuffer guibg=NONE
      hi! link NeoTreeDirectoryName Directory
      hi! link NeoTreeDirectoryIcon Directory
      hi! link NeoTreeRootName Title
    ]])
        end,
    }
}
