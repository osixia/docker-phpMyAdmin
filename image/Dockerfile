FROM osixia/web-baseimage:0.1.6
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# phpMyAdmin version
ENV PHPMYADMIN_VERSION 4.5.2
ENV PHPMYADMIN_SHA1 22a4180d87fa33917feb45782594438c4567e108

# MariaDB version
ENV MARIADB_MAJOR 10.1

# Use baseimage's init system.
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/run
CMD ["/container/tool/run"]

# Install apache2 and php5-fpm using osixia/baseimage utils
# Caution: /container/tool/install-service-available arguments order is important
# php5-fpm install will detect apache2 and configure it

# Add MariaDB repository
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db \
    && echo "deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/$MARIADB_MAJOR/debian jessie main" > /etc/apt/sources.list.d/mariadb.list \
    && { \
		     echo 'Package: *'; \
		     echo 'Pin: release o=MariaDB'; \
		     echo 'Pin-Priority: 999'; \
	     } > /etc/apt/preferences.d/mariadb

# Download, check integrity and unzip phpMyAdmin to /var/www/phpmyadmin_bootstrap
RUN apt-get update \
		&& /container/tool/install-multiple-process-stack \
		&& /container/tool/install-service-available apache2 php5-fpm ssl-helper-openssl \
		&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
			 mariadb-client \
			 php-gettext \
			 php5-json \
			 php5-mcrypt \
			 php5-mysql \
			 php5-gd \
			 curl \
		&& curl -o phpmyadmin.tar.gz -SL http://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz \
		&& echo "$PHPMYADMIN_SHA1 *phpmyadmin.tar.gz" | sha1sum -c - \
		&& mkdir -p /var/www/phpmyadmin_bootstrap /var/www/phpmyadmin \
		&& tar -xzf phpmyadmin.tar.gz --strip 1 -C /var/www/phpmyadmin_bootstrap \
		&& apt-get remove -y --purge --auto-remove curl

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script and clean all
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service \
		&& rm phpmyadmin.tar.gz \
		&& apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /container/environment/env.yaml

# Set wordpress data directory in a data volume
VOLUME ["/var/www/phpmyadmin"]

# Expose http and https default ports
EXPOSE 80 443
