#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-mariadb-client-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  #
  # Search ssl config in hosts config and call cfssl-helper
  #
  function host_info() {

    local ssl_ca=""
    local ssl_cert=""
    local ssl_key=""

    # iterate all host config
    for info in $(complex-bash-env iterate "$1")
    do

      if [ $(complex-bash-env isRow "${!info}") = true ]; then
        local key=$(complex-bash-env getRowKey "${!info}")
        local value=$(complex-bash-env getRowValue "${!info}")

        if [ "$key" == "ssl_cert" ]; then
          local ssl_cert=$value
        elif [ "$key" == "ssl_key" ]; then
          local ssl_key=$value
        elif [ "$key" == "ssl_ca" ]; then
          local ssl_ca=$value
        fi
      fi
    done

    if [ -n "$ssl_cert" ] && [ -n "$ssl_key" ] && [ -n "$ssl_ca" ]; then
      cfssl-helper ${MARIADB_CLIENT_CFSSL_PREFIX} "$ssl_cert" "$ssl_key" "$ssl_ca"
      chown -R www-data:www-data $ssl_cert $ssl_key $ssl_ca
    fi

  }

  # iterate all hosts
  for host in $(complex-bash-env iterate PHPMYADMIN_DB_HOSTS)
  do
    if [ $(complex-bash-env isRow "${!host}") = true ]; then
      info=$(complex-bash-env getRowValueVarName "${!host}")
      host_info "$info"
    fi
  done

  touch $FIRST_START_DONE
fi

exit 0
