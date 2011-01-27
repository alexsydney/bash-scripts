###############################################################################
#                                                                             #
#   dont_run_apache_as_web-admin.sh                                           #
#                                                                             #
#   Updates the Apache configuration file to inform it to run the server      #
#   as user web-server, after it has been changed to run as web-admin         #
#   for some administrative purpose.                                          #
#                                                                             #
#   Author: Tyler Gannon <tyler@medallurgy.com>                               #
#                                                                             #
#                                                                             #
###############################################################################


sed -i  's/User web-admin/User web-server/g' /etc/httpd/conf/httpd.conf 
/etc/init.d/httpd restart

echo "Good job, you remembered."
echo "Apache is running as web-server again."
echo "You may return to your normal way of life."

