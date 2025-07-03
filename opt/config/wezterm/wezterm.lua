-- Pull in the wezterm API
local wezterm = require "wezterm"

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

config.color_scheme = "GruvboxDark"
config.font = wezterm.font "JetBrainsMono Nerd Font Mono"
config.font_size = 9.0
config.enable_wayland = false 
config.enable_scroll_bar = true
config.window_close_confirmation = "NeverPrompt"
config.hide_tab_bar_if_only_one_tab = true

-- Finally, return the configuration to wezterm:
return config