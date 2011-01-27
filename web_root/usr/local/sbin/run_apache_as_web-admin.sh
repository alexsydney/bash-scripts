###############################################################################
#                                                                             #
#        run_apache_as_web-admin.sh                                           #
#                                                                             #
#   Updates the Apache configuration file to inform it to run the server      #
#   as user web-admin, for the purposes of administrative events that         #
#   require the web server to have write privileges in its document root.     #
#                                                                             #
#   Author: Tyler Gannon <tyler@medallurgy.com>                               #
#                                                                             #
#                                                                             #
###############################################################################

sed -i  's/User web-server/User web-admin/g' /etc/httpd/conf/httpd.conf 
/etc/init.d/httpd restart

echo "I have changed the web server to run as user web-admin."
echo "Don't forget to change it back."
echo "You should consider this an insecure state for the web server."

