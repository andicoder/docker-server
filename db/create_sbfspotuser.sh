#!/bin/sh

mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER '${SBFSPOT_USERNAME}'@'%' IDENTIFIED BY '${SBFSPOT_PASSWORD}'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER '${VOLKSZ_USERNAME}'@'%' IDENTIFIED BY '${VOLKSZ_PASSWORD}'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'";
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT INSERT ON SBFspot.* TO '${SBFSPOT_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT SELECT ON SBFspot.* TO '${SBFSPOT_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT UPDATE ON SBFspot.* TO '${SBFSPOT_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT INSERT ON volkszaehler.* TO '${SBFSPOT_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT SELECT ON volkszaehler.* TO '${SBFSPOT_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT UPDATE ON volkszaehler.* TO '${SBFSPOT_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT INSERT ON volkszaehler.* TO '${VOLKSZ_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT SELECT ON volkszaehler.* TO '${VOLKSZ_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT UPDATE ON volkszaehler.* TO '${VOLKSZ_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT UPDATE ON volkszaehler.* TO '${VOLKSZ_USERNAME}'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "DROP USER 'root'@'%'"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES"