#!/bin/sh
set -e 

echo " "
echo "Launching: /app/tun2proxy-bin --setup $*"
echo " "
cd /app
/app/tun2proxy-bin --setup $@
