#!/bin/bash
set -e
export HOME=/tmp
source /etc/profile
shopt -s expand_aliases
NPROC=`nproc`

# https://git.kernel.org/pub/scm/git/git.git/
if [ -n "$GIT_VERSION" ]; then
	export GIT_TAG=$GIT_VERSION
else
	export GIT_TAG=2.30.1
fi


download_build_install_git()
{
	cd /tmp/
	FILE=git-"$GIT_TAG".tar.gz
	URL="https://git.kernel.org/pub/scm/git/git.git/snapshot/${FILE}"
	wget -O "$FILE" "$URL"
	mkdir /tmp/git
	tar -C /tmp/git --strip-components=1 -xvf "$FILE"
	rm $FILE
	cd /tmp/git
	make -j "$NPROC" prefix=/usr/local
	make -j "$NPROC" prefix=/usr/local install
	cd /tmp
	rm -rf /tmp/git*
}

download_build_install_git

rm $0
