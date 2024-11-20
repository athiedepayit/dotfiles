#!/usr/bin/env bash

api="https://api.cloudflare.com/client/v4"
account="df8bb2e3d50cb08b06f60f359672f07f"
zone_id="s3licensing.net"
token="$(op item get --vault Employee 'cloudflare api token' --reveal --fields label=password)"

verify() {
    curl -s \
	-H "Authorization: Bearer $token" \
	-H "Content-Type:application/json" \
	-X GET "$api/accounts/$account/tokens/verify"
}

list_scripts() {
    curl -s \
	-H "Authorization: Bearer $token" \
	-H "Content-Type:application/json" \
	-X GET "$api/accounts/$account/workers/scripts"
}

list_script_settings() {
    scripts=$(list_scripts | jq -r '.result[].id')
    echo $scripts
    for script in $scripts; do
	curl -s \
	    -H "Authorization: Bearer $token" \
	    -H "Content-Type:application/json" \
	    -X GET "$api/accounts/$account/workers/scripts/$script/script-settings"
    done
}

$1
