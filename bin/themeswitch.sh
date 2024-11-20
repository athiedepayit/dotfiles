#!/usr/bin/env bash

# get current macos theme
current_theme=$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')
if [[ "$current_theme" == "true" ]]; then
	echo "Switching to light"
	osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
	sed -i -e 's/dark.toml/light.toml/g' ~/.config/alacritty/alacritty.toml
else
	echo "Switching to dark"
	osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
	sed -i -e 's/light.toml/dark.toml/g' ~/.config/alacritty/alacritty.toml
fi
