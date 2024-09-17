#!/usr/bin/env bash
config_dirs="alacritty tmux nvim aerospace"
for dir in $config_dirs; do
	mkdir -p "$HOME/.config/$dir"
done

# alacritty
cp alacritty.toml "$HOME/.config/alacritty/"
cp dark.toml "$HOME/.config/alacritty/"
cp light.toml "$HOME/.config/alacritty/"
# tmux
cp tmux.conf "$HOME/.config/tmux/tmux.conf"
# nvim
cp nvim_init.lua "$HOME/.config/nvim/init.lua"
# aerospace
cp aerospace.toml "$HOME/.config/aerospace/"
# vim
cp vimrc "$HOME/.vimrc"
# bashrc
cp bashrc "$HOME/.bashrc"

