
MYSQL="mysql -h vx34 -u tyler -pmr.c00l ucsf_drupal_dev -sN -e"
for table in `$MYSQL "show tables"`; do
    echo "Converting table $table"
    $MYSQL "ALTER TABLE $table TYPE=InnoDB;"
done

