return {
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local comment = require("Comment")
            comment.setup()

            -- Keymaps
            local api = require("Comment.api")

            -- Normal mode: <C-/> toggles current line
            vim.keymap.set("n", "<C-/>", api.toggle.linewise.current, { desc = "Toggle comment" })

            -- Visual mode: <C-/> toggles selection
            local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
            vim.keymap.set("x", "<C-/>", function()
                vim.cmd('normal! ' .. esc)
                api.toggle.linewise(vim.fn.visualmode())
            end, { desc = "Toggle comment" })
        end,
    },
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            signs = true,
        },
    }
}
