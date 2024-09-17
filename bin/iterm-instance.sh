#!/usr/bin/env bash
# launches iterm window if it's running
# otherwise just opens the app

app_path="/Applications/iTerm.app"
app_id="com.googlecode.iterm2"

function itermwindow() {
	    osascript &>/dev/null <<EOF
        tell application "iTerm2"
			create window with default profile
        end tell
EOF
}

if aerospace list-apps|grep $app_id; then
	echo "launching new window"
	itermwindow
else
	echo "launching iterm"
	open $app_path
fi

