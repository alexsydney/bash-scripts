#!/bin/sh

user='ucsfdrupal'
password='08$cuR3'
dbhost='dbpa.ucsf.edu'
db='ucsf_drupal_prod'


query="select old_path, substring(old_path, 8+position('/' in replace(old_path, 'http://', ''))), new_path from ee_legacy_urls;"


#for i in $(cat example.txt); do echo $i; done
mysql -h $dbhost -p$password -u $user $db -sN -e "$rewrite_rules_query"

