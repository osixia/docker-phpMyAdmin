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