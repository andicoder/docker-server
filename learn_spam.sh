#! /bin/sh

for dir in `/usr/bin/docker exec mail ls /var/mail/***REMOVED***.de/`
do
	/usr/bin/docker exec mail sa-learn --spam /var/mail/***REMOVED***.de/$dir/.Junk --dbpath /var/mail-state/lib-amavis/.spamassassin
	/usr/bin/docker exec mail sa-learn --ham /var/mail/***REMOVED***.de/$dir/cur --dbpath /var/mail-state/lib-amavis/.spamassassin
done
