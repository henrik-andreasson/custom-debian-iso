#!/bin/bash

if [ "x$1" != "x" ] ; then

	EFI_MENU_DIR=$1
else
	EFI_MENU_DIR="server/boot/grub/"
fi


while getopts u:i: flag; do
  case $flag in
    i) isolinux="$OPTARG";
      ;;
    u) uefidir=$OPTARG;
      ;;
    ?)
      exit;
      ;;
  esac
done


if [ "x$isolinux" == "x" ] ; then
	echo "-i isolinux dir - where the preseed files are"
	exit -1
fi

if [ "x$uefidir" == "x" ] ; then
	echo "-u uefidir dir - where the grub.cfg file are"
	exit -2
fi

cat<<__EOF__>$uefidir/grub.cfg

if loadfont $prefix/font.pf2 ; then
  set gfxmode=800x600
  set gfxpayload=keep
  insmod efi_gop
  insmod efi_uga
  insmod video_bochs
  insmod video_cirrus
  insmod gfxterm
  insmod png
  terminal_output gfxterm
fi

if background_image /isolinux/splash.png; then
  set color_normal=light-gray/black
  set color_highlight=white/black
elif background_image /splash.png; then
  set color_normal=light-gray/black
  set color_highlight=white/black
else
  set menu_color_normal=cyan/blue
  set menu_color_highlight=white/blue
fi

insmod play
play 960 440 1 0 4 440 1
set theme=/boot/grub/theme/1



__EOF__


for cfg in ${isolinux}/preseed-*cfg ; do
	filename=$(basename $cfg)
	hostnamex=$(echo $filename | sed 's/preseed-//' | sed 's/\.cfg//' )

cat<<__EOF__>>$uefidir/grub.cfg


menuentry --hotkey=6 'Install $hostnamex' {
    set background_color=black
    linux    /install.amd/vmlinuz vga=788 --- quiet  auto=true file=/cdrom/isolinux/$filename
    initrd   /install.amd/initrd.gz
}


__EOF__

done
