return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim",    build = "make" },
            { "nvim-telescope/telescope-live-grep-args.nvim" },
        },
        cmd = "Telescope", -- lazy-load on :Telescope
        config = function()
            local actions = require("telescope.actions")
            local lga_actions = require("telescope-live-grep-args.actions")

            require("telescope").setup({
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
                        "--hidden",
                        "--no-ignore",
                    },
                    layout_config = { prompt_position = "top" },
                    sorting_strategy = "ascending",
                    preview = {
                        treesitter = true,
                    },
                    mappings = {
                        i = {
                            ["<CR>"] = actions.select_default,
                            ["<C-s>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,
                        },
                        n = {
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
                extensions = {
                    live_grep_args = {
                        auto_quoting = true,
                        mappings = {
                            i = {
                                ["<C-k>"] = lga_actions.quote_prompt(),
                                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                            },
                        },
                    },
                },
            })

            require("telescope").load_extension("fzf")
            require("telescope").load_extension("live_grep_args")

            vim.keymap.set("n", "<leader>fg", function()
                require("telescope").extensions.live_grep_args.live_grep_args()
            end, { desc = "Live grep with args" })
        end,
    },
}
