local function show_path_popup()
    local path = vim.fn.expand('%:p')                       -- Get the directory path
    local buf = vim.api.nvim_create_buf(false, true)        -- Create a scratch buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { path }) -- Put path in buffer

    local opts = {
        relative = 'cursor',
        width = math.min(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]:len() + 4, 60),
        height = 1,
        col = 0,
        row = 1,
        style = 'minimal',
        border = 'rounded',
    }

    vim.api.nvim_open_win(buf, true, opts)

    -- Auto-close the popup after 3 seconds
    -- vim.defer_fn(function()
    --     if vim.api.nvim_win_is_valid(vim.api.nvim_get_current_win()) then
    --         vim.api.nvim_win_close(0, true)
    --     end
    -- end, 3000)
end

-- Map it to a key (e.g., <leader>fp)
vim.keymap.set('n', '<leader>fp', show_path_popup, { desc = "Show path popup" })


local function yank_file_lines()
    local bufnr = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(bufnr)

    if file == "" then
        vim.notify("Current buffer has no file path", vim.log.levels.WARN)
        return
    end

    -- Use a path relative to Neovim's current working directory.
    file = vim.fn.fnamemodify(file, ":.")

    local first = vim.fn.line("'<")
    local last = vim.fn.line("'>")

    -- In normal mode, use the current line.
    if first == 0 or last == 0 then
        first = vim.fn.line(".")
        last = first
    end

    if first > last then
        first, last = last, first
    end

    local target = string.format("%s:%d-%d", file, first, last)

    -- Copy to the system clipboard.
    vim.fn.setreg("+", target)

    vim.notify("Copied: " .. target)
end

-- Normal mode: copy the current line
vim.keymap.set("n", "<leader>yl", yank_file_lines, {
    desc = "Copy file path and current line",
})

-- Visual mode: copy the selected line range
vim.keymap.set("v", "<leader>yl", yank_file_lines, {
    desc = "Copy file path and selected lines",
})
