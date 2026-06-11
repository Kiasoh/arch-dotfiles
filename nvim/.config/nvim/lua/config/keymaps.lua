vim.g.mapleader = " "
vim.keymap.set("n", "<leader>qq", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore session" })
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end,
    { desc = "Restore last session" })
vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end)
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Stop auto session" })
--local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>gg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = 'List buffers' })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete all but current" })
vim.keymap.set("n", "<leader>-", "<cmd>Oil<CR>", {desc = "Oil"})
vim.keymap.set("n", "<leader>=", "<cmd>Oil --float<CR>", {desc = "Oil"})

vim.keymap.set("n", "<leader>bl", "<cmd>Telescope buffers sort_mru=true sort_lastused=true initial_mode=normal<CR>",
    { desc = "List buffers" })
vim.keymap.set("n", "<leader>tb", "<cmd>Telescope buffers<CR>", { desc = "List buffers" })
vim.keymap.set("n", "<leader>td", "<cmd>Telescope diagnostics<CR>", { desc = "List diagnostics" })
vim.keymap.set("n", "<leader>th", "<cmd>Telescope help_tags<cr>", { desc = "Help" })
vim.keymap.set('n', '<leader>tn', "<cmd>Telescope notify<CR>", { desc = 'list notification history' })

vim.keymap.set("n", "<leader>e", function()
    vim.diagnostic.open_float(nil, {
        focus = true,
        scope = "cursor",
        border = "rounded",
    })
end, { desc = "Show diagnostic under cursor" })
vim.keymap.set("n", "<C-e>", "<cmd>Neotree filesystem reveal left<cr>")
vim.keymap.set("n", "<C-e>", "<cmd>Neotree toggle<cr>")

vim.keymap.set("n", "<leader>dd", function()
    require("config.diag_picker").select_preset()
end, { desc = "Select diagnostic style" })
--navigate splits
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Quickly resize splits
vim.keymap.set('n', '<A-h>', '<C-w><')
vim.keymap.set('n', '<A-l>', '<C-w>>')
vim.keymap.set('n', '<A-j>', '<C-w>-')
vim.keymap.set('n', '<A-k>', '<C-w>+')

vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal Split" })
--Trouble
vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { desc = "Toggle Trouble list" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    { desc = "Buffer Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)", })
--Codeium

vim.keymap.set("i", "<C-Enter>", function()
    local codeium_accept = vim.fn["codeium#Accept"]()
    if codeium_accept ~= nil and codeium_accept ~= "" then
        vim.schedule(function()
            vim.api.nvim_feedkeys(codeium_accept, "i", true)
        end)
        return
    end
end, { desc = "Accept Codeium suggestion" })
-- vim.keymap.set("i", "<Tab>", function() return vim.fn["codeium#Accept"]() end, { desc = "Accept Codeium suggestion" })
-- vim.keymap.set("i", "<C-]>", function() return vim.fn  end, { })
-- vim.keymap.set("i", "<C-[>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { })
-- vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { })
--Harpoon
-- vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Add file to Harpoon" })
-- vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
--     { desc = "Harpoon menu" })
-- for i = 1, 5 do
--     vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end)
-- end

vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format, {})


--git
-- map({"n", "v"}, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
-- map({"n", "v"}, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
-- map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
-- map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
-- map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
-- map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
-- map("n", "<leader>hb", function() gs.blame_line{full=true} end, { desc = "Blame line" })
-- map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
-- map("n", "<leader>hd", gs.diffthis, { desc = "Diff this buffer" })
-- map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "Diff against last commit" })
-- map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle deleted signs" })
--
-- bufferline
--        map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
-- map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
-- map("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Pin buffer" })
-- map("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "Pick buffer to close" })
-- map("n", "<leader>bb", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer to jump" })
--
-- vim.keymap.set('n', 'H', vim.lsp.buf.hover, opts)
-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
-- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
-- vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
-- vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
-- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
--

vim.keymap.set(
    "n",
    "<leader>tp",
    function()
        require(
            "config.theme_picker"
        ).open()
    end,
    {
        desc = "Theme Picker",
    }
)

local cfg =
    require(
        "config.theme_storage"
    ).load()

require(
    "config.theme_loader"
).apply(cfg)
