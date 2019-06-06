#! /bin/bash
# Startup servidor Pop
##########################

/opt/docker/install.sh && echo "ok install"
/usr/sbin/xinetd -dontfork && echo "xinetd OK" 
