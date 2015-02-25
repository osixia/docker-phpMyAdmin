#!/bin/bash -e
# this script is run during the image build

# Add phpMyAdmin virtualhosts
ln -s /osixia/phpmyadmin/apache2/phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf
ln -s /osixia/phpmyadmin/apache2/phpmyadmin-ssl.conf /etc/apache2/sites-available/phpmyadmin-ssl.conf
ln -s /osixia/phpmyadmin/config.inc.php /var/www/phpmyadmin/config.inc.php

cat /osixia/phpmyadmin/php5-fpm/pool.conf >> /etc/php5/fpm/pool.d/www.conf

mkdir -p /var/www/tmp
chown www-data:www-data /var/www/tmp

# Remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# Correct issue
# https://bugs.launchpad.net/ubuntu/+source/php-mcrypt/+bug/1240590
ln -s ../conf.d/mcrypt.so /etc/php5/mods-available/mcrypt.so
php5enmod mcrypt

# Delete unnecessary files
rm -rf /var/www/phpmyadmin/doc \
	   /var/www/phpmyadmin/scripts \
	   /var/www/phpmyadmin/setup
