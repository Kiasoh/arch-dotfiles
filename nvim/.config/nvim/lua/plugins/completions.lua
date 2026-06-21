return {
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    {
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
        },

        opts = {
            keymap = {
                preset = "default",

                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-a>"] = { "hide", "fallback" },
                ["<CR>"] = { "accept", "fallback" },

                ["<Tab>"] = {
                    "select_next",
                    "snippet_forward",
                    "fallback",
                },

                ["<S-Tab>"] = {
                    "select_prev",
                    "snippet_backward",
                    "fallback",
                },
            },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },

            completion = {
                accept = {
                    auto_brackets = {
                        enabled = true,
                    },
                },

                menu = {
                    border = "rounded",
                    -- border = "none",
                },

                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                    window = {
                        border = "rounded",
                        -- border = "none",
                    },
                },

                ghost_text = {
                    enabled = false,
                },
            },

            signature = {
                enabled = true,
                window = {
                    border = "rounded",
                },
            },

            snippets = {
                preset = "luasnip",
            },

            sources = {
                default = {
                    "lsp",
                    "path",
                    "snippets",
                    "buffer",
                },
            },

            cmdline = {
                enabled = true,
            },

            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },
        },

        opts_extend = {
            "sources.default",
        },
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            check_ts = true,
            ts_config = {
                lua = { "string" },
                javascript = { "template_string" },
                typescript = { "template_string" },
                java = false,
            },
            fast_wrap = {},
        },
    },
}
