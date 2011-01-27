###############################################################################
#                                                                             #
#   mysql_purge_binlogs.sh                                                    #
#                                                                             #
#   Purges binary logs from mysql, removing records older than 15 days.       #
#                                                                             #
#                                                                             #
#   author: Tyler Gannon <tyler@medallurgy.com>                               #
#                                                                             #
#                                                                             #
#                                                                             #
###############################################################################


source '/usr/local/sbin/settings.sh.include'

expire_date=`date -u --date "now -15 days" "+%Y-%m-%d"`
query="PURGE BINARY LOGS BEFORE '$expire_date 00:00:00';"

mysql -h $primary_host -p$password -u $user $db -sN -e "$query"
mysql -h $alternate_host -p$password -u $user $db -sN -e "$query"
