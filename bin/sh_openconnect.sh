#!/bin/bash

VPN_EXECUTABLE=/opt/homebrew/bin/openconnect
VPN_HOST="anyconnect.s3gov.com"
VPN_USERNAME="athiede-admin@s3gov.com"

VPN_PASSWORD="$(/opt/homebrew/bin/op item get --vault Employee azure --fields password --reveal)"

function token() {
osascript <<EOF
		tell app "System Events"
			text returned of (display dialog "Enter $1 token:" with hidden answer default answer "" buttons {"OK"} default button 1 with title "$(basename $0)")
		end tell
EOF
}
TOKEN=$(token)
#echo -e "${VPN_PASSWORD}\n$(token)\n"
#echo "running: sudo $VPN_EXECUTABLE --useragent=AnyConnect -u \"$VPN_USERNAME\" \"$VPN_HOST/$VPN_GROUP\""
echo -e "${VPN_PASSWORD}\n${TOKEN}\n" | sudo $VPN_EXECUTABLE --useragent=AnyConnect -u "$VPN_USERNAME" "$VPN_HOST/$VPN_GROUP" --passwd-on-stdin
