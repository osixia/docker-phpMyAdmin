#!/bin/bash -e

FIRST_START_DONE="/etc/docker-mariadb-client-first-start-done"

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
    for info in $(complex-bash-env iterate "$2")
    do

      local isRow=$(complex-bash-env isRow "${!info}")

      if [ $isRow = true ]; then
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
      cfssl-helper mariadb "$ssl_cert" "$ssl_key" "$ssl_ca"
    fi

  }

  # iterate all hosts
  for host in $(complex-bash-env iterate "${PHPMYADMIN_DB_HOSTS}")
  do
    isRow=$(complex-bash-env isRow "${!host}")
    if [ $isRow = true ]; then
      info=$(complex-bash-env getRowValue "${!host}")
      host_info "$info"
    fi
  done

  touch $FIRST_START_DONE
fi

exit 0
