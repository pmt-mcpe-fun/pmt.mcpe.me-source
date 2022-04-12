FROM php:7.1-apache

WORKDIR /var/www/html

COPY . .

# move token to /var/www
RUN mv token.txt ../token.txt
# move cid to /var/www
RUN mv cid.txt ../cid.txt
# move secret to /var/www
RUN mv secret.txt ../secret.txt

# custom php.ini
RUN mv "php.ini" "$PHP_INI_DIR/php.ini"

# make plugin dirs
RUN mkdir -p ../tmp
RUN mkdir -p data/phars

# set perms for plugin dirs
RUN chmod -R 777 /var/www
RUN chown -R root:www-data /var/www

# install php extensions
RUN apt update
RUN apt install -y libzip-dev libyaml-dev
RUN pecl install zip
RUN pecl install yaml
RUN docker-php-ext-enable zip yaml

# enable mod_rewrite apache
RUN a2enmod rewrite

# remove cron from dir
COPY remove-data /etc/cron.d/remove-data
RUN rm -rf remove-data
RUN crontab /etc/cron.d/remove-data
*/10 * * * * rm -rf /var/www/html/data/tmp/{*,.*} && rm -rf /var/www/html/data/phars/{*,.*}
EXPOSE 80