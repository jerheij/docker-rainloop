#!/bin/sh

# Set attachment size limit
sed -i "s/<UPLOAD_MAX_SIZE>/$UPLOAD_MAX_SIZE/g" /etc/php.ini
sed -i "s/<UPLOAD_MAX_SIZE>/$UPLOAD_MAX_SIZE/g" /etc/nginx/sites-enabled/rainloop.conf
sed -i "s/<SERVER_NAME>/$SERVER_NAME/g" /etc/nginx/sites-enabled/rainloop.conf
sed -i "s/<MEMORY_LIMIT>/$MEMORY_LIMIT/g" /etc/php.ini

# Copy php.ini
cat /etc/php.ini > /etc/php/7.4/fpm/php.ini

# Add folders
mkdir -p /rainloop/data/_data_/_default_/plugins/
mkdir -p /var/log/rainloop

# Fix permissions
usermod -u $UID www-data
groupmod -g $GID www-data
chown -R $UID:$GID /rainloop /var/log/rainloop
chmod -R 750 /rainloop

# Remove Nginx default site
sed -i "s%80%89%g" /etc/nginx/sites-available/default

# Remove /var/www/html
rm -vrf /var/www/html

exec "$@"
