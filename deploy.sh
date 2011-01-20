
host=`hostname`
RSYNC="sudo rsync -rtv --executability"

if [[ $host == "webprodpa" ]]; then
    $RSYNC web_root/* / 
    $RSYNC webprod.pa/* / 
    sudo /usr/local/sbin/mk_mod_rewrite.conf.sh
fi

if [[ $host == "webaltpa" ]]; then
    $RSYNC  web_root/* / 
    $RSYNC  webalt.pa/* / 
    sudo /usr/local/sbin/mk_mod_rewrite.conf.sh
fi

if [[ $host == "dbprodpa" ]]; then
    $RSYNC db_root/* /
    $RSYNC dbprod.pa/* / 
fi

if [[ $host == "dbaltpa" ]]; then
    $RSYNC b_root/* /
    $RSYNC dbalt.pa/* / 
fi

if [[ $host == "vx34" || $host == "stagepa" || $host == "qapa"  ]]; then
    $RSYNC web_root/* / 
    sudo /usr/local/sbin/mk_mod_rewrite.conf.sh
fi
