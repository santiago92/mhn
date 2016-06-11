#!/bin/bash

if [ "$(whoami)" != "root" ]
then
    echo -e "You must be root to run this script"
    exit 1
fi

set -e

MHN_HOME=`dirname "$(readlink -f "$0")"`
SCRIPTS="$MHN_HOME/scripts/"
cd $SCRIPTS

if [ -f /etc/redhat-release ]; then
    export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$PATH
    ./install_sqlite.sh

    if [ ! -f /usr/local/bin/python2.7 ]; then
        echo "[`date`] Installing Python2.7 as a pre-req"
        ./install_python2.7.sh
    fi

    ./install_supervisord.sh
fi

echo "[`date`] Starting Installation of all MHN packages"

echo "[`date`] ========= Installing hpfeeds ========="
./install_hpfeeds.sh

echo "[`date`] ========= Installing menmosyne ========="
./install_mnemosyne.sh

echo "[`date`] ========= Installing Honeymap ========="
./install_honeymap.sh

echo "[`date`] ========= Installing MHN Server ========="
./install_mhnserver.sh

echo "[`date`] ========= MHN Server Install Finished ========="
echo ""

chown www-data /var/log/mhn/mhn.log
supervisorctl restart mhn-celery-worker

echo "[`date`] Completed Installation of all MHN packages"
