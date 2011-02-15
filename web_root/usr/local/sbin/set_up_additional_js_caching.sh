
days_to_keep_data=14
src=/var/www/current-release-branch/www/sites/default/files
cache=/var/www/webprod.pa.ucsf.edu/layout_cache

log=/var/log/layout_cache.log

date +"%c" | tee -a $log

for type in css js; do
  cd $src/$type
  echo "rm" >> $log
  for file in `find "$cache/$type" -maxdepth 1 -mtime +$days_to_keep_data`; do
    rm -v $file | tee -a $log
  done
  echo "cp" >> $log
  cp -pv $src/$type/* $cache/$type  | tee -a $log
done

# find $cache -user root | xargs chown web-admin:web-data
