#!/bin/bash

docker build -t custom_debian_iso .

#    --entrypoint "/build/bin/make-srv-iso.sh" \
#--entrypoint "/bin/bash" \

docker run --rm -it \
    --entrypoint "/build/bin/make-srv-iso.sh" \
    --mount type=bind,source=/opt/custom-debian-iso/server/,target=/build/source \
    --mount type=bind,source=/home/han/iso-and-repo/iso-storage-b/configs/,target=/build/configs \
    --mount type=bind,source=/opt/custom-debian-iso/iso/,target=//build/iso \
    --mount type=bind,source=/opt/repos/,target=/build/repos \
    custom_debian_iso \
    -s /build/source/acert-iso-2025-10/ \
    -o /build/iso/ \
    -r /build/repos \
    -c /build/configs \
    -n acert-storageb-2026v1
#    -g /build/repos/custom-repo.gpg \
