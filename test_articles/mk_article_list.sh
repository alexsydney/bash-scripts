#!/bin/sh

if [[ -z "$1" ]]; then
    echo "arguments: \"mysql_connect_string\" [create|drop]"
    echo "example: \"-h webprodpa -u user =ppassword ucsf_drupal_prod\""
    echo "example: \"-h webprodpa -u user =ppassword ucsf_drupal_prod\""
    echo
    echo "Be sure to include the quote around your connect string."
    exit 1
fi

connect=$1
msql="$connect --raw -sN -e"
dir='articles'
query="select '---';select concat('- :new: ', new_path, char(10), '  :old: ', old_path) from ee_legacy_urls"
mysql $connect --raw -sN -e "$query" > urls.yaml
CURL="curl -w \"
%{http_code} %{size_download} %{url_effective}
\" --progress-bar -o "

host=webprod.pa.ucsf.edu
dir=articles

mysql $msql "select concat('mkdir $dir/', entry_id) from ee_legacy_urls;" > mk_dirs
query="select concat('echo \"', new_path, '\" > $dir/', entry_id, '/new_path') from ee_legacy_urls;
select concat('echo \"', old_path, '\" > $dir/', entry_id, '/old_path') from ee_legacy_urls;"
mysql $msql "$query" > mk_url_files

query="select concat('$CURL ', ' $dir/', entry_id, '/old_article.html \"', old_path, '\"') from ee_legacy_urls;"
mysql $msql "$query" > download_old_articles

query="select concat('$CURL ', ' $dir/', entry_id, '/new_article.html http://$host/', new_path) from ee_legacy_urls;"
mysql $msql "$query" > download_new_articles

