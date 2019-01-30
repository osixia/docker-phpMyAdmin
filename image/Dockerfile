FROM osixia/web-baseimage:1.1.1

# phpMyAdmin version
ARG PHPMYADMIN_VERSION=4.8.5
ARG PHPMYADMIN_SHA256=ed55089538b7a652dd571e3d4336e0e8769990f06f14fca9d6a55965f4a27d43

# MariaDB version
ARG MARIADB_MAJOR=10.3

# Install apache2 and php7.0-fpm using osixia/baseimage utils
# Caution: /container/tool/install-service-available arguments order is important
# php7.0-fpm install will detect apache2 and configure it

# Add MariaDB repository
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8 \
    && echo "deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/$MARIADB_MAJOR/debian stretch main" > /etc/apt/sources.list.d/mariadb.list \
    && { \
    echo 'Package: *'; \
    echo 'Pin: release o=MariaDB'; \
    echo 'Pin-Priority: 999'; \
    } > /etc/apt/preferences.d/mariadb

# Download, check integrity and unzip phpMyAdmin to /var/www/phpmyadmin_bootstrap
RUN apt-get update \
    && /container/tool/add-multiple-process-stack \
    && /container/tool/add-service-available :apache2 :php7.0-fpm :ssl-tools \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    mariadb-client-$MARIADB_MAJOR \
    php7.0-gd \
    php7.0-json \
    php7.0-mcrypt \
    php7.0-mysql \
    php-gettext \
    && curl -o phpmyadmin.tar.gz -SL https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz \
    && echo "$PHPMYADMIN_SHA256 *phpmyadmin.tar.gz" | sha256sum -c - \
    && mkdir -p /var/www/phpmyadmin_bootstrap /var/www/phpmyadmin \
    && tar -xzf phpmyadmin.tar.gz --strip 1 -C /var/www/phpmyadmin_bootstrap \
    && apt-get remove -y --purge --auto-remove ca-certificates curl \
    && rm phpmyadmin.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

# Add default env variables
ADD environment /container/environment/99-default

# Set wordpress data directory in a data volume
VOLUME ["/var/www/phpmyadmin"]

# Expose http and https default ports
EXPOSE 80 443
