#!/bin/bash -e
# this script is run during the image build

rm -rf /var/www/phpmyadmin/doc \
	   /var/www/phpmyadmin/examples \
	   /var/www/phpmyadmin/scripts \
	   /var/www/phpmyadmin/setup

# Correct issue
# https://bugs.launchpad.net/ubuntu/+source/php-mcrypt/+bug/1240590
ln -s ../conf.d/mcrypt.so /etc/php5/mods-available/mcrypt.so
php5enmod mcrypt

# nginx config (tools from osixia/baseimage)
/sbin/nginx-add-vhost localhost /usr/share/phpmyadmin --php --ssl --ssl-crt=/etc/nginx/ssl/$PHPMYADMIN_SSL_CRT_FILENAME --ssl-key=/etc/nginx/ssl/$PHPMYADMIN_SSL_KEY_FILENAME
/sbin/nginx-remove-vhost default

# php options
PHP_CONFIG=`cat /etc/phpmyadmin/phpmyadmin.nginx.php.config`
/sbin/nginx-vhost-add-php-config localhost "$PHP_CONFIG"

# nginx custom config
NGINX_CONFIG=`cat /etc/phpmyadmin/phpmyadmin.nginx.config`
/sbin/nginx-vhost-add-config localhost "$NGINX_CONFIG"

## Fix some security stuff
## https://wiki.phpmyadmin.net/pma/Security

# Remove setup directory
rm -rf /usr/share/phpmyadmin/setup

# Change php directories owner
chown -R www-data:www-data /usr/share/phpmyadmin/
chown -R www-data:www-data /etc/phpmyadmin/

# Change config file chmod
chmod 660 /etc/phpmyadmin/config.inc.php
chmod 660 /etc/phpmyadmin/config-db.php 