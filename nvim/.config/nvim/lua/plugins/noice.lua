return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    config = function()
        require("noice").setup({
            cmdline = {
                format = {
                    -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                    -- view: (default is cmdline view)
                    -- opts: any options passed to the view
                    -- icon_hl_group: optional hl_group for the icon
                    -- title: set to anything or empty string to hide
                    cmdline = { pattern = "^:", icon = "", lang = "vim" },
                    search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                    search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                    filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                    lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
                    help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                    input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
                    -- lua = false, -- to disable a format, set to `false`
                    -- cmdline = { pattern = "^:", icon = "", lang = "vim" },
                    -- search_down = { kind = "search", pattern = "^/", icon = "🔍 ✓", lang = "regex" },
                    -- search_up = { kind = "search", pattern = "^%?", icon = "🔍 ↑", lang = "regex" },
                },
            },
            messages = {
                enabled = true,
                view = "notify", -- can be: "mini", "virtualtext", "notify", "popup"
                view_error = "notify",
                view_warn = "notify",
                view_history = "messages",
                view_search = "mini",
            },

            commands = {
                history = {
                    -- options for the message history that you get with `:Noice`
                    view = "split",
                    opts = { enter = true, format = "details" },
                    filter = {
                        any = {
                            { event = "notify" },
                            { error = true },
                            { warning = true },
                            { event = "msg_show", kind = { "" } },
                            { event = "lsp",      kind = "message" },
                        },
                    },
                },
                -- :Noice last
                last = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = {
                        any = {
                            { event = "notify" },
                            { error = true },
                            { warning = true },
                            { event = "msg_show", kind = { "" } },
                            { event = "lsp",      kind = "message" },
                        },
                    },
                    filter_opts = { count = 1 },
                },
                -- :Noice errors
                errors = {
                    -- options for the message history that you get with `:Noice`
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = { error = true },
                    filter_opts = { reverse = true },
                },
                all = {
                    -- options for the message history that you get with `:Noice`
                    view = "split",
                    opts = { enter = true, format = "details" },
                    filter = {},
                },
            },

            -- idk what this does. smthg about menus?
            popupmenu = {
                enabled = true,
                backend = "nui",
            },

            notify = {
                enabled = true,
                view = "notify",
            },

            lsp = {
                progress = { enabled = true },
                signature = { enabled = true, auto_open = { enabled = true } },
                hover = { enabled = true },
                message = { enabled = true }, -- route LSP messages through Noice
                documentation = { view = "hover" },
            },

            -- views = {
            --     mini = {
            --         timeout = 3000,
            --         position = { row = 1, col = "100%" },
            --     },
            --     popup = {
            --         border = {
            --             style = "rounded",
            --         }
            --     }
            -- },

            presets = {
                bottom_search = true,   -- classic Vim-style search cmdline
                command_palette = true, -- cmdline + popupmenu together
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = true,
            },

            routes = {
                { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
                { filter = { event = "msg_show", find = "written" },      opts = { skip = true } },
                { filter = { event = "msg_show", find = "lines" },        opts = { skip = true } },
                {
                    view = 'cmdline',
                    filter = {
                        event = 'msg_showmode',
                        any = {
                            { find = 'recording' },
                        },
                    },
                },
            }
        })

        require("notify").setup({
            stages = "fade_in_slide_out",
            timeout = 3000,
        })
    end,
}
