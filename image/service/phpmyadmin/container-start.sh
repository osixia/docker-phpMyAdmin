#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpmyadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create phpMyAdmin vhost
  if [ "${PHPMYADMIN_HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-helper "/container/service/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CRT_FILENAME" "/container/service/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_KEY_FILENAME" --ca-crt=/container/service/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CA_CRT_FILENAME

    # add CA certificat config if CA cert exists
    if [ -e "--ca-crt=/container/service/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CA_CRT_FILENAME" ]; then
      sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" /container/service/phpmyadmin/assets/apache2/phpmyadmin-ssl.conf
    fi

    a2ensite phpmyadmin-ssl

  else
    a2ensite phpmyadmin
  fi

  # phpMyAdmin directory is empty, we use the bootstrap
  if [ ! "$(ls -A /var/www/phpmyadmin)" ]; then
    cp -R /var/www/phpmyadmin_bootstrap/* /var/www/phpmyadmin
    rm -rf /var/www/phpmyadmin_bootstrap

    echo "link /container/service/phpmyadmin/assets/config.inc.php to /var/www/phpmyadmin/config.inc.php"
    ln -s /container/service/phpmyadmin/assets/config.inc.php /var/www/phpmyadmin/config.inc.php

    # phpMyAdmin Absolute URI
    sed -i "s|{{ PHPMYADMIN_CONFIG_ABSOLUTE_URI }}|${PHPMYADMIN_CONFIG_ABSOLUTE_URI}|g" /var/www/phpmyadmin/config.inc.php

    get_salt () {
      salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:/{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
    }

    # phpMyAdmin cookie secret
    get_salt
    sed -i "s|{{ PHPMYADMIN_BLOWFISH_SECRET }}|${salt}|g" /var/www/phpmyadmin/config.inc.php

    append_to_servers() {
      TO_APPEND=$1
      sed -i "s|{{ PHPMYADMIN_SERVERS }}|${TO_APPEND}\n{{ PHPMYADMIN_SERVERS }}|g" /var/www/phpmyadmin/config.inc.php
    }

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
        append_to_servers "$to_print['$key']=$php_value;"

      # it's just a not empty value
      elif [ -n "$value" ]; then
        local php_value=$(print_by_php_type $value)
        append_to_servers "$to_print['$key']=$php_value;"
      fi
    }

    PHPMYADMIN_CONFIG_DB_TABLES=($PHPMYADMIN_CONFIG_DB_TABLES)
    pma_storage_config (){

      append_to_servers "\$cfg['Servers'][$1]['controlhost'] = '${PHPMYADMIN_CONFIG_DB_HOST}';"
      append_to_servers "\$cfg['Servers'][$1]['controlport'] = '${PHPMYADMIN_CONFIG_DB_PORT}';"
      append_to_servers "\$cfg['Servers'][$1]['controluser'] = '${PHPMYADMIN_CONFIG_DB_USER}';"
      append_to_servers "\$cfg['Servers'][$1]['controlpass'] = '${PHPMYADMIN_CONFIG_DB_PASSWORD}';"
      append_to_servers "\$cfg['Servers'][$1]['pmadb'] = '${PHPMYADMIN_CONFIG_DB_NAME}';"

      for table_infos in "${PHPMYADMIN_CONFIG_DB_TABLES[@]}"
      do
        table=(${!table_infos})
        append_to_servers "\$cfg['Servers'][$1]['${!table[0]}'] = '${!table[1]}';"
      done
    }

    PHPMYADMIN_DB_HOSTS=($PHPMYADMIN_DB_HOSTS)
    i=1
    for host in "${PHPMYADMIN_DB_HOSTS[@]}"
    do

      #host var contain a variable name, we access to the variable value and cast it to a table
      infos=(${!host})

      # it's a table of infos
      if [ "${#infos[@]}" -gt "1" ]; then
        append_to_servers "\$cfg['Servers'][$i]['host'] = '${!infos[0]}';"
        pma_storage_config $i
        host_infos "\$cfg['Servers'][$i]" ${infos[1]}

      # it's just a host name
      # stored in a variable
      elif [ -n "${!host}" ]; then
        append_to_servers "\$cfg['Servers'][$i]['host'] = '${!host}';"
        pma_storage_config $i

      # directly
      else
        append_to_servers "\$cfg['Servers'][$i]['host'] = '${host}';"
        pma_storage_config $i
      fi

      ((i++))
    done

    sed -i "/{{ PHPLDAPADMIN_SERVERS }}/d" /var/www/phpldapadmin/config/config.php

  fi

  touch $FIRST_START_DONE
fi

# Fix file permission
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;
chmod 400 /var/www/phpmyadmin/config.inc.php
chown www-data:www-data -R /var/www

exit 0
