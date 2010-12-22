source '/usr/local/sbin/settings.sh.include'

echo "Stopping slaves."
for server in $primary_host $alternate_host; do
  message="Stopping slave $server"
  echo $message
  mysql -h $server -u $user -p$password -sN -e "STOP SLAVE;"
  if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi
done

echo "Resetting masters."
for server in $primary_host $alternate_host; do
  message="resetting $server"
  echo $message
  mysql -h $server -u $user -p$password -sN -e "RESET MASTER;"
  if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi
done

echo "Dumping data to file."
for database in 'replication' 'ucsf_drupal_prod'; do
  message="dumping $database"
  echo $message
  mysqldump -h $primary_host -u $user -p$password -c $database > ~/$database.dump.sql
  if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi
done

echo "Restoring databases."
for database in 'replication' 'ucsf_drupal_prod'; do
  message="restoring $database"
  echo $message
  mysql -u $user -p$password -D $database -h $alternate_host < ~/$database.dump.sql
  if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi
done

echo "Setting master status."
for server in $primary_host $alternate_host; do
  message="resetting $server master status"
  echo $message
  [ $server == $primary_host ] && other=$alternate_host || other=$primary_host
  [ $server == $primary_host ] && other_ip=$alternate_ip || other_ip=$primary_ip
  
  set -- $(mysql -h $other -p$password -u $user -sN -e "SHOW MASTER STATUS;")
  log_file=$1
  log_pos=$2
  $(mysql -h $server -p$password -u $user -sN -e "CHANGE MASTER TO MASTER_HOST='$other_ip', MASTER_USER='$replication_user', MASTER_PASSWORD='$replication_password', MASTER_LOG_FILE='$log_file', MASTER_LOG_POS=$log_pos;")
  if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi
done

echo "Starting replication."
for server in $primary_host $alternate_host; do
  message="starting $server replication"
  echo $message
  $(mysql -h $server -p$password -u $user -sN -e "START SLAVE;")
  if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi
done



