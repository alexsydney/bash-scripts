
host=`hostname`
RSYNC="sudo rsync -rtv --executability"

if [[ $host == "webprodpa" ]]; then
    sed -i  's/__server_ip__/64.54.134.33/g' web_root/etc/httpd/conf/local/vhosts.conf
    sed -i  's/__server_ip__/64.54.134.33/g' web_root/etc/httpd/conf/httpd.conf
    $RSYNC web_root/* / 
    $RSYNC webprod.pa/* / 
    sudo /usr/local/sbin/mk_mod_rewrite.conf.sh
fi

if [[ $host == "webaltpa" ]]; then
    sed -i  's/__server_ip__/64.54.134.34/g' web_root/etc/httpd/conf/local/vhosts.conf
    sed -i  's/__server_ip__/64.54.134.34/g' web_root/etc/httpd/conf/httpd.conf
    $RSYNC  web_root/* / 
    $RSYNC  webalt.pa/* / 
    sudo /usr/local/sbin/mk_mod_rewrite.conf.sh
fi

if [[ $host == "dbprodpa" ]]; then
    $RSYNC db_root/* /
    $RSYNC dbprod.pa/* / 
fi

if [[ $host == "dbaltpa" ]]; then
    $RSYNC db_root/* /
    $RSYNC dbalt.pa/* / 
fi

if [[ $host=="vx34" ]]; then
    host_name='dev.pa.ucsf.edu'
elif [[ $host=="stagepa" ]]; then
    host_name='stage.pa.ucsf.edu'
elif [[ $host="qapa" ]]; then
    host_name='qa.pa.ucsf.edu'
fi

if [[ $host == "vx34" || $host == "stagepa" || $host == "qapa"  ]]; then
    sed -i  "s/webprod.pa.ucsf.edu/$host_name/g"  web_root/etc/httpd/conf/local/www.ucsf.edu.conf
    $RSYNC web_root/* / 
    sudo /usr/local/sbin/mk_mod_rewrite.conf.sh
fi
