###############################################################################
#                                                                             #
# httpd configuration guide                                                   #
#                                                                             #
# The original files are stored in conf.backup, and the conf.d files          #
# have been backed up to conf.backup/conf.d.                                  #
#                                                                             #
# A number of things have been turned off in httpd.conf, and almost           #
# everything in conf.d has been turned off.                                   #
#                                                                             #
# httpd.conf also has an Include directive to include conf/local/vhosts.conf. #
# That in turn includes things.  Here's how it looks:                         #
#                                                                             #
# httpd.conf                                                                  #
#   > local/vhosts.conf                                                       #
#       > www.ucsf.edu.conf                                                   #
#            > rewrite_rules.www.ucsf.edu.*.conf                              #
#       > rewrite_rules.<other_web_sites>.conf                                #
#                                                                             #
#  You'll also find the SSL certificate and key in conf/local.                #
#                                                                             #
#  enjoy!                                                                     #
#  Tyler Gannon <tyler@medallurgy.com>                                        #
#                                                                             #
###############################################################################













