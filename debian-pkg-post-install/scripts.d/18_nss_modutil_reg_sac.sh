#!/bin/bash

mkdir -p /etc/skel/.pki/nssdb
modutil -dbdir sql:/etc/skel/.pki/nssdb -add etoken -libfile "/usr/lib/libeToken.so"
