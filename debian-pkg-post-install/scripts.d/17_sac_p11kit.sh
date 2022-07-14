#!/bin/bash

mkdir -p /etc/pkcs11/modules/

cat<<__EOF__>/etc/pkcs11/modules/sac.module
module: /usr/lib/libeToken.so
__EOF__
