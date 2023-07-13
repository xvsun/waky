FROM serversideup/php:8.2-fpm-nginx

ARG NODE_VERSION=18

# Needed when building npm dependencies or else the app won't launch
# To change later modify the env file and run `npm run build`
ARG VITE_PUSHER_APP_KEY
ARG VITE_PUSHER_HOST
ARG VITE_PUSHER_PORT
ARG VITE_PUSHER_SCHEME
ARG VITE_PUSHER_APP_CLUSTER

ENV VITE_PUSHER_APP_KEY=$VITE_PUSHER_APP_KEY
ENV VITE_PUSHER_HOST=$VITE_PUSHER_HOST
ENV VITE_PUSHER_PORT=$VITE_PUSHER_PORT
ENV VITE_PUSHER_SCHEME=$VITE_PUSHER_SCHEME
ENV VITE_PUSHER_APP_CLUSTER=$VITE_PUSHER_APP_CLUSTER

# Add /config to allowed directory tree
ENV PHP_OPEN_BASEDIR=$WEBUSER_HOME:/config/:/dev/stdout:/tmp

# Enable mixed ssl mode so port 80 or 443 can be used
ENV SSL_MODE="mixed"

# Install additional packages and cron file
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        cron \
        htop \
# Install cron file
    && echo "MAILTO=\"\"\n* * * * * webuser /usr/bin/php /var/www/html/artisan schedule:run" > /etc/cron.d/laravel \
# Install node & npm
    && curl -sLS https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \ 
    && npm install -g npm \
# Clean up package lists
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Copy package configs
COPY --chmod=755 docker/deploy/etc/s6-overlay/ /etc/s6-overlay/

WORKDIR /var/www/html

# Copy app
COPY --chown=webuser:webgroup . /var/www/html/

# Install composer dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev --no-cache \
    && mkdir -p storage/logs \
    && php artisan optimize:clear \
    && chown -R webuser:webgroup /var/www/html

# Install npm dependencies
RUN npm ci \
    && npm run build

VOLUME /config