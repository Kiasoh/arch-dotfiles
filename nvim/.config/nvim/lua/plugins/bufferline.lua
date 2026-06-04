return{
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
        require("bufferline").setup({
            options = {
                mode = "tabs", -- show buffers instead of tabs
                numbers = "none", -- can be "ordinal" or "buffer_id" too
                diagnostics = "nvim_lsp", -- show LSP diagnostics in bufferline
                separator_style = "slant", -- "slant", "padded_slant", "thick", "thin"
                always_show_bufferline = true,
                show_buffer_close_icons = true,
                show_close_icon = false,
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
            },
        })

        -- Keymaps
        local map = vim.keymap.set
        map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
        map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
        map("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Pin buffer" })
        map("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "Pick buffer to close" })
        map("n", "<leader>bb", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer to jump" })
    end,
}
