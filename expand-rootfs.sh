#!/bin/bash

VERSION="0.1"

if (($EUID < 1)); then
    export ROOTDEV=$(mount | grep ' / '|cut -d' ' -f 1)
    export ROOTPART=$(lsblk -no NAME $ROOTDEV)
    export ROOTDISK=$(lsblk -no PKNAME $ROOTDEV)
    export ROOTPARTNUM=$(cat /sys/class/block/$ROOTPART/partition)

    echo "============================"
    echo "|  Rootfs expander script  |"
    echo "|       version $VERSION        |"
    echo "|     bugreports here      |"
    echo ">>>> Snoop05B@gmail.com <<<<"
    echo ""
    echo "'$ROOTDEV' is mounted as '/'"
    echo "'/dev/$ROOTDISK' is disk that contain your '/' partition"
    if (fdisk -l /dev/$ROOTDISK | grep -c dos) &> /dev/null; then
        echo "'/dev/$ROOTDISK' has 'dos' partition table"
    fi
    if (fdisk -l /dev/$ROOTDISK | grep -c gpt) &> /dev/null; then
        echo "'/dev/$ROOTDISK' has 'gpt' partition table"
    fi
    echo ""
    read -p "Continue (y/n)?" CHOICE
    case "$CHOICE" in 
        y|Y|yes|Yes|YES ) export CONTINUE=true;;
        n|N|no|No|NO ) echo "Aborted by user." & exit;;
        * ) echo "What's that supposed to mean?" & exit;;
    esac

    if [ "$CONTINUE" = "true" ]; then
        echo ""
        echo "Resizing partition..."
        if (fdisk -l /dev/$ROOTDISK | grep -c dos) &> /dev/null; then
            fdisk /dev/$ROOTDISK <<PARTCMD
d
$ROOTPARTNUM
n
p
$ROOTPARTNUM


w
PARTCMD
        fi

        if (fdisk -l /dev/$ROOTDISK | grep -c gpt) &> /dev/null; then
        fdisk /dev/$ROOTDISK <<PARTCMD
d
$ROOTPARTNUM
n
$ROOTPARTNUM


w
PARTCMD
        fi

        echo "Reloading new partition table..."
        partx -u /dev/$ROOTDISK

        echo ""
        echo "Resizing root filesystem..."
        resize2fs -p /dev/$ROOTPART

        echo "Done!"
    fi
fi

if (($EUID != 0)); then
    echo "This script must be run as root!"
    echo "Type your root password (default is 'root')"
    su root -c "sh ${0}"
fi
