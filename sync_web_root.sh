#!/bin/sh

#######################################################################
#   
#   sync_web_root.sh
#   Author: Tyler Gannon <tyler@medallurgy.com>
#   Date: 20 Dec 2010
#   
#   Synchronizes the given directory tree with rsync,
#   Sends an email if there is an error.
#   
#######################################################################

src_server='webprodpa'
src_root='/var/www'
dest_root='/var/www'
log_file="/tmp/rsync.log.`date +%Y%m%d`"
user='rsync'
recipients='tgannon@gmail.com'

if [ -e $log_file ]; then rm $log_file; fi

function copy_files(){
	rsync -rtvu --delete --copy-links $user@$src_server:$src_root/$1/* $dest_root/$2 2>>$log_file
	if [ $? -ne 0 ]; then
		errors='yes'
	fi
}

copy_files 'webprod.pa.ucsf.edu', 'webalt.pa.ucsf.edu'

if [ -n "$errors" ]; then
	mail -s "Errors encountered syncing files from $src_server to `hostname`" $recipients < $log_file
	exit 1
else
	exit 0
fi
