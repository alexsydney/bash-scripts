source '/usr/local/sbin/settings.sh.include'

message_file='message.txt'
if [ -e $message_file ]; then
  rm $message_file
fi

increment=$autoincrement_increment

#  The strategy:
#  Get the most recent id added into primary/replication.replication_status, and expect to find that same
#  id in the alternate.  If not, report back.  Do the same for the alternate.
for master in $primary_host $alternate_host; do
  message="Checking replication for master $master"
  echo $message
  [ $master == $primary_host ] && slave=$alternate_host || slave=$primary_host
  [ $master == $primary_host ] && offset=$primary_autoincrement_offset || offset=$alternate_autoincrement_offset
  
  GET_SLAVE_STATS=`mysql -h $slave -p$password -u $user $db -sN -e 'show slave status;'`
  
  slave_io_running=`echo "$GET_SLAVE_STATS" | cut -f 11`
  slave_sql_running=`echo "$GET_SLAVE_STATS" | cut -f 12`
  replication_error=`echo "$GET_SLAVE_STATS" | cut -f 20`
  if [[ $slave_io_running != 'Yes' ]]; then
    echo "Replication io is not running on replication subscriber $slave" | tee -a $message_file  
    echo "The most recent error message is: $replication_error" | tee -a $message_file  
  fi

  if [[ $slave_sql_running != 'Yes' ]]; then
    echo "Replication appears to have stopped on replication subscriber $slave" | tee -a $message_file  
    echo "The most recent error message is: $replication_error" | tee -a $message_file  
  fi
  
  get_id_query="select id from replication_monitor where id%$increment=$offset order by id desc limit 1;"
  master_last_id=$(mysql -h $master -p$password -u $user $db -sN -e "$get_id_query")
  if [ $? -ne 0 ]; then
    echo "Problem connecting to mysql server $master while checking replication" | tee -a $message_file
    master_last_id=-1
  fi

  slave_last_id=$(mysql -h $slave -p$password -u $user $db -sN -e "$get_id_query")
  if [ $? -ne 0 ]; then 
    echo "Problem connecting to mysql server $slave while checking replication" | tee -a $message_file
    slave_last_id=-2
  fi
  if [ $master_last_id -ne $slave_last_id ]; then
    source '/usr/local/sbin/replication_failure_message.sh.include'
  fi

  # Now do a little cleanup -- write a new value to the database, flush old binary logs, and clear old replication messages.
  mysql -h $master -p$password -u $user $db -sN -e "delete from replication_monitor where datediff(now(), updated_at) > 30"
  if [ $? -ne 0 ]; then echo "Error deleting old replication monitor info." | tee -a $message_file ; fi
  mysql -h $master -p$password -u $user $db -sN -e "insert into replication_monitor (inserted_at) values('$master')"
  if [ $? -ne 0 ]; then echo "Error inserting next replication timestamp." | tee -a $message_file ; fi

  if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi
done

if [ -e $message_file ]
then
  cat $message_file | /bin/mail -s "Replication failure message from `hostname`" $recipients
fi

