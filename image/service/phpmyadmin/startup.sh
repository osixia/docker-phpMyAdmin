#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-phpmyadmin-first-start-done"

#
# HTTPS config
#
if [ "${PHPMYADMIN_HTTPS,,}" == "true" ]; then

  log-helper info "Set apache2 https config..."

  # generate a certificate and key if files don't exists
  # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/assets/tool/ssl-helper
  ssl-helper ${PHPMYADMIN_SSL_HELPER_PREFIX} "${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CA_CRT_FILENAME"

  # add CA certificat config if CA cert exists
  if [ -e "${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/apache2/certs/$PHPMYADMIN_HTTPS_CA_CRT_FILENAME" ]; then
    sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/apache2/https.conf
  fi

  ln -sf ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/apache2/https.conf /etc/apache2/sites-available/phpmyadmin.conf
#
# HTTP config
#
else
  log-helper info "Set apache2 http config..."
  ln -sf ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/apache2/http.conf /etc/apache2/sites-available/phpmyadmin.conf
fi

#
# Reverse proxy config
#
if [ "${PHPMYADMIN_TRUST_PROXY_SSL,,}" == "true" ]; then
  echo 'SetEnvIf X-Forwarded-Proto "^https$" HTTPS=on' > /etc/apache2/mods-enabled/remoteip_ssl.conf
fi

a2ensite phpmyadmin | log-helper debug

#
# phpMyAdmin directory is empty, we use the bootstrap
#
if [ ! "$(ls -A -I lost+found /var/www/phpmyadmin)" ]; then

  log-helper info "Bootstap phpMyAdmin..."

  cp -R /var/www/phpmyadmin_bootstrap/* /var/www/phpmyadmin
  rm -rf /var/www/phpmyadmin_bootstrap
  rm -f /var/www/phpmyadmin/config.inc.php
fi


# if there is no config
if [ ! -e "/var/www/phpmyadmin/config.inc.php" ]; then

  # on container first start customise the container config file
  if [ ! -e "$FIRST_START_DONE" ]; then

    # phpMyAdmin Absolute URI
    sed -i "s|{{ PHPMYADMIN_CONFIG_ABSOLUTE_URI }}|${PHPMYADMIN_CONFIG_ABSOLUTE_URI}|g" ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/config/config.inc.php

    get_salt () {
      salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:/{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
    }

    # phpMyAdmin cookie secret
    get_salt
    sed -i "s|{{ PHPMYADMIN_BLOWFISH_SECRET }}|${salt}|g" ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/config/config.inc.php

    append_to_file() {
      TO_APPEND=$1
      sed -i "s|{{ PHPMYADMIN_SERVERS }}|${TO_APPEND}\n{{ PHPMYADMIN_SERVERS }}|g" ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/config/config.inc.php
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
        if [ $(complex-bash-env isRow "${!info}") = true ]; then
          local key=$(complex-bash-env getRowKey "${!info}")
          local valueVarName=$(complex-bash-env getRowValueVarName "${!info}")

          if [ $(complex-bash-env isTable "${!valueVarName}") = true ] || [ $(complex-bash-env isRow "${!valueVarName}") = true ]; then
            host_info "$to_print['$key']" "$valueVarName"
          else
            append_value_to_file "$to_print['$key']" "${!valueVarName}"
          fi
        fi
      done
    }

    pma_storage_config (){
      append_to_file "\$cfg['Servers'][$1]['controlhost'] = '${PHPMYADMIN_CONFIG_DB_HOST}';"
      append_to_file "\$cfg['Servers'][$1]['controlport'] = '${PHPMYADMIN_CONFIG_DB_PORT}';"
      append_to_file "\$cfg['Servers'][$1]['controluser'] = '${PHPMYADMIN_CONFIG_DB_USER}';"
      append_to_file "\$cfg['Servers'][$1]['controlpass'] = '${PHPMYADMIN_CONFIG_DB_PASSWORD}';"
      append_to_file "\$cfg['Servers'][$1]['pmadb'] = '${PHPMYADMIN_CONFIG_DB_NAME}';"

      for table in $(complex-bash-env iterate PHPMYADMIN_CONFIG_DB_TABLES)
      do
        local key=$(complex-bash-env getRowKey "${!table}")
        local value=$(complex-bash-env getRowValue "${!table}")
        append_to_file "\$cfg['Servers'][$1]['${key}'] = '${value}';"
      done
    }

    i=1
    for host in $(complex-bash-env iterate PHPMYADMIN_DB_HOSTS)
    do
      if [ $(complex-bash-env isRow "${!host}") = true ]; then
        hostname=$(complex-bash-env getRowKey "${!host}")
        info=$(complex-bash-env getRowValueVarName "${!host}")

        append_to_file "\$cfg['Servers'][$i]['host'] = '$hostname';"
        pma_storage_config $i
        host_info "\$cfg['Servers'][$i]" "$info"
      else
        append_to_file "\$cfg['Servers'][$i]['host'] = '${!host}';"
        pma_storage_config $i
      fi

      ((i++))
    done

    sed -i "/{{ PHPMYADMIN_SERVERS }}/d" ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/config/config.inc.php

    touch $FIRST_START_DONE
  fi

  log-helper debug "copy ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/config/config.inc.php to/var/www/phpmyadmin/config.inc.php"
  cp -f ${CONTAINER_SERVICE_DIR}/phpmyadmin/assets/config/config.inc.php /var/www/phpmyadmin/config.inc.php

fi

# Fix file permission
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;
chown www-data:www-data -R /var/www

# symlinks special (chown -R don't follow symlinks)
chown www-data:www-data /var/www/phpmyadmin/config.inc.php
chmod 400 /var/www/phpmyadmin/config.inc.php

exit 0
