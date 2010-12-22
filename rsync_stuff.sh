
sync -rucP --delete --force --ignore-errors -e ssh --copy-links 

sudo at  2200  <<EOQ
for mypath in 'main_site/media' 'main_site/z_multimedia' 'news_site/multimedia' 'main_site/images' 'news_site/images'
do
  rsync -ruc --ignore-errors -e ssh --copy-links ztgannon@dx24n1:/var/www/html/$mypath/*" "/var/www/html/$mypath" >> /var/log/rsync.log 2>&1
done
mail -s "Results of file sync" tyler@medallurgy.com < /var/log/rsync.log
EOQ




sudo rsync -rucv --ignore-errors --include-from=/home/gannon/extensions -e ssh --copy-links "tgannon@dx24n1:/var/www/html/*" "/var/www/html"
sudo at now + 1 minute <<EOQ
rsync -rucv --ignore-errors --include-from=/home/gannon/extensions -e ssh --copy-links "gannon@webprodpa:/var/www/html/" "/var/www/html" >> /var/log/rsync.log 2>&1
mail -s "Results of file sync" tyler@medallurgy.com < /var/log/rsync.log
EOQ




rsync -uv --include-from=/home/gannon/rsync-include.txt  "/var/www/html/news_site" "/var/www/html_do_trash_this" 



18G     /var/www/html/main_site/media
2.5G    /var/www/html/
4.7M    /var/www/html/news_site/multimedia
61M     /var/www/html/main_site/images
35M     /var/www/html/news_site/images



for mypath in 'main_site/media' 'main_site/z_multimedia' 'news_site/multimedia' 'main_site/images' 'news_site/images'
do
  echo rsync -ruc --delete --force --ignore-errors -e ssh --copy-links "tgannon@dx24n1:/var/www/html/$mypath/*" "/var/www/html/$mypath"
done




