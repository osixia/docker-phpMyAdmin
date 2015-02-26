#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpmyadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

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

  # phpMyAdmin servers config
  host_infos () { 

    local to_print=$1
    local infos=(${!2})

    for info in "${infos[@]}"
    do

      info_key_value=(${!info})

      local key=${!info_key_value[0]}
      local value=(${!info_key_value[1]})

      # it's a table of values
      if [ "${#value[@]}" -gt "1" ]; then
        host_infos "$to_print['$key']" ${info_key_value[1]}

      # it's just a not empty value
      elif [ -n "$value" ]; then
        echo "$to_print['$key']=$value;" >> /osixia/phpmyadmin/config.inc.php
      fi
    done
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