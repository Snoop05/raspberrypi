#!/bin/bash

if (($EUID < 1)); then
    cp /boot/config.txt /boot/config.bak
    cp /boot/cmdline.txt /boot/cmdline.bak
    cp /boot/config-openelec.txt /boot/config.txt
    cp /boot/cmdline-openelec.txt /boot/cmdline.txt
fi

if (($EUID != 0)); then
    echo "This script must be run as root!"
    echo "Type your root password (default is 'root')"
    su root -c "sh ${0}"
fi
