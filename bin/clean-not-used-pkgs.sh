#!/bin/bash

notused_pkgs="
./pool/main/p/plasma-workspace/
./pool/main/o/open-gram/
./pool/main/e/evolution/
./pool/main/e/emacs/
./pool/main/libr/libreoffice/
./pool/main/m/matplotlib/
./pool/main/k/kde*
./pool/main/f/firefox-esr
./pool/main/t/texlive-base/
./pool/main/n/norwegian/
./pool/main/c/chromium/
./pool/main/i/inkscape/
./pool/main/m/mate-*
./g/gnucash-docs
./t/texlive-extra
./t/thunderbird
./q/qtwebengine-opensource-src
./g/gimp-help
./libr/libreoffice-*
./w/wireshark
./w/webkit2gtk
./m/mesa

"

for file in ${notused_pkgs} ; do
	if [ -x "$file" ] ; then
		echo $file
		rm -rf $file
	fi
done
