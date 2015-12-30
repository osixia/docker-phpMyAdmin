#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpmyadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create phpMyAdmin vhost
  if [ "${PHPMYADMIN_HTTPS,,}" == "true" ]; then

    # check certificat and key or create it
    cfssl-helper phpmyadmin "/container/service/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CRT_FILENAME" "/container/service/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_KEY_FILENAME" "/container/service/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CA_CRT_FILENAME"

    # add CA certificat config if CA cert exists
    if [ -e "--ca-crt=/container/service/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CA_CRT_FILENAME" ]; then
      sed -i --follow-symlinks "s/#SSLCACertificateFile/SSLCACertificateFile/g" /container/service/phpmyadmin/assets/apache2/phpmyadmin-ssl.conf
    fi

    a2ensite phpmyadmin-ssl

  else
    a2ensite phpmyadmin
  fi

  # phpMyAdmin directory is empty, we use the bootstrap
  if [ ! "$(ls -A /var/www/phpmyadmin)" ]; then
    cp -R /var/www/phpmyadmin_bootstrap/* /var/www/phpmyadmin
    rm -rf /var/www/phpmyadmin_bootstrap

    echo "copy /container/service/phpmyadmin/assets/config.inc.php to /var/www/phpmyadmin/config.inc.php"
    cp -f /container/service/phpmyadmin/assets/config.inc.php /var/www/phpmyadmin/config.inc.php

    # phpMyAdmin Absolute URI
    sed -i --follow-symlinks "s|{{ PHPMYADMIN_CONFIG_ABSOLUTE_URI }}|${PHPMYADMIN_CONFIG_ABSOLUTE_URI}|g" /var/www/phpmyadmin/config.inc.php

    get_salt () {
      salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:/{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
    }

    # phpMyAdmin cookie secret
    get_salt
    sed -i --follow-symlinks "s|{{ PHPMYADMIN_BLOWFISH_SECRET }}|${salt}|g" /var/www/phpmyadmin/config.inc.php

    append_to_file() {
      TO_APPEND=$1
      sed -i --follow-symlinks "s|{{ PHPMYADMIN_SERVERS }}|${TO_APPEND}\n{{ PHPMYADMIN_SERVERS }}|g" /var/www/phpmyadmin/config.inc.php
    }

    append_value_to_file() {
      local TO_PRINT=$1
      local VALUE=$2
      local php_value=$(print_by_php_type "$VALUE")
      append_to_file "$TO_PRINT=$php_value;"
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

    host_info(){

      local to_print=$1

      for info in $(complex-bash-env iterate "$2")
      do

        local isRow=$(complex-bash-env isRow "${!info}")

        if [ $isRow = true ]; then
          local key=$(complex-bash-env getRowKey "${!info}")
          local value=$(complex-bash-env getRowValue "${!info}")

          if [ $(complex-bash-env isTable "$value") = true ] || [ $(complex-bash-env isRow "$value") = true ]; then
            host_info "$to_print['$key']" "$value"
          else
            append_value_to_file "$to_print['$key']" "$value"
          fi
        else
          append_value_to_file "$to_print" "$info"
        fi

      done
    }

    pma_storage_config (){

      append_to_file "\$cfg['Servers'][$1]['controlhost'] = '${PHPMYADMIN_CONFIG_DB_HOST}';"
      append_to_file "\$cfg['Servers'][$1]['controlport'] = '${PHPMYADMIN_CONFIG_DB_PORT}';"
      append_to_file "\$cfg['Servers'][$1]['controluser'] = '${PHPMYADMIN_CONFIG_DB_USER}';"
      append_to_file "\$cfg['Servers'][$1]['controlpass'] = '${PHPMYADMIN_CONFIG_DB_PASSWORD}';"
      append_to_file "\$cfg['Servers'][$1]['pmadb'] = '${PHPMYADMIN_CONFIG_DB_NAME}';"

      for table in $(complex-bash-env iterate "${PHPMYADMIN_CONFIG_DB_TABLES}")
      do
        local key=$(complex-bash-env getRowKey "${!table}")
        local value=$(complex-bash-env getRowValue "${!table}")
        append_to_file "\$cfg['Servers'][$1]['${key}'] = '${value}';"
      done
    }

    i=1
    for host in $(complex-bash-env iterate "${PHPMYADMIN_DB_HOSTS}")
    do

      isRow=$(complex-bash-env isRow "${!host}")

      if [ $isRow = true ]; then
        hostname=$(complex-bash-env getRowKey "${!host}")
        info=$(complex-bash-env getRowValue "${!host}")

        append_to_file "\$cfg['Servers'][$i]['host'] = '$hostname';"
        pma_storage_config $i
        host_info "\$cfg['Servers'][$i]" "$info"

      else
        append_to_file "\$cfg['Servers'][$i]['host'] = '${host}';"
        pma_storage_config $i
      fi

      ((i++))
    done

    sed -i --follow-symlinks "/{{ PHPMYADMIN_SERVERS }}/d" /var/www/phpmyadmin/config.inc.php

  fi

  touch $FIRST_START_DONE
fi

# Fix file permission
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;
chmod 400 /var/www/phpmyadmin/config.inc.php
chown www-data:www-data -R /var/www

exit 0
