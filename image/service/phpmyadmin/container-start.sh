#!/bin/bash -e

FIRST_START_DONE="/etc/docker-phpmyadmin-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # create phpMyAdmin vhost
  if [ "$HTTPS" == "True" ]; then

    # check certificat and key or create it
    /sbin/ssl-kit "/osixia/phpmyadmin/apache2/$SSL_CRT_FILENAME" "/osixia/phpmyadmin/apache2/$SSL_KEY_FILENAME"

    # add CA certificat config if CA cert exists
    if [ -e "/osixia/phpmyadmin/apache2/$SSL_CA_CRT_FILENAME" ]; then
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

      # it's just a value
      else
        echo "$to_print['$key']=$value;" >> /osixia/phpmyadmin/config.inc.php
      fi

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
      host_infos "\$cfg['Servers'][$i]" ${infos[1]}

    # it's just a host name
    else
        echo "\$cfg['Servers'][$i]['host'] = '${!host}';" >> /osixia/phpmyadmin/config.inc.php
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