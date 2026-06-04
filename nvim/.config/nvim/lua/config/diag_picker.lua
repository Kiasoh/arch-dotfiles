local M = {}
local diag = require("config.diagnostics")

function M.select_preset()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Select Diagnostic Preset",
    finder = finders.new_table({
      results = vim.tbl_keys(diag.presets),
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        diag.set_preset(selection[1])
      end)
      return true
    end,
  }):find()
end

return M

