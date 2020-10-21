#!/bin/bash
set -e
export HOME=/tmp
source /etc/profile
shopt -s expand_aliases
NPROC=`nproc`

# https://public-inbox.org/public-inbox.git
if [ -n "$PBI_VERSION" ]; then
	export GIT_TAG=$PBI_VERSION
else
	export GIT_TAG=1.6.0
fi

download_build_install_public_inbox()
{
	cd /tmp/
	FILE=public-inbox-"$GIT_TAG".tar.gz
	URL="https://public-inbox.org/public-inbox.git/snapshot/${FILE}"
	wget -O "$FILE" "$URL"
	mkdir /tmp/pbi
	tar -C /tmp/pbi --strip-components=1 -xvf "$FILE"
	rm $FILE
	cd /tmp/pbi
	perl Makefile.PL
	make -j "$NPROC"
	# build test fails in 1.6.0
	# make test
	make install
	cp Makefile /usr/local/
	cd /tmp
	rm -rf /tmp/pbi*
}

download_build_install_public_inbox

rm $0
