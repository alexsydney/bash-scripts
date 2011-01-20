#!/bin/sh

#######################################################################
#   
#   sync_from_dx24n1.sh
#   Author: Tyler Gannon <tyler@medallurgy.com>
#   Date: 20 Dec 2010
#   
#   Pulls media files from dx24n1 according to the map I wrote.
#   See google doc at http://tinyurl.com/ucsf-media-map for more info.
#   
#######################################################################

src_server='dx24n1'
src_root='/var/www/html'
media_dir='/var/www/multimedia'
dest_root="$media_dir/legacy"
log_file="/tmp/sync_from_dx24n1.log"
user='tgannon'
recipients='tgannon@gmail.com'
if [ -e $log_file ]; then rm $log_file; fi

function copy_files(){
	rsync -rtvu $user@$src_server:"$src_root/$1/*" "$dest_root/$2" 2>>$log_file
	if [ $? -ne 0 ]; then
		errors='yes'
	fi
}

copy_files 'main_site/images' 'images'
copy_files 'main_site/media' 'media'
copy_files 'main_site/pdf' 'pdf'
copy_files 'main_site/z_multimedia' 'z_multimedia'
copy_files 'main_site/sciencecafe/images' 'news/images'
copy_files 'main_site/sciencecafe/pdf' 'news/pdf'
copy_files 'news_site/images' 'news/images'
copy_files 'news_site/multimedia' 'news/multimedia'
copy_files 'today/daily' 'today/daily'
copy_files 'today/images' 'today/images'
copy_files 'ahw/images' 'today/images'
copy_files '_graphics' 'images'

mv $dest_root/media/podcast/sciencecafe/* $media_dir/podcast/sciencecafe/
mv $dest_root/pdf/eir/* $media_dir/pdf/eir
mv $dest_root/images/science_cafe/* $dest_root/news/images/stories/

if [ -n "$errors" ]; then
    subject="Errors encountered syncing files from $src_server"
	mail -s "$subject" $recipients < $log_file
	exit 1
else
	exit 0
fi
