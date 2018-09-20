#! /bin/sh
docker run --rm --volume dockerserver_maildata:/var/mail -v "$(pwd)":/backups -ti tvial/docker-mailserver tar cfz /backups/docker-mailserver.tgz /var/mail
