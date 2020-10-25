Flow
====

NOTE: Even though public-inbox CAN read from imap folders directly, I prefer a
backup and a controlled flow to avoid race if possible (lost email while trying
to clean up corporate imap folder due to space constraints etc..)

So, this does look a bit convoluted..

![Flow](flow.png)


mbsync config files
===================

* mbsyncrc.imap -> pulls email to a master maildir
* mbsyncrc.patchworks -> creates a copy from master maildir for patchwork
* mbsyncrc.public-inbox -> creates another copy from master maildir for public-inbox

Scripts
=======

* mbsync-cron.sh -> This runs all my  mail cleanup push pull etc sequences
  I use systemd to enable it, but cronjob will do just fine as well.
* [list-archive-maker](https://git.kernel.org/pub/scm/linux/kernel/git/mricon/korg-helpers.git/plain/list-archive-maker.py) - I use this to convert patchwork maildir to mbox and feed to patchworks:
```
      python manage.py parsearchive --list-id list@example.com /firefly/*.mbox
```

