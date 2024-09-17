#!/usr/bin/env bash
config_dirs="alacritty tmux nvim aerospace"
for dir in $config_dirs; do
	mkdir -p "$HOME/.config/$dir"
done

install_dots() {
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
	# vscode
	mkdir -p "$HOME/Library/Application Support/Code/User/"
	cp settings.json "$HOME/Library/Application Support/Code/User/"
}

install_bin() {
	mkdir -p "$HOME/.local/bin"
	cp bin/* "$HOME/.local/bin/"
}

brew_packages() {
	# brew install
	# generated with brew list --installed-on-request
	brew install $(cat brew_packages)
	# generated with brew list --cask
	brew install --cask $(cat brew_casks)
}

install_dots
brew_packages
