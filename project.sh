#!/bin/bash

# 1. Install relevant applications on the local computer
# Identify apps needed

function inst()
{
	#1) nipe (https://github.com/htrgouvea/nipe)	
	git clone https://github.com/htrgouvea/nipe && cd nipe
	sudo cpan install Try::Tiny Config::Simple JSON
	sudo perl nipe.pl install
	#2) curl (https://www.cyberciti.biz/faq/how-to-install-curl-command-on-a-ubuntu-linux/)
	sudo apt install curl
	#3) geoiplookup (https://www.maketecheasier.com/ip-address-geolocation-lookups-linux/)
	sudo apt-get install geoip-bin
	#4) 		
	sudo apt-get install openssh-server
	#5) sshpass (https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
	sudo apt-get install sshpass	
}

# 2. Check if the connection is from your origin country. If no, continue.
function anon()
{
	function anonchecker()
	{
	read -p "What country are you in? " country
	user=$(whoami)
	ip=$(curl -s ifconfig.co)
	current=$(geoiplookup "$ip" | awk '{print $NF}')
	#checking case insensitive in while statement(https://stackoverflow.com/questions/1728683/case-insensitive-comparison-of-strings-in-shell-script)
	if [ "${current,,}" == "${country,,}" ]
	then
		echo "You are exposed"
	else
		echo "You are anonymous"
	fi
	}
	anonchecker
	var=$(anonchecker)
	while [ "$var" == "You are exposed" ]
	do	
		cd /home/$user/nipe
		sudo perl nipe.pl restart
		ip2=$(sudo perl nipe.pl status | grep Ip | awk '{print $NF}')
		current=$(geoiplookup "$ip2" | awk '{print $NF}')
		anonchecker
		var=$(anonchecker) 
	done
}

function vps()
{
	ip=$(curl -s ifconfig.co)
	#Installing app(https://www.kali.org/tools/whois/)
	apt install whois
	echo "$(whois "$ip")"
	#Installing app(https://installati.one/kalilinux/nmap/)
	apt-get -y install nmap	
	nmap "$ip"
	
}

inst
anon
#sshpass (https://stackoverflow.com/questions/22107610/shell-script-run-function-from-script-over-ssh)
sshpass -p P@s5w0Rd ssh root@134.209.110.3 "$(typeset -f vps); vps"

