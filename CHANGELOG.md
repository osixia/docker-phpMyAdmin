# Changelog

## 4.7.7
  - phpMyAdmin 4.7.7

## 4.7.6
  - phpMyAdmin 4.7.6

## 4.7.5
  - phpMyAdmin 4.7.5

## 4.7.4
  - phpMyAdmin 4.7.4

## 4.7.3-1
  - Optimise apache config
  - Add opcache config

## 4.7.3
  - phpMyAdmin 4.7.3

## 4.7.2
  - phpMyAdmin 4.7.2
  - Upgrade baseimage: web-baseimage:1.1.0 (debian stretch, php7)
  - add config.inc.php in config folder

## 4.7.0
  - phpMyAdmin 4.7.0

## 4.6.6-1
  - Upgrade baseimage: web-baseimage:1.0.0

## 4.6.6
  - phpMyAdmin 4.6.6

## 4.6.5.2
  - fix config issue with files in a volume
  - phpMyAdmin 4.6.5.2

## 4.6.5.1
  - phpMyAdmin 4.6.5.1

## 4.6.5
  - Upgrade baseimage: web-baseimage:0.1.12
  - phpMyAdmin 4.6.5
  - We now use the phpMyAdmin version number as docker image tag

## 0.3.7
  - Upgrade baseimage: web-baseimage:0.1.11
  - phpMyAdmin 4.6.4

## 0.3.6
  - Upgrade baseimage: web-baseimage:0.1.10
  - Add PHPMYADMIN_SERVER_PATH environment variable
  - phpMyAdmin 4.6.3

## 0.3.5
  - Upgrade baseimage: web-baseimage:0.1.9
  - phpMyAdmin 4.5.4.1

## 0.3.4
  - Upgrade baseimage: web-baseimage:0.1.7
  - Makefile with build no cache

## 0.3.3
  - phpMyAdmin 4.5.2

## 0.3.2
  - Upgrade baseimage: web-baseimage:0.1.6

## 0.3.1
  - Upgrade baseimage: web-baseimage:0.1.5
  - Add env variable PHPMYADMIN_CONFIG_ABSOLUTE_URI
  - More simple config.inc.php file
  - Remove listen on http when https is enable

## 0.3.0
  - Upgrade baseimage: web-baseimage:0.1.3
  - Easy mariadb ssl support

## 0.2.2
  - Fix bootstrap config
  - Allow single PHPMYADMIN_DB_HOSTS simply by -e PHPMYADMIN_DB_HOSTS=host instead of -e PHPMYADMIN_DB_HOSTS=['host']

## 0.2.1
  - New SSL certs directory
  - Bootstrap capabilities

## 0.2.0
  - New version initial release
