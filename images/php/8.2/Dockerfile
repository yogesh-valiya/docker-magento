FROM php:8.2-fpm

WORKDIR /var/www/html

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get update
RUN apt-get install -y cron default-mysql-client git gnupg gzip libbz2-dev libfreetype6-dev libicu-dev
RUN apt-get install -y nano libjpeg62-turbo-dev libmagickwand-dev libmcrypt-dev libonig-dev libpng-dev
RUN apt-get install -y libpng-dev libsodium-dev libssh2-1-dev libwebp-dev libxslt1-dev libzip-dev lsof
RUN apt-get install -y mailutils msmtp nodejs procps vim zip
RUN apt-get install -y net-tools wget nano

RUN pecl channel-update pecl.php.net && pecl install imagick redis ssh2-1.3.1 xdebug

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install bcmath bz2 calendar exif gd gettext intl mbstring mysqli opcache pcntl
RUN docker-php-ext-install pdo_mysql soap sockets sodium sysvmsg sysvsem sysvshm xsl zip
RUN docker-php-ext-enable imagick redis ssh2 xdebug

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY conf/php.ini $PHP_INI_DIR
COPY conf/php-fpm.conf /usr/local/etc/
COPY conf/www.conf /usr/local/etc/php-fpm.d/

RUN mkdir -p /adminer
RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql-en.php -O /adminer/index.php

RUN mkdir -p /app

EXPOSE 9000
