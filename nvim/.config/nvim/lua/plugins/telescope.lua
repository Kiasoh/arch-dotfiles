return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
        cmd = "Telescope", -- lazy-load on :Telescope
        config = function()
            local actions = require("telescope.actions")
            local opts = {
                defaults = {
                    path_display = { "smart" },
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden", -- include hidden files
                        -- "--no-ignore",  -- OPTIONAL: ignore .gitignore
                    },
                    layout_config = { prompt_position = "top" },
                    sorting_strategy = "ascending",
                    preview = {
                        treesitter = true,
                    },
                    mappings = {
                        i = {
                            ["<CR>"] = actions.select_default,     -- open in current window
                            ["<C-s>"] = actions.select_horizontal, -- open in horizontal split
                            ["<C-v>"] = actions.select_vertical,   -- open in vertical split
                            ["<C-t>"] = actions.select_tab,        -- open in new tab
                        },
                        n = {                                      -- for normal mode inside Telescope
                            ["<CR>"] = actions.select_default,
                            ["s"] = actions.select_horizontal,
                            ["v"] = actions.select_vertical,
                            ["t"] = actions.select_tab,
                            ["d"] = actions.delete_buffer,
                            ["q"] = actions.close,
                        },
                    },
                },
                pickers = {
                    live_grep = {
                        previewer = true,
                    },
                    find_files = {
                        hidden = true,
                        file_ignore_patterns = {
                            "^.git/",
                            "node_modules/",
                            "dist/",
                            "build/",
                            "^.pio",
                        },
                    },
                },
            }
            require("telescope").setup(opts)
            require("telescope").load_extension("fzf") -- This registers the extension
        end
    },
}
