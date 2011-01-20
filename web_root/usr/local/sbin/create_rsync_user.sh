###############################################################################
#                                                                             #
#     create_rsync_user.sh                                                    #
#                                                                             #
#     creates a user to be used by the cron job that logs in for              #
#     mirroring web roots between servers.                                    #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
###############################################################################

user=rsync
group=web-data

if (( "$1" == "--help" || "$1" == "-?" )); then
	echo $0
	echo creates a user to be used by the cron job that logs in for
	echo mirroring web roots between servers.  
	echo
	echo Usage:
	echo "  $1 [user] [group]"
	echo "    Creates a user and adds it to group.  Default user: $user.  Default group: $group."
	echo "  $1 (--help || -?)"
	echo "    Show this helpful instruction."
	exit 1
fi

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [[ -n $1 ]]; then
	user=$1
fi
if [[ -n $2 ]]; then
	group=$2
fi

if [[ -n `grep $user /etc/passwd` ]]; then
	echo "User $user already exists."
	read -p "Update $user user password? (y/n)"
	if [[ "$REPLY" -eq "y" ]]; then
		passwd $user
		echo "Done."
	else
		echo "Fine then."
		exit 1
	fi
else
	if [[ -z `grep ^$group /etc/group` ]]; then
		echo "Group $group doesn't exist.  Throw me a bone here..."
		exit 1
	else
		read -p "Create user $user and add to group $group? (y/n)"
		if [[ "$REPLY" -eq "y" ]]; then
			/usr/sbin/useradd -G $group $user
			passwd $user
			echo "Created new user."
		else
			echo "Fine then."
			exit 1
		fi
	fi
fi

echo "Now be sure to log in to ALT server and run /usr/local/sbin/allow_root_login_to_webprod.sh"
exit 0
