require("config.lazy")
require("config.options")
require("config.diagnostics")
require("config.diag_picker")
require("config.theme_registry")
require("config.theme_storage")
require("config.theme_loader")
require("config.theme_picker")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("config.other")


local diag = require("config.diagnostics")
diag.set_preset("On_Insert_Virtual")

vim.api.nvim_set_hl(0, "LuasnipSnippetActive", { underline = false })
vim.api.nvim_set_hl(0, "LuasnipTextNodeUnvisited", { underline = false })
vim.api.nvim_set_hl(0, "LuasnipInsertNodeActive", { underline = false })
vim.api.nvim_set_hl(0, "LuasnipExitNodeUnvisited", { underline = false })

-- remove underline from rust semantic tokens
vim.api.nvim_set_hl(0, "@lsp.type.unresolvedReference.rust", { underline = false })
vim.api.nvim_set_hl(0, "@lsp.type.macro.rust", { underline = false })


vim.lsp.set_log_level("ERROR")
