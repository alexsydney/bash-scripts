###############################################################################
#                                                                             #
#   mysql_purge_binlogs.sh                                                    #
#                                                                             #
#   Purges binary logs from mysql, removing any "used" log files.             #
#                                                                             #
#                                                                             #
#   author: Tyler Gannon <tyler@medallurgy.com>                               #
#                                                                             #
#                                                                             #
#                                                                             #
###############################################################################


source '/usr/local/sbin/settings.sh.include'

declare -a slave_status_results
echo Purging binary logs...
for master in $primary_host $alternate_host; do
    echo $master
    [ $master == $primary_host ] && slave=$alternate_host || slave=$primary_host

    slave_status_results=(`mysql -h $slave -u $user -p$password -sN -e "show slave status;"`)
    log_file=${slave_status_results[10]}

    expire_date=`date -u --date "now -2 hours" "+%Y-%m-%d"`
    query="PURGE BINARY LOGS TO '$log_file';"

    mysql -h $master -p$password -u $user $db -sN -e "$query"
    if [ $? -ne 0 ]; then echo "Error purging binary logs at $master" && exit 1; fi
done

echo done.
exit 0
