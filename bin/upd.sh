#!/usr/bin/env bash
brew_updates=$(brew outdated)
if [[ "$brew_updates" == "" ]];then
	echo "No package updates"
else
	echo -e "---\n$brew_updates\n---\n"
	read -p "upgrade? [y/n]" choice 
	if [[ "$choice" == "y" ]];then
		brew upgrade
	fi
fi


mas_updates=$(mas outdated)
if [[ "$mas_updates" == "" ]];then
	echo "No app store updates"
else
	echo -e "---\n$mas_updates\n---\n"
	read -p "upgrade? [y/n]" choice 
	if [[ "$choice" == "y" ]];then
		mas upgrade
	fi
fi

