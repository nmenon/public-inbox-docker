#!/bin/bash
set -e
mbsync -c /data/docker/docker-config/mbsync-config/mbsyncrc.imap -Va
mbsync -c /data/docker/docker-config/mbsync-config/mbsyncrc.public-inbox -Va
mbsync -c /data/docker/docker-config/mbsync-config/mbsyncrc.patchworks -Va


/home/location/bin/public-inbox-compact
/home/location/bin/public-inbox-index

# Do patchwork stuff


# Now that everything is downloaded pushed etc.. if this is executed between a 15 min window once a week, we will
# clean up our local copy so that it will percolate everywhere. (Expunge Both)
dow=`date +%u`
hr=`date +%H`
min=`date +%M`
if [ "$dow" == "6" -a "$hr" == "20" -a $min -gt 0 -a $min -lt 30 ]; then
	# Cleanup all our "original" copies of emails.. so that it syncs back to server on the next run
	rm /data/mailing_list_emails/original/INBOX/*/*
fi
