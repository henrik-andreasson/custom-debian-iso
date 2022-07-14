#!/bin/bash

date_ts=$(date +"%Y-%m-%d_%H.%M.%S")

while getopts i:v:s: flag; do
  case $flag in
    i) isoname="$OPTARG";
      ;;
    o) output=$OPTARG;
      ;;
    s) source=$OPTARG;
        ;;
    ?)
      exit;
      ;;
  esac
done


if [ "x$isoname" = "x" ] ; then
  isoname="snapshot-${date_ts}"
fi

if [ "x$output" = "x" ] ; then
  output="custom-debian-iso-${isoname}-11.0.0-amd64.iso"
fi

if [ "x$source" = "x" ] ; then
  source="server"
fi


xorriso -as mkisofs -r -checksum_algorithm_iso md5,sha1,sha256,sha512 \
  -V "$isoname" \
  -o  "$output" \
  -J -joliet-long \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -b isolinux/isolinux.bin -c isolinux/boot.cat \
  -boot-load-size 4 -boot-info-table -no-emul-boot \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus $source
