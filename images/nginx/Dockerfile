FROM nginx:latest

WORKDIR /var/www/html

RUN apt-get update
RUN apt-get install curl telnet nano -y

RUN mkdir -p /adminer
RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql-en.php -O /adminer/index.php

RUN mkdir -p /etc/nginx/magento/virtual-hosts
RUN mkdir -p /etc/nginx/magento/magento-config
RUN mkdir -p /app

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/adminer-vhost.conf /etc/nginx/conf.d/adminer-vhost.conf
COPY ./conf/default-magento.conf /etc/nginx/default-magento.conf

EXPOSE 80

WORKDIR /var/www/html