#!/bin/bash

if (($EUID < 1)); then
    mount -o remount,rw /flash
    cp /flash/config.txt /flash/config.bak
    cp /flash/cmdline.txt /flash/cmdline.bak
    cp /flash/config-archlinux.txt /flash/config.txt
    cp /flash/cmdline-archlinux.txt /flash/cmdline.txt
fi

if (($EUID != 0)); then
    echo "This script must be run as root!"
    echo "Type your root password (default is 'root')"
    su root -c "sh ${0}"
fi
