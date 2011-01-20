###############################################################################
#                                                                             #
#   set_webroot_permissions.sh                                                #
#     resets and hardens permissions on /var/www                              #
#     also locks down permissions on /etc/httpd                               #
#                                                                             #
#   author: Tyler Gannon <tyler@medallurgy.com>                               #
#                                                                             #
###############################################################################

doc_root='/var/www'
drupal_root='/var/www/webprod.pa.ucsf.edu'

apache_user=web-server
webmin_user=web-admin
docroot_group=web-data
nagios_group=nagcmd

# Create web-data group if it's not already there.
if [[ -z "`grep $docroot_group /etc/group`" ]]; then 
    /usr/sbin/groupadd $docroot_group
fi

# Create user for apache or just add it to the group.
if [[ -z "`grep $apache_user /etc/passwd`" ]]; then
    /usr/sbin/useradd -s /sbin/nologin -g $docroot_group -M $apache_user
    /usr/sbin/usermod -a -G $docroot_group $apache_user
else
    if [[ -z "`grep $docroot_group /etc/group | grep $apache_user`" ]]; then
        /usr/sbin/usermod -a -G $docroot_group $apache_user
    fi
fi

# Make sure the apache user is in the nagios group
if [[ -z "`grep $nagios_group /etc/group | grep $apache_user`" ]]; then
    /usr/sbin/usermod -a -G $nagios_group $apache_user
fi

# If it doesn't exist, create $webmin_user user // don't let it log in.
if [[ -z "`grep $webmin_user /etc/passwd`" ]]; then
    /usr/sbin/useradd -s /sbin/nologin -g $docroot_group -M $webmin_user
fi

# Change ownership and group of all files and directories.
chown -R $webmin_user:$docroot_group $doc_root

# Change ownership and group of all symlinks.
find $doc_root -type l -exec chown -h $webmin_user:$docroot_group {} \;

# Set all folders and symlinks to rwxrw----
find $doc_root -type d -exec chmod u=rwx,g=rx,o= {} \;

# Set all files to   rw-r-----
find $doc_root -type f -exec chmod u=rw,g=r,o= {} \;

# Now let $docroot_group group write to the files directories.
# While we're at it, get rid of any php or htaccess files there.
for dir in "$drupal_root/media" "$drupal_root/sites/default/files"; do
    echo "Set permissions on $dir"
    find -L $dir -type d -exec chmod u=rwx,g=rwx,o= {} \;
    find -L $dir -type f -exec chmod u=rw,g=rw,o= {} \;
    for file in `find -L $dir -type f -iname "*.php"`; do
        rm $file
    done
    for file in `find -L $dir -type f -iname ".htaccess"`; do
        rm $file
    done
done

# Delete unwanted drupal files
for name in 'CHANGELOG.txt' 'COPYRIGHT.txt' 'INSTALL.pgsql.txt' \
            'LICENSE.txt' 'UPGRADE.txt' 'INSTALL.mysql.txt' 'INSTALL.txt' \
            'MAINTAINERS.txt' 'install.php'; do
    for file in `find $drupal_root -iname $name`; do
        rm $file
    done
done

#  Also make sure nobody dropped a writeable file into /etc/httpd
find /etc/httpd -type d -exec chmod u=rwx,g=rx,o=rx {} \;
find /etc/httpd -type f -exec chmod u=rw,g=r,o=r {} \;
