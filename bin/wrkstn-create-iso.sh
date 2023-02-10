#!/bin/bash

xorriso -as mkisofs -r -checksum_algorithm_iso md5,sha1,sha256,sha512 \
  -V 'cs-debian-wrk' \
  -o cs-debian-wrk-10.10.0-amd64-cs002.iso \
  -J -joliet-long \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -b isolinux/isolinux.bin -c isolinux/boot.cat \
  -boot-load-size 4 -boot-info-table -no-emul-boot \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus wrk
