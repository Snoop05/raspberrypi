# Raspberry Pi releated stuff

## [expand-rootfs.sh](expand-rootfs.sh)
* Script will expand root partition to full available size.
* Written for Arch Linux ARM on Pi but it should work on other distrubutions and computers.
* Should work with any kind of block device that holds root partition (internal sdcard and usb tested).
* Works with `dos` and `gpt` partition tables.

## [make-rpi-alarm-image.sh](make-rpi-alarm-image.sh)
* Script will download latest Arch Linux ARM rootfs tarball for selected Raspberry Pi model (`rpi` or `rpi-2`).
* Create disk image that can be flashed from any OS (no need to have Linux machine).
* Should work with 2GB and bigger sdcards.
* `expand-rootfs.sh` included in final disk image (`/usr/local/bin/expand-rootfs`) for resizing root partition (just type `expand-rootfs` after logging in).
* Prebuilt images available for download here: [To be uploaded](http://snoop05.uhostall.com/?dir=Raspberry%20Pi)

## More to come!
