#!/bin/sh
###############################################################################
#    sync_webroot_from_webprod.sh                                             #
#                                                                             #
#    The top-level driver for mirroring web doc_root between web servers.     #
#    The rsync user sccount should have read access to the entire /etc/www    #
#        directory on the source server.                                      #
#                                                                             #
#    An email will be sent in the event of any errors, but every attempt      #
#    is made regardless, to complete the job despite errors.                  #
#                                                                             #
###############################################################################
                                                                        
rsync_user=rsync
source_server=webprodpa
# recipients should be a comma-delimited list.
recipients=`/usr/local/sbin/email_recipients.sh`

/usr/local/sbin/sync_web_root.sh $rsync_user@$source_server "$recipients"

