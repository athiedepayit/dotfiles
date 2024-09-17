#!/usr/bin/env bash
# launches alacritty window if it's running
# otherwise just opens the app

app_path="/Applications/Alacritty.app"
app_id="org.alacritty"

function openwindow() {
	alacritty msg create-window
}

if aerospace list-apps|grep $app_id; then
	echo "launching new instance"
	openwindow
else
	echo "launching alacritty"
	open $app_path
fi

