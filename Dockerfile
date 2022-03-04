FROM  php:7.4.28-apache 

# 1. development packages
RUN apt-get update && apt-get install -y \
    git \
    zip \
    curl \
    sudo \
    unzip \
    libicu-dev \
    libbz2-dev \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    libmcrypt-dev \
    libreadline-dev \
    libfreetype6-dev \
    libonig-dev \
    g++

RUN pecl install xdebug-3.1.2
ADD ./html/docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

COPY ./html /var/www/html

# 2. apache configs + document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

# 3. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers

# 4. start with base php config, then add extensions
#RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"


RUN docker-php-ext-install \
    bz2 \
    intl \
    iconv \
    bcmath \
    opcache \
    calendar \
    mbstring \
    pdo_mysql \
    zip
# 5. composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

#ARG UID
#RUN useradd -G www-data,root -u $UID -d /home/devuser devuser
#RUN mkdir -p /home/devuser/.composer && \
#    chown -R devuser:devuser /home/devuser
# if we want to install via apt (sudo...)
#USER root
#instalL composer 
#RUN apt-get update
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
# remove installer
#RUN php -r "unlink('composer-setup.php');"


# drop back to the regular jenkins user - good practice
#RUN useradd -G www-data,root -u $uid -d /home/$user $user
#RUN mkdir -p /home/$user/.composer && \
#chown -R $user:$user /home/$user

#WORKDIR /var/www/html

