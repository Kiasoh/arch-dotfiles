local colors = require("colors")
hl.config({ general = {
    gaps_in = 10, gaps_out = 14, border_size = 0,
    col = { active_border = colors.on_surface, inactive_border = colors.on_primary_fixed },
    layout = "dwindle", resize_on_border = true,
} })
