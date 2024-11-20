#!/bin/sh

export x=1

cf_ips=$(curl -s https://www.cloudflare.com/ips-v4/)
webapp_rg="oh"
webapp_name="owls-sp"
slot_name="qa"

for ip in $cf_ips; do
    az webapp config access-restriction add \
	--resource-group $webapp_rg \
	-n $webapp_name \
	--slot $slot_name \
	--rule-name "Cloudflare IP $x" \
	--action Allow \
	--ip-address $ip \
	--priority $((500+$x))
    export x=$((x+1))
done
