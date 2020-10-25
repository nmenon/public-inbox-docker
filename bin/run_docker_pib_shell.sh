#!/bin/bash

DOCKER_NAME="nishanthmenon/public-inbox:latest"
SERVER_NAME="pib-shell"

source `dirname $0`/docker_2include_pib.sh
VOLUMES="$VOLUMES /home/firefly:/firefly"
source `dirname $0`/docker_0include.sh

# Debug things
docker run -it --rm --name $SERVER_NAME $V "$DOCKER_NAME" bash
