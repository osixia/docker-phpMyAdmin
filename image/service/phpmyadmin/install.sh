#!/bin/bash -e
# this script is run during the image build

# add phpMyAdmin virtualhosts
ln -sf /container/service/phpmyadmin/assets/apache2/phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf
ln -sf /container/service/phpmyadmin/assets/apache2/phpmyadmin-ssl.conf /etc/apache2/sites-available/phpmyadmin-ssl.conf

cat /container/service/phpmyadmin/assets/php7.0-fpm/pool.conf >> /etc/php/7.0/fpm/pool.d/www.conf
rm /container/service/phpmyadmin/assets/php7.0-fpm/pool.conf

cp -f /container/service/phpmyadmin/assets/php7.0-fpm/opcache.ini /etc/php/7.0/fpm/conf.d/opcache.ini
rm /container/service/phpmyadmin/assets/php7.0-fpm/opcache.ini

mkdir -p /var/www/tmp
chown www-data:www-data /var/www/tmp

# remove apache default host
a2dissite 000-default
rm -rf /var/www/html

# Add apache modules
a2enmod deflate expires

phpenmod mcrypt

# delete unnecessary files
rm -rf /var/www/phpmyadmin_bootstrap/doc \
	   /var/www/phpmyadmin_bootstrap/examples \
	   /var/www/phpmyadmin_bootstrap/setup
