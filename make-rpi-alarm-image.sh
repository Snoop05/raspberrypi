#!/bin/bash

set -e

VERSION="0.1"

show_help() 
{
echo "Usage: $0 {rpi|rpi-2} [options]"
echo "Default filename: ArchLinuxARM-%Y.%m-{rpi|rpi-2}.img"
echo ""
echo "Options:"
echo " -f, --file <file>     manually choose filename"
echo " -t, --tempdir <dir>   manually choose temporary directory"
echo "                         default is 'temp'"
echo "                         if exists, 'temp[N]' (e.g. 'temp1') is used"
echo " -h  --help            display this help and exit"
echo " -V  --version         output version information and exit"
}

filename() { echo "ArchLinuxARM-$DATE-$TARGET.img"; }

FILE=""
TARGET=""
TEMP="temp"


while :; do
    case $1 in
        -h|--help)
            show_help
            exit
            ;;
        -V|--version)
            echo "Version $VERSION"
            exit
            ;;
        rpi)
                TARGET="rpi"
                shift
            ;;
        rpi-2)
                TARGET="rpi-2"
                shift
            ;;
        -f|--file)
            if [ -n "${2}" ] && [ "${2}" != "-t" ]; then
                FILE=${2}
                shift 2
                continue
            else
                echo "ERROR: --file requires a non-empty option argument." >&2
                exit 2
            fi
            ;;
        -t|--tempdir)
            if [ -n "${2}" ] && [ "${2}" != "-f" ]; then
                TEMP=${2}
                shift 2
                continue
            else
                echo "ERROR: --tempdir requires a non-empty option argument." >&2
                exit 3
            fi
            ;;
        ?*)
            echo "WARNING: Unknown option (ignored): $1" >&2
            shift
            ;;
        *)
            break
    esac
done

if [ -z "$TARGET" ]; then
    echo "ERROR: TARGET not given. See --help." >&2
    exit 1
fi

echo "Creating temporary directory..."
if [ ${TEMP} == temp ]; then
    i="1"
    while [ -d "${TEMP}" ]; do
        TEMP=temp$i
        i=$[$i+1]
    done
fi

if [ -d "${TEMP}" ]; then
    echo "WARNING: Temporary directory exists."
else mkdir ${TEMP}
fi

DATE=$(date +%Y.%m)
echo "Downloading Arch Linux ARM tarball..."
set +e
if (ping -c 1 google.com > /dev/null 2>&1) ; then
    wget http://os.archlinuxarm.org/os/rpi/ArchLinuxARM-$DATE-$TARGET-rootfs.tar.gz -O ${TEMP}/ArchLinuxARM-$DATE-$TARGET-rootfs.tar.gz
    if [ $? -eq 8 ]; then
        DATE=$(date -d "-1 month" +%Y.%m)
        wget http://os.archlinuxarm.org/os/rpi/ArchLinuxARM-$DATE-$TARGET-rootfs.tar.gz -O ${TEMP}/ArchLinuxARM-$DATE-$TARGET-rootfs.tar.gz
    fi
else
   echo "ERROR: No internet."
   exit 4
fi
set -e

echo "Downloading expand-rootfs script..."
wget http://snoop05.uhostall.com/Raspberry%20Pi/expand-rootfs -O ${TEMP}/expand-rootfs

if [ -z ${FILE} ]; then
    FILE=$(filename)
fi

echo "Creating empty sdcard image..."
dd if=/dev/zero of=${TEMP}/image.img bs=1MB count=1800 status=progress

echo "Partitioning sdcard image..."
fdisk ${TEMP}/image.img <<EOF
o
n
p
1

+100M
t
c
n
p
2


w
EOF

echo "Creating loop device..."
LOOP=$(losetup -f)
losetup ${LOOP} ${TEMP}/image.img
partprobe ${LOOP}

echo "Creating filesystems..."
mkfs.vfat -n boot -F 32 ${LOOP}p1
mkfs.ext4 -L root ${LOOP}p2

echo "Mounting filesystems..."
mkdir ${TEMP}/boot ${TEMP}/root
mount ${LOOP}p1 ${TEMP}/boot
mount ${LOOP}p2 ${TEMP}/root

echo "Extracting tarball..."
bsdtar -xpf ${TEMP}/ArchLinuxARM-$DATE-$TARGET-rootfs.tar.gz -C ${TEMP}/root
mv ${TEMP}/root/boot/* ${TEMP}/boot/
echo "Copying expand-rootfs script..."
cp ${TEMP}/expand-rootfs ${TEMP}/root/usr/local/bin/expand-rootfs
chmod 777 ${TEMP}/root/usr/local/bin/expand-rootfs

echo "Unmounting image..."
sync
umount ${TEMP}/boot ${TEMP}/root
losetup -d ${LOOP}

echo "Cleaning temporary files..."
mv ${TEMP}/image.img ${FILE}
rm -rf ${TEMP}

echo "Done!"
echo "You can run 'expand-rootfs' after logging in."
