#!/usr/bin/env bash

brew_u() {
    command -v brew > /dev/null
    if [[ ! $? -eq 0 ]];then
	return
    fi
    echo "Fetching brew updates..."
    brew_updates=$(brew outdated)
    if [[ "$brew_updates" == "" ]];then
	echo "No package updates"
    else
	echo -e "---\n$brew_updates\n---\n"
	read -p "brew upgrade? [y/n] " choice
	if [[ "$choice" == "y" ]];then
	    brew upgrade
	fi
    fi
    echo "---"
}

mas_u() {
    command -v mas > /dev/null
    if [[ ! $? -eq 0 ]];then
	return
    fi
    echo "Fetching app store updates..."
    mas_updates=$(mas outdated)
    if [[ "$mas_updates" == "" ]];then
	echo "No app store updates"
    else
	echo -e "---\n$mas_updates\n---\n"
	read -p "mas upgrade? [y/n] " choice
	if [[ "$choice" == "y" ]];then
	    mas upgrade
	fi
    fi
    echo "---"
}

system_u(){
    command -v softwareupdate > /dev/null
    if [[ ! $? -eq 0 ]];then
	return
    fi
    echo "Fetching system software updates..."
    software_updates=$(softwareupdate -l | grep 'Label:')
    if [[ "$software_updates" == "" ]];then
	echo "No software updates"
    else
	echo -e "---\n$software_updates\n---\n"
	read -p "softwareupdate -ai ? [y/n] " choice
	if [[ "$choice" == "y" ]];then
	    softwareupdate -ai
	fi
    fi
    echo "---"
}

apt_u(){
    command -v apt > /dev/null
    if [[ ! $? -eq 0 ]];then
	return
    fi
    echo "apt updates..."
    sudo apt-get update && sudo apt-get upgrade
    echo "---"
}

all() {
    brew_u
    mas_u
    system_u
    apt_u
}

case $1 in
    brew)
	brew_u;;
    mas)
	mas_u;;
    system)
	system_u;;
    apt)
	apt_u;;
    *)
	all;;
esac
