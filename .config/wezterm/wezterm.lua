-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

config.color_scheme = 'GruvboxDark'
config.font = wezterm.font 'JetBrains Mono Nerd'
config.enable_wayland = true

-- Finally, return the configuration to wezterm:
return config