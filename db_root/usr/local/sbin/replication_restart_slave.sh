###############################################################################
#                                                                             #
#   replication_restart_slave                                                 #
#                                                                             #
#   use this when you just want to restart the replication slave              #
#   without synchronizing the data again.                                     #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
#                                                                             #
###############################################################################

source '/usr/local/sbin/settings.sh.include'

if [[ -z "$1" || "--help" == "$1" ]]; then
    echo "usage: replication_restart_slave [primary|alternate]"
    echo "to restart replication from primary to alternate, type:"
    echo "  replication_restart_slave primary"
    exit 1
fi     

[ $1 == "primary" ] && slave=$alternate_host || slave=$primary_host
[ $1 == "primary" ] && master=$primary_host || master=$alternate_host
[ $1 == "primary" ] && master_ip=$primary_ip || master_ip=$alternate_ip

echo "master: $master"
echo "slave: $slave"
echo "ip: $master_ip"

message="Stop slave."
mysql -h $slave -u $user -p$password -sN -e "STOP SLAVE;"
if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi

message="RESET MASTER"
mysql -h $master -u $user -p$password -sN -e "RESET MASTER;"
if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi

message="Restarting master."
set -- $(mysql -h $master -p$password -u $user -sN -e "SHOW MASTER STATUS;")
log_file=$1
log_pos=$2
mysql -h $slave -p$password -u $user -sN -e "CHANGE MASTER TO MASTER_HOST='$master_ip', MASTER_USER='$replication_user', MASTER_PASSWORD='$replication_password', MASTER_LOG_FILE='$log_file', MASTER_LOG_POS=$log_pos;"
if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi

message="Restarting slave."
mysql -h $slave -p$password -u $user -sN -e "START SLAVE;"
if [ $? -ne 0 ]; then echo "error during step $message, quitting" && exit 1; fi

echo "Done."
exit 0


