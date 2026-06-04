local registry = require("config.theme_registry")
local storage = require("config.theme_storage")
local loader = require("config.theme_loader")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local state = require("telescope.actions.state")

local M = {}

local function picker(title, items, cb)
    pickers.new({}, {
        prompt_title = title,

        finder = finders.new_table({
            results = items,
        }),

        sorter = conf.generic_sorter({}),

        attach_mappings = function(prompt_bufnr)
            vim.schedule(function()
                vim.cmd("stopinsert")
            end)
            actions.select_default:replace(function()
                local selection =
                    state.get_selected_entry()[1]

                actions.close(prompt_bufnr)

                cb(selection)
            end)

            return true
        end,
    }):find()
end

function M.open()
    local themes = {}

    for theme, _ in pairs(registry.themes) do
        table.insert(themes, theme)
    end

    table.sort(themes)

    picker(
        "Theme",
        themes,

        function(theme)
            local variants =
                registry.themes[theme].variants

            picker(
                "Variant",
                variants,

                function(variant)
                    picker(
                        "Transparent",
                        {
                            "false",
                            "true",
                        },

                        function(value)
                            local cfg = {
                                theme = theme,
                                variant = variant,
                                transparent =
                                    value == "true",
                            }

                            loader.apply(cfg)
                            storage.save(cfg)

                            vim.notify(
                                string.format(
                                    "%s (%s)",
                                    theme,
                                    variant
                                )
                            )
                        end
                    )
                end
            )
        end
    )
end

return M
