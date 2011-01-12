#!/bin/sh
###############################################################################
#                                                                             #
#       allow_root_login_to_webprod.sh                                        #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
###############################################################################

server=webprodpa
user=rsync

if (( "$1" == "--help" || "$1" == "-?" )); then
	echo $0
	echo "Logs in to $server and allows user to log in as $user using ssh key"
	echo in place of password.
	echo
	echo Usage:
	echo "  $1 [user] [server]"
	echo "    Log in as user@server.  Default user: $user.  Default server: $server."
	echo "  $1 (--help || -?)"
	echo "    Show this helpful instruction."
	exit 1
fi

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [[ ! -e /root/.ssh/id_rsa.pub ]]; then
	echo "First need to create an SSH key.  Recommend not adding a passphrase."
	echo "Also recommend not distributing this file any further than right here."
	ssh-keygen
fi

read -p "Log in to $server as $user and allow passwordless login? (y/n)"
if [[ "$REPLY" -eq "y" ]]; then
	ssh-copy-id -i /root/.ssh/id_rsa.pub $user@$server
	echo
	read -p "Press any key to log in to $server to negotiate keys. Once logged in, just log back out."
	ssh $user@$server	
	echo Done.
else
	echo "Fine then."
	exit 1
fi

