Docker Folder configs
=====================
* docker\_2include\_pib.sh -> setup the volume paths that you want..

Folders
-------
- /data/public-inbox/config:/workdir/.public-inbox -> this is where the "config" file is located
- /data/public-inbox/git-repos:/git-repos -> all the mail archive git repos are here
- /data/mailing\_list\_emails/public-inbox:/mbox -> this is where it syncs the maildirs from (ignore if you are using imap directly)

Docker Shell
============

* run\_docker\_pib\_shell.sh -> Go straight to Docker shell to play with any command etc..

   Use this to setup all the commands that you want to run - example: public-inbox-init etc..

Daemons:
--------

* public-inbox-httpd - Runs the httpd page
* public-inbox-nntpd - Runs the nntp
* public-inbox-watch - This syncs the emails to the git database

Periodic cleanup
----------------
* public-inbox-compact - GC
* public-inbox-index - Re-index xapian (might put this in a cron job OR as part of mbsync pull)

Usage
-----

The wrapper scripts all use the docker\_1include\_pib.sh which provides an uniform command interface..

* NOTE: -l and -S options are only useful for the Daemons

Example:

```
Usage: ./public-inbox-compact [-l] [-s] [-p] [-S]
-l : Logs
-s : Stop and delete container
-S : Check Status
-p : Purge: Stop and delete container, remove all images
```
