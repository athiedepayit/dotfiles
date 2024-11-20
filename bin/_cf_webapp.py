#!/usr/bin/env python3

import subprocess
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-r", "--resourcegroup", help="Web App RG")
parser.add_argument("-n", "--webapp", help="Web App Name")
parser.add_argument("-s", "--slot", help="Web App Slot")
args = parser.parse_args()

cf_ip_str=subprocess.check_output(["curl", "-s",  "https://www.cloudflare.com/ips-v4/"], text=True)
print(cf_ip_str)
cf_ips=cf_ip_str.split("\n")
for ip in cf_ips:
    print(f"IP: {ip}")
base_rule=500
num=1

if args.slot is None:
    for ip in cf_ips:
        cmd=f"az webapp config access-restriction add --resource-group {args.resourcegroup} -n {args.webapp} --rule-name \"Cloudflare IP {num}\" --action Allow --ip-address {ip} --priority {base_rule+num}"
        print(cmd)
        os.system(cmd)
        num+=1
else:
    for ip in cf_ips:
        cmd=f"az webapp config access-restriction add --resource-group {args.resourcegroup} -n {args.webapp} --slot {args.slot} --rule-name \"Cloudflare IP {num}\" --action Allow --ip-address {ip} --priority {base_rule+num}"
        print(cmd)
        os.system(cmd)
        num+=1

