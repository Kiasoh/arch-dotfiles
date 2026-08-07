local colors = require("colors")
hl.config({ general = {
    gaps_in = 20, gaps_out = 40, border_size = 0,
    col = { active_border = colors.on_surface, inactive_border = colors.on_primary_fixed },
    layout = "dwindle", resize_on_border = true,
} })
