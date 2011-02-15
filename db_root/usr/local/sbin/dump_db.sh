source '/usr/local/sbin/settings.sh.include'

database=$1
mysqldump -h $primary_host -u $2 -p$3 -c $database

