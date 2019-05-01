#!/bin/bash
echo c[_] Are you running this as root?

if [ $EUID -ne 0 ]
then 
    echo c[_] You ain\'t running this as root?!? RUN AS ROOT!!!
    exit 1
fi

apt-get update --fix-missing
apt-get autoclean
apt-get -f install
dpkg --configure -a
apt-get -f install
apt-get -u dist-upgrade
