from color_manager import utils

src     = "papirus-icon-theme/Papirus-Dark" 
name    = "papirus-gruvbox"
dest    = "/usr/share/icons/"
color   = (0.5, 0.5, 0.5) # = rc.norm_hsl(180, 50, 50)
palette = "gruvbox.json"

utils.recolor(src, dest, name, color) # Either color, palette, or mapping.