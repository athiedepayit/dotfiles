#!/usr/bin/env bash

fileserver="s3-fs-01.s3gov.com"
domain="s3gov.com"

kdestroy -a
echo "Is your VPN connected?"
ping -c1 $fileserver > /dev/null

if [ $? -ne 0 ]; then
	echo "Can't ping the file server"
	exit 1
fi

while getopts 'u:p:h' OPTION; do
    case "$OPTION" in
	u)
	    username="$OPTARG"
	    ;;
	p)
	    password="$OPTARG"
	    ;;
	h)
	    usage
	    ;;
	?)
	    usage
	    exit 1
	    ;;
    esac
done

if [ -z "$username" ];then
	read -p "username: " username
fi

if [ -z "$password" ];then
	read -p "password (will not echo): " -s password
	echo
fi

#mount_smbfs -o username=$username,password=$password //$fileserver/S3Share ~/Public/S3Share

#osascript -e 'tell application "Finder" to mount volume "smb://s3-fs-01.s3gov.com/S3Share"'

#echo -e "$password\n" | kinit --keychain "${username}@${domain}"

open "smb://$username:$password@$fileserver/S3Share"

sleep 5

klist
