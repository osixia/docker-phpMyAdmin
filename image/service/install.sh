#!/bin/bash -e
# this script is run during the image build

# Add phpMyAdmin virtualhosts
ln -s /osixia/phpmyadmin/apache2/phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf
ln -s /osixia/phpmyadmin/apache2/phpmyadmin-ssl.conf /etc/apache2/sites-available/phpmyadmin-ssl.conf
ln -s /osixia/phpmyadmin/config.inc.php /var/www/phpmyadmin/config.inc.php

# Remove apache default host
a2dissite 000-default

# Correct issue
# https://bugs.launchpad.net/ubuntu/+source/php-mcrypt/+bug/1240590
ln -s ../conf.d/mcrypt.so /etc/php5/mods-available/mcrypt.so
php5enmod mcrypt

# Delete unnecessary files
rm -rf /var/www/phpmyadmin/doc \
	   /var/www/phpmyadmin/examples \
	   /var/www/phpmyadmin/scripts \
	   /var/www/phpmyadmin/setup