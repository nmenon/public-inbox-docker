#!/bin/bash
set -e
export HOME=/tmp
PBI_SOURCE=${PBI_SOURCE:-snapshot}
source /etc/profile
shopt -s expand_aliases
NPROC=`nproc`

# https://public-inbox.org/public-inbox.git
if [ -n "$PBI_VERSION" ]; then
	export GIT_TAG=$PBI_VERSION
else
	export GIT_TAG=1.6.1
fi

download_build_install_public_inbox()
{
	if [ "$PBI_SOURCE" = checkout ]; then
		PBI_DIR=/tmp/public-inbox
		rm -f "$PBI_DIR/.git"
	else
		cd /tmp/
		FILE=public-inbox-"$GIT_TAG".tar.gz
		URL="https://public-inbox.org/public-inbox.git/snapshot/${FILE}"
		wget -O "$FILE" "$URL"
		PBI_DIR=/tmp/pbi
		mkdir "$PBI_DIR"
		tar -C "$PBI_DIR" --strip-components=1 -xvf "$FILE"
		rm "$FILE"
	fi
	cd "$PBI_DIR"
	perl Makefile.PL
	make -j "$NPROC"
	# build test fails in 1.6.0
	# make test
	make install
	cp Makefile /usr/local/
	cd /tmp
	rm -rf "$PBI_DIR"
}

download_build_install_public_inbox

rm $0
