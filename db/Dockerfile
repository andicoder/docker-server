FROM mariadb:latest
# Add files 
ADD sbfspot.sql /docker-entrypoint-initdb.d/
ADD volkszaehler.sql /docker-entrypoint-initdb.d/
ADD create_sbfspotuser.sh /docker-entrypoint-initdb.d/create_sbfspotuser.sh
