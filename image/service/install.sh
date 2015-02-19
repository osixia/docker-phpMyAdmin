#!/bin/bash -e
# this script is run during the image build

# Add phpMyAdmin virtualhosts
ln -s /osixia/phpmyadmin/apache2/phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf
ln -s /osixia/phpmyadmin/apache2/phpmyadmin-ssl.conf /etc/apache2/sites-available/phpmyadmin-ssl.conf
ln -s /osixia/phpmyadmin/config.inc.php /var/www/phpmyadmin/config.inc.php
ln -s /osixia/php5-fpm/phpmyadmin.conf /etc/php5/fpm/conf.d/phpmyadmin.conf

# Remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# Correct issue
# https://bugs.launchpad.net/ubuntu/+source/php-mcrypt/+bug/1240590
ln -s ../conf.d/mcrypt.so /etc/php5/mods-available/mcrypt.so
php5enmod mcrypt

# Delete unnecessary files
rm -rf /var/www/phpmyadmin/doc \
	   /var/www/phpmyadmin/examples \
	   /var/www/phpmyadmin/scripts \
	   /var/www/phpmyadmin/setup

mkdir -p /tmp/phpmyadmin
chown www-data:www-data /tmp/phpmyadmin

sed -i "s/disable_functions/;disable_functions/g" /etc/php5/fpm/php.ini