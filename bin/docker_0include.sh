#!/bin/bash

S=`docker ps|grep $SERVER_NAME`
C=""
if [ -n "$S" ]; then
	C=`echo $S|cut -d " " -f1`
fi

ACTION="START"
while getopts ":lspS" opt; do
  case ${opt} in
    l ) # logs
    	ACTION="LOG"
      ;;
    s ) # Stop Container
    	ACTION="STOPD"
      ;;
    p ) # Purge - Stop container, delete image
    	ACTION="PURGE"
      ;;
    S) # Check status if running
    	ACTION="STATUS"
      ;;
    \? ) echo "Usage: $0 [-l] [-s] [-p] [-S]"
    	echo "-l : Logs"
	echo "-s : Stop and delete container"
	echo "-S : Check Status"
	echo "-p : Purge: Stop and delete container, remove all images"
	exit 0
      ;;
  esac
done

if [ "$ACTION" == "LOG" ]; then
	if [ -z "$C" ]; then
		echo "Nothing running?"
		exit 1
	fi
	echo "Container ID: $C"
	docker logs $C
	exit 0
fi
if [ "$ACTION" == "STATUS" ]; then
	name=`basename $0|cut  -d '_' -f2-|cut -d '.' -f1`
	if [ -z "$C" ]; then
		echo -e "$name: \e[33m\e[101m\e[1m\e[5mDOWN\e[0m";
	else
		echo -e "$name: \e[92m\e[1mOKAY\e[0m";
	fi
	exit 0
fi

# Stop the container if needed.
if [ -n "$C" ]; then
	echo "Container ID: $C"
	if [ "$ACTION" == "START" ]; then
		echo "Unable to start container.. image already running: $S"
		exit 1
	fi
	if [ "$ACTION" == "STOPD" -o "$ACTION" == "PURGE" ]; then
		docker container stop $C
		docker container rm $C
	fi
fi
if [ "$ACTION" == "STOPD" ]; then
	echo "Cleanedup container"
	exit 0
fi
if [ "$ACTION" == "PURGE" ]; then
	echo "Purging image $DOCKER_NAME"
	IM=`docker image ls $DOCKER_NAME|grep -v REPOSITORY`
	if [ -n "$IM" ]; then
		docker image rm "$DOCKER_NAME"
	fi
	echo "Purged"
	exit 0
fi

# So we are starting docker here..

V=""
for VOL in $VOLUMES
do
	V="$V -v $VOL"
done

# Pick up the latest docker image
docker pull "$DOCKER_NAME"

# Rest of the script takes care of starting docker correctly
