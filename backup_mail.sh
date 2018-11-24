
#! /bin/sh
/usr/bin/docker run --rm --volume dockerserver_maildata:/var/mail -v "/home/andreas/backup":/backups  tvial/docker-mailserver tar cfz /backups/docker-mailserver.tgz /var/mail
/usr/bin/docker exec mariadb-***REMOVED***sh -c 'exec mysqldump --all-databases -uroot -p3@_9#oX2bY]z,+Q_' > /home/andreas/backup/all-databases.sql

