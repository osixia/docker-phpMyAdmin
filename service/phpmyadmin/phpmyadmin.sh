#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -ex

status () {
  echo "---> ${@}" >&2
}

# a mariadb container is linked to this phpMyAdmin container
if [ -n "${DB_NAME}" ]; then
  DB_HOST=${DB_PORT_3306_TCP_ADDR}
else
  DB_HOST=${DB_HOST}
fi

if [ ! -e /etc/phpmyadmin/docker_bootstrapped ]; then
  status "configuring phpMyAdmin for first run"

  # phpMyAdmin DB host config
  sed -i "s/dbserver=''/dbserver='${DB_HOST}'/g" /etc/phpmyadmin/config-db.php

  # Create phpMyAdmin database
  gunzip /usr/share/doc/phpmyadmin/examples/create_tables.sql.gz 

  #mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "CREATE DATABASE IF NOT EXISTS phpmyadmin DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;"
  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST phpmyadmin < /usr/share/doc/phpmyadmin/examples/create_tables.sql

  # Generate phpMyAdmin user password
  PMA_USER_PWD=`makepasswd --chars 16`

  # Create phpMyAdmin user and privileges
  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT USAGE ON mysql.* TO 'phpmyadmin'@'localhost' IDENTIFIED BY '${PMA_USER_PWD}';"
  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT USAGE ON mysql.* TO 'phpmyadmin'@'%' IDENTIFIED BY '${PMA_USER_PWD}';"

  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT (Host, User, Select_priv, Insert_priv, Update_priv, Delete_priv,Create_priv, Drop_priv, Reload_priv, Shutdown_priv,Process_priv,File_priv, Grant_priv, References_priv, Index_priv, Alter_priv,Show_db_priv, Super_priv, Create_tmp_table_priv, Lock_tables_priv,Execute_priv,Repl_slave_priv, Repl_client_priv) ON mysql.user TO 'phpmyadmin'@'localhost';"
  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT (Host, User, Select_priv, Insert_priv, Update_priv, Delete_priv,Create_priv, Drop_priv, Reload_priv, Shutdown_priv,Process_priv,File_priv, Grant_priv, References_priv, Index_priv, Alter_priv,Show_db_priv, Super_priv, Create_tmp_table_priv, Lock_tables_priv,Execute_priv,Repl_slave_priv, Repl_client_priv) ON mysql.user TO 'phpmyadmin'@'%';"

  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT ON mysql.db TO 'phpmyadmin'@'localhost';"
  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT ON mysql.db TO 'phpmyadmin'@'%';"

  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT ON mysql.host TO 'phpmyadmin'@'localhost';"
  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT ON mysql.host TO 'phpmyadmin'@'%';"

  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT (Host, Db, User, Table_name, Table_priv, Column_priv) ON mysql.tables_priv TO 'phpmyadmin'@'localhost';"
  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT (Host, Db, User, Table_name, Table_priv, Column_priv) ON mysql.tables_priv TO 'phpmyadmin'@'%';"

  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'phpmyadmin'@'localhost';"
  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'phpmyadmin'@'%';"

  mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "FLUSH PRIVILEGES;"

  # Set correct phpMyAdmin table name
  sed -i "s/'pma_/'pma__/g" /etc/phpmyadmin/config.inc.php

  # Set phpMyAdmin user password 
  sed -i "s/dbpass='[^']*'/dbpass='${PMA_USER_PWD}'/g" /etc/phpmyadmin/config-db.php


  # Correct issue
  # https://bugs.launchpad.net/ubuntu/+source/php-mcrypt/+bug/1240590
  ln -s ../conf.d/mcrypt.so /etc/php5/mods-available/mcrypt.so
  php5enmod mcrypt

  # nginx config
  ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/phpmyadmin
  rm /etc/nginx/sites-enabled/default

  touch /etc/phpmyadmin/docker_bootstrapped
else
  status "found already-configured phpLDAPadmin"
fi
