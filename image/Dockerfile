FROM osixia/web-baseimage:release-1.2.0-dev

# phpMyAdmin version
ARG PHPMYADMIN_VERSION=5.0.2
ARG PHPMYADMIN_SHA256=8d5cb67de154262b6e51e6ac6967d0931d28ef39cdc7fbec44011d374eb432ae

# Install apache2 and php7.3-fpm using osixia/baseimage utils
# Caution: /container/tool/install-service-available arguments order is important
# php7.3-fpm install will detect apache2 and configure it

# Download, check integrity and unzip phpMyAdmin to /var/www/phpmyadmin_bootstrap
RUN apt-get update \
    && /container/tool/add-multiple-process-stack \
    && /container/tool/add-service-available :apache2 :php7.3-fpm :ssl-tools \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    mariadb-client \
    php-apcu \
    php-gd \
    php-gettext \
    php-json \
    php-mbstring \
    php-mysql \
    php-xml \
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
