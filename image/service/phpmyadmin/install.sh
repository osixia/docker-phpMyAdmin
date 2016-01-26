#!/bin/bash -e
# this script is run during the image build

# add phpMyAdmin virtualhosts
ln -sf /container/service/phpmyadmin/assets/apache2/phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf
ln -sf /container/service/phpmyadmin/assets/apache2/phpmyadmin-ssl.conf /etc/apache2/sites-available/phpmyadmin-ssl.conf

cat /container/service/phpmyadmin/assets/php5-fpm/pool.conf >> /etc/php5/fpm/pool.d/www.conf
rm /container/service/phpmyadmin/assets/php5-fpm/pool.conf

mkdir -p /var/www/tmp
chown www-data:www-data /var/www/tmp

# remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# correct issue
# https://bugs.launchpad.net/ubuntu/+source/php-mcrypt/+bug/1240590
ln -sf ../conf.d/mcrypt.so /etc/php5/mods-available/mcrypt.so
php5enmod mcrypt

# delete unnecessary files
rm -rf /var/www/phpmyadmin_bootstrap/doc \
	   /var/www/phpmyadmin_bootstrap/examples \
	   /var/www/phpmyadmin_bootstrap/setup
