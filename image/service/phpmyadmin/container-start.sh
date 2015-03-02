#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpmyadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # phpMyAdmin directory is empty, we use the bootstrap
  if [ ! "$(ls -A /var/www/phpmyadmin)" ]; then
    cp -R /var/www/phpmyadmin_bootstrap/* /var/www/phpmyadmin
    rm -rf /var/www/phpmyadmin_bootstrap
  fi

  # create phpMyAdmin vhost
  if [ "${HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-kit "/osixia/phpmyadmin/apache2/ssl/$SSL_CRT_FILENAME" "/osixia/phpmyadmin/apache2/ssl/$SSL_KEY_FILENAME"

    # add CA certificat config if CA cert exists
    if [ -e "/osixia/phpmyadmin/apache2/ssl/$SSL_CA_CRT_FILENAME" ]; then
      sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" /osixia/phpmyadmin/apache2/phpmyadmin-ssl.conf
    fi

    a2ensite phpmyadmin-ssl

  else
    a2ensite phpmyadmin
  fi

  get_salt () {
    salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:|{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
  }

  # phpMyAdmin cookie secret
  get_salt
  sed -i "s/blowfish_secret'] = '/blowfish_secret'] = '${salt}/g" /osixia/phpmyadmin/config.inc.php

  print_by_php_type() {

    if [ "$1" == "True" ]; then
      echo "true"
    elif [ "$1" == "False" ]; then
      echo "false"
    elif [[ "$1" == array\(\'* ]]; then 
      echo "$1"
    else
      echo "'$1'"
    fi
  }

  # phpLDAPadmin servers config
  host_infos() { 

    local to_print=$1
    local infos=(${!2})

    for info in "${infos[@]}"
    do
      host_infos_value "$to_print" "$info"
    done
  }

  host_infos_value(){

    local to_print=$1
    local info_key_value=(${!2})

    local key=${!info_key_value[0]}
    local value=(${!info_key_value[1]})

    local value_of_value_table=(${!value})

    # it's a table of values
    if [ "${#value[@]}" -gt "1" ]; then
      host_infos "$to_print['$key']" ${info_key_value[1]}

    # the value of value is a table
    elif [ "${#value_of_value_table[@]}" -gt "1" ]; then
      host_infos_value "$to_print['$key']" "$value"

    # the value contain a not empty variable
    elif [ -n "${!value}" ]; then
      local php_value=$(print_by_php_type ${!value})
      echo "$to_print['$key']=$php_value;" >> /osixia/phpmyadmin/config.inc.php

    # it's just a not empty value
    elif [ -n "$value" ]; then
      local php_value=$(print_by_php_type $value)
      echo "$to_print['$key']=$php_value;" >> /osixia/phpmyadmin/config.inc.php
    fi
  }

  PHPMYADMIN_CONFIG_DB_TABLES=($PHPMYADMIN_CONFIG_DB_TABLES)
  pma_storage_config (){

    echo "\$cfg['Servers'][$1]['controlhost'] = '${PHPMYADMIN_CONFIG_DB_HOST}';" >> /osixia/phpmyadmin/config.inc.php
    echo "\$cfg['Servers'][$1]['controlport'] = '${PHPMYADMIN_CONFIG_DB_PORT}';" >> /osixia/phpmyadmin/config.inc.php
    echo "\$cfg['Servers'][$1]['controluser'] = '${PHPMYADMIN_CONFIG_DB_USER}';" >> /osixia/phpmyadmin/config.inc.php
    echo "\$cfg['Servers'][$1]['controlpass'] = '${PHPMYADMIN_CONFIG_DB_PASSWORD}';" >> /osixia/phpmyadmin/config.inc.php
    echo "\$cfg['Servers'][$1]['pmadb'] = '${PHPMYADMIN_CONFIG_DB_NAME}';" >> /osixia/phpmyadmin/config.inc.php

    for table_infos in "${PHPMYADMIN_CONFIG_DB_TABLES[@]}"
    do
      table=(${!table_infos})
      echo "\$cfg['Servers'][$1]['${!table[0]}'] = '${!table[1]}';" >> /osixia/phpmyadmin/config.inc.php
    done
  }

  DB_HOSTS=($DB_HOSTS)
  i=1
  for host in "${DB_HOSTS[@]}"
  do
    
    #host var contain a variable name, we access to the variable value and cast it to a table
    infos=(${!host})

    # it's a table of infos
    if [ "${#infos[@]}" -gt "1" ]; then
      echo "\$cfg['Servers'][$i]['host'] = '${!infos[0]}';" >> /osixia/phpmyadmin/config.inc.php
      pma_storage_config $i
      host_infos "\$cfg['Servers'][$i]" ${infos[1]}

    # it's just a host name
    else
      echo "\$cfg['Servers'][$i]['host'] = '${!host}';" >> /osixia/phpmyadmin/config.inc.php
      pma_storage_config $i
    fi

    ((i++))
  done

  # Fix file permission
  find /var/www/ -type d -exec chmod 755 {} \;
  find /var/www/ -type f -exec chmod 644 {} \;
  chmod 400 /osixia/phpmyadmin/config.inc.php
  chown www-data:www-data -R /osixia/phpmyadmin/config.inc.php
  chown www-data:www-data -R /var/www

  touch $FIRST_START_DONE
fi

exit 0