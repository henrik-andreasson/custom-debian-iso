#!/bin/bash

date_ts=$(date +"%Y-%m-%d_%H.%M.%S")

if [ "x$1" != "x" ] ; then
  isoname=$1
else
  isoname="snapshot-${date_ts}"
fi


if [ "x$2" != "x" ] ; then
  output=$2
else
  output="custom-debian-iso-${isoname}-11.0.0-amd64.iso"
fi


xorriso -as mkisofs -r -checksum_algorithm_iso md5,sha1,sha256,sha512 \
  -V "$isoname" \
  -o  "$output" \
  -J -joliet-long \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -b isolinux/isolinux.bin -c isolinux/boot.cat \
  -boot-load-size 4 -boot-info-table -no-emul-boot \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus server
