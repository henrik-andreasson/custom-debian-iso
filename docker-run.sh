#!/bin/bash

docker build -t custom_debian_iso .

#    --entrypoint "/build/bin/make-srv-iso.sh" \
#--entrypoint "/bin/bash" \

docker run -it \
    --entrypoint "/build/bin/make-srv-iso.sh" \
    --mount type=bind,source=/opt/custom-debian-iso/server/,target=/build/source \
    --mount type=bind,source=/opt/custom-debian-iso/iso/,target=//build/iso \
    --mount type=bind,source=/opt/custom-debian-iso/repos/,target=//build/repos \
    custom_debian_iso \
    -s /build/source/baseiso-2024-debian-12.7.0/ \
    -o /build/iso/
