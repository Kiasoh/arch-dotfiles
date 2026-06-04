local M = {}

function M.apply(cfg)
    if cfg.theme == "tokyonight" then
        require("tokyonight").setup({
            style = cfg.variant,
            transparent = cfg.transparent,
        })

        vim.cmd.colorscheme("tokyonight")
        return
    end

    if cfg.theme == "kanagawa" then
        require("kanagawa").setup({
            theme = cfg.variant,
            transparent = cfg.transparent,
            colors = {
                theme = {
                    all = {
                        ui = {
                            bg_gutter = "none",
                        },
                    },
                },
            },
            overrides = function(colors)
                return {
                    TelescopeBorder = {
                        bg = "NONE",
                        fg = colors.palette.sumiInk4,
                    },

                    TelescopeNormal = {
                        bg = "NONE",
                    },

                    TelescopePromptBorder = {
                        bg = "NONE",
                    },

                    TelescopeResultsBorder = {
                        bg = "NONE",
                    },

                    TelescopePreviewBorder = {
                        bg = "NONE",
                    },
                }
            end
            -- overrides = function(colors)
            --     local theme = colors.theme
            --
            --     return {
            --         TelescopeTitle = {
            --             fg = theme.ui.special,
            --             bold = true,
            --         },
            --
            --         TelescopePromptNormal = {
            --             bg = theme.ui.bg_p1,
            --         },
            --
            --         TelescopePromptBorder = {
            --             bg = theme.ui.bg_p1,
            --             fg = theme.ui.bg_p1,
            --         },
            --
            --         TelescopeResultsNormal = {
            --             bg = theme.ui.bg_m1,
            --         },
            --
            --         TelescopeResultsBorder = {
            --             bg = theme.ui.bg_m1,
            --             fg = theme.ui.bg_m1,
            --         },
            --
            --         TelescopePreviewNormal = {
            --             bg = theme.ui.bg_dim,
            --         },
            --
            --         TelescopePreviewBorder = {
            --             bg = theme.ui.bg_dim,
            --             fg = theme.ui.bg_dim,
            --         },
            --     }
            -- end,
        })

        vim.cmd.colorscheme("kanagawa")
        return
    end

    if cfg.theme == "catppuccin" then
        require("catppuccin").setup({
            flavour = cfg.variant,
            transparent_background = cfg.transparent,
        })

        vim.cmd.colorscheme("catppuccin")
        return
    end

    if cfg.theme == "rose-pine" then
        require("rose-pine").setup({
            variant = cfg.variant,
            disable_background = cfg.transparent,
        })

        vim.cmd.colorscheme("rose-pine")
        return
    end

    if cfg.theme == "nightfox" then
        require("nightfox").setup({
            options = {
                transparent = cfg.transparent,
            },
        })

        vim.cmd.colorscheme(cfg.variant)
        return
    end

    if cfg.theme == "github" then
        require("github-theme").setup({
            options = {
                transparent = cfg.transparent,
            },
        })

        vim.cmd.colorscheme(cfg.variant)
        return
    end
end

return M
