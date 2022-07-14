#!/bin/bash

if [ "x$1" != "x" ] ; then

	ISOLINUX_DIR=$1
else
	ISOLINUX_DIR="server/isolinux"
fi


cat<<__EOF__>$ISOLINUX_DIR/csws.cfg

menu hshift 4
menu width 70
include stdmenu.cfg

menu title Custom Debian ISO installer beta 001

LABEL local-boot
	MENU LABEL Local boot - Abort install
#	MENU DEFAULT
	KERNEL chain.c32
	APPEND hd0 0
# should be default at release to make operator make a decision on what to install

__EOF__

for cfg in ${ISOLINUX_DIR}/preseed-*cfg ; do
	filename=$(basename $cfg)
	hostnamex=$(echo $filename | sed 's/preseed-//' | sed 's/\.cfg//' )

cat<<__EOF__>>$ISOLINUX_DIR/csws.cfg
label
	menu label ^$hostnamex
	menu default
	kernel /install.amd/vmlinuz
	append auto=true priority=critical vga=788 initrd=/install.amd/initrd.gz --quiet file=/cdrom/isolinux/$filename
__EOF__

done
