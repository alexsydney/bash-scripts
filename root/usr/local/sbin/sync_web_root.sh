#!/bin/sh

#######################################################################
#   
#   /usr/local/sbin/sync_web_root.sh
#   Author: Tyler Gannon <tyler@medallurgy.com>
#   Date: 20 Dec 2010
#   
#   Synchronizes the given directory tree with rsync,
#   Sends an email if there is an error.
#   
#######################################################################

default_rsync_options="-rtvu --user=apache --group=apache --delete --copy-links --ignore-errors"

if [ -z "$1" ]; then
	echo "sync_web_root"
	echo
	echo "   Mirrors files between document roots using rsync."
	echo "      options passed to rsync are: $default_rsync_options"
	echo "   "
	echo "usage: /usr/local/sbin/sync_web_root.sh user@source [recipients] [src_root] [dest_root] [rsync_options]"
	echo "examples:"
	echo "    /usr/local/sbin/sync_web_root.sh rsync@webaltpa"
	echo "         copy files from webaltpa as user rsync, and print any errors to stdout when done."
	echo
	echo "    /usr/local/sbin/sync_web_root.sh rsync@webaltpa 'user@domain,user2@otherdomain"
	echo "         copy files from webaltpa as user rsync, and send any errors to users in list."
	echo "src_root and dest_root are optional parameters relative to filesystem root on respective servers."
	echo "rsync_options overrides the default options passed to rsync, which are:"
	echo "         $default_rsync_options"
	echo "**** Notice especially the --copy-links "
	exit 1
fi	

# default source and destination roots
src_root='/var/www/drupal'
dest_root='/var/www/drupal'

log_file="/tmp/rsync.log"
conn_info=$1
recipients=$2

# Add source and destination from command parameters if specified.
if [ -n "$3" ]; then src_root=$3; fi
if [ -n "$4" ]; then dest_root=$4; fi
# Remove any existing log file.
if [ -e $log_file ]; then rm $log_file; fi

rsync -rtvu --user=apache --group=apache --delete --copy-links --ignore-errors $conn_info:$src_root/* $dest_root 2>>$log_file

if [ $? -ne 0 ]; then
	subject="Errors encountered syncing files from $conn_info to `hostname`"
	if [ -n "$recipients" ]; then
		mail -s $subject $recipients < $log_file
	else
		echo $subject
		cat $log_file
	fi
	exit 1
else
	exit 0
fi
