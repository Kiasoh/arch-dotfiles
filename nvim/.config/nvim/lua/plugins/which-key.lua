        -- })
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")

        wk.setup({
            plugins = {
                spelling = { enabled = true },
            },
            -- key_labels = {
            --   ["<space>"] = "SPC",
            --   ["<cr>"] = "RET",
            --   ["<tab>"] = "TAB",
            -- },
            icons = {
                breadcrumb = "»", -- top breadcrumb in the popup
                separator = "➜", -- between key and label
                group = "+" -- prefix for groups
            },
            -- popup_mappings = {
            --   scroll_down = "<c-d>",
            --   scroll_up = "<c-u>"
            -- },
            -- window = {
            --   border = "single", -- none, single, double, shadow
            --   position = "bottom",
            -- },
        })

        -- Register keymaps
    --     wk.register({
    --         { "<leader>b",   group = "Buffers" },
    --         { "<leader>bb",  "<cmd>BufferLinePick<CR>",                     desc = "Pick Buffer" },
    --         { "<leader>bc",  "<cmd>BufferLinePickClose<CR>",                desc = "Pick Buffer to Close" },
    --         { "<leader>bp",  "<cmd>BufferLineTogglePin<CR>",                desc = "Pin Buffer" },
    --         { "<leader>c",   "<cmd>CommentToggle<CR>",                      desc = "Toggle Comment" },
    --         { "<leader>h",   group = "Git Hunk" },
    --         { "<leader>hR",  "<cmd>Gitsigns reset_buffer<CR>",              desc = "Reset Buffer" },
    --         { "<leader>hS",  "<cmd>Gitsigns stage_buffer<CR>",              desc = "Stage Buffer" },
    --         { "<leader>hb", '<function() require("gitsigns").blame_line{full=true} end>', desc = "Blame Line" },
    --         { "<leader>hp",  "<cmd>Gitsigns preview_hunk<CR>",              desc = "Preview Hunk" },
    --         { "<leader>hr",  "<cmd>Gitsigns reset_hunk<CR>",                desc = "Reset Hunk" },
    --         { "<leader>hs",  "<cmd>Gitsigns stage_hunk<CR>",                desc = "Stage Hunk" },
    --         { "<leader>htb", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle Line Blame" },
    --         { "<leader>u",   "<cmd>UndotreeToggle<CR>",                     desc = "Undo Tree" },
    --     })
    end,
}
