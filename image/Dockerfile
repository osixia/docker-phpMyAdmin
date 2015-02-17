FROM osixia/baseimage:0.10.2
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# phpMyAdmin version
ENV PHPMYADMIN_VERSION 4.3.9
ENV PHPMYADMIN_SHA1 423734dc0d804ea79dd388a163797e07e54b93a8

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


# Install apache2 and php5-fpm using osixia/baseimage utils
# Caution: /sbin/enable-service arguments order is important
# php5-fpm install will detect apache2 and configure it

# Download, check integrity and unzip phpMyAdmin to /var/www/phpmyadmin
RUN apt-get update && /sbin/enable-service apache2 php5-fpm \
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mysql-client php-gettext php5-json php5-mcrypt php5-mysql php5-gd
	&& curl -o phpmyadmin.tar.gz -SL http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz \
	&& echo "$PHPMYADMIN_SHA1 *phpmyadmin.tar.gz" | sha1sum -c - \
	&& mkdir -p /var/www/phpmyadmin \
	&& tar -xzf phpmyadmin.tar.gz --strip 1 -C /var/www/phpmyadmin

# Add install script and phpMyAdmin assets
ADD service/install.sh /tmp/install.sh
ADD service/phpmyadmin/assets /osixia/phpmyadmin

# Run install script and clean all
RUN ./tmp/install.sh && rm /tmp/install.sh \
	&& rm phpmyadmin.tar.gz \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yml /etc/env.yml

# Add phpMyAdmin container start config
ADD service/phpmyadmin/container-start.sh /etc/my_init.d/phpmyadmin

# Expose http and https default ports
EXPOSE 80 443