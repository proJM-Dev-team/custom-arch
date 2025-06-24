from color_manager import utils

src     = "papirus-icon-theme/Papirus" 
name    = "papirus-gruvbox"
dest    = "/usr/share/icons/"
palette = "gruvbox.json"

utils.recolor(src, dest, name, palette)