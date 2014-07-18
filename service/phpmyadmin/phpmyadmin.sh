#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -ex

status () {
  echo "---> ${@}" >&2
}

# An osixia/mariadb container is linked to this phpMyAdmin container
if [ -n "${DB_NAME}" ]; then
  DB_HOST=${DB_PORT_3306_TCP_ADDR}
  DB_ROOT_USER=${DB_ENV_ROOT_USER}
  DB_ROOT_PWD=${DB_ENV_ROOT_PWD}
else
  DB_HOST=${DB_HOST}
  DB_ROOT_USER=${DB_ROOT_USER}
  DB_ROOT_PWD=${DB_ROOT_PWD}
fi

USE_EXTENDED_FEATURES=${USE_EXTENDED_FEATURES}

if [ ! -e /etc/phpmyadmin/docker_bootstrapped ]; then
  status "configuring phpMyAdmin for first run"

  # phpMyAdmin DB host config
  sed -i "s/dbserver=''/dbserver='${DB_HOST}'/g" /etc/phpmyadmin/config-db.php

 if [ "$USE_EXTENDED_FEATURES" = true ] ; then

    # Create phpMyAdmin database
    gunzip /usr/share/doc/phpmyadmin/examples/create_tables.sql.gz 
    mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST < /usr/share/doc/phpmyadmin/examples/create_tables.sql

    # Set correct phpMyAdmin table name
    sed -i "s/'pma_/'pma__/g" /etc/phpmyadmin/config.inc.php

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

    # Set phpMyAdmin user password 
    sed -i "s/dbpass='[^']*'/dbpass='${PMA_USER_PWD}'/g" /etc/phpmyadmin/config-db.php
  
  fi

  # Correct issue
  # https://bugs.launchpad.net/ubuntu/+source/php-mcrypt/+bug/1240590
  ln -s ../conf.d/mcrypt.so /etc/php5/mods-available/mcrypt.so
  php5enmod mcrypt

  # nginx config
  ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/phpmyadmin
  rm /etc/nginx/sites-enabled/default

  ## Fix some security stuff
  ## https://wiki.phpmyadmin.net/pma/Security

  # An osixia/mariadb container is linked to this phpMyAdmin container
  if [ -n "${DB_NAME}" ]; then

    # Remove root access from docker network
    mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "DELETE FROM mysql.user WHERE User='root' and Host='172.17.%.%';"
    mysql -u $DB_ROOT_USER -p$DB_ROOT_PWD -h $DB_HOST -e "FLUSH PRIVILEGES;"

  fi


  # Remove setup directory
  rm -rf /usr/share/phpmyadmin/setup

  # Change php directories owner
  chown -R www-data:www-data /usr/share/phpmyadmin/
  chown -R www-data:www-data /etc/phpmyadmin/

  # Change config file chmod
  chmod 660 /etc/phpmyadmin/config.inc.php
  chmod 660 /etc/phpmyadmin/config-db.php 

  touch /etc/phpmyadmin/docker_bootstrapped
else
  status "found already-configured phpLDAPadmin"
fi
