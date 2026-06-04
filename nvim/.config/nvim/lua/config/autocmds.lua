vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        -- Directories & Files
        vim.cmd("hi! link NeoTreeDirectoryName Directory")
        vim.cmd("hi! link NeoTreeDirectoryIcon Directory")
        vim.cmd("hi! link NeoTreeFileName Normal")

        -- Root and Title
        vim.cmd("hi! link NeoTreeRootName Title")
        vim.cmd("hi! link NeoTreeSymbolicLink String")

        -- Git Status
        vim.cmd("hi! link NeoTreeGitAdded DiffAdded")
        vim.cmd("hi! link NeoTreeGitDeleted DiffDeleted")
        vim.cmd("hi! link NeoTreeGitModified DiffChanged")

        -- Indent guides / icons
        vim.cmd("hi! link NeoTreeIndentMarker Comment")
        vim.cmd("hi! link NeoTreeExpander Normal")

        vim.cmd([[
        hi NeoTreeNormal guibg=NONE
        hi NeoTreeNormalNC guibg=NONE
      ]])
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.fn.stdpath("config") .. "/**/*.lua",
    command = "source <afile>",
    desc = "Auto-reload Neovim config",
})
