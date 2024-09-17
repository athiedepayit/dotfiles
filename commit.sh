#!/usr/bin/env bash
cp "$HOME"/.config/alacritty/* .
cp "$HOME"/.config/tmux/tmux.conf tmux.conf
cp "$HOME/.config/nvim/init.lua" nvim_init.lua 
cp "$HOME"/.config/aerospace/* .
cp "$HOME/.vimrc" vimrc
cp "$HOME/.bashrc" bashrc
cp "$HOME/Library/Application Support/Code/User/settings.json" .
cp "$HOME/.local/bin/*" bin/
git add .
git commit -m "update $(date +%Y%m%d\ %H:%M)"
