local colors = require("colors")
hl.config({ general = {
    gaps_in = 5, gaps_out = 5, border_size = 2,
    col = { active_border = colors.on_surface, inactive_border = colors.on_primary_fixed },
    layout = "dwindle", resize_on_border = true,
} })
