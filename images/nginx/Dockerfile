FROM nginx:latest

WORKDIR /var/www/html

RUN mkdir -p /var/www/html/adminer
RUN apt-get update
RUN apt-get install curl telnet nano -y

COPY ./config/nginx-virtual-hosts.conf /etc/nginx/conf.d/default.conf
COPY ./config/magento-host.conf /etc/nginx/magento-host.conf

EXPOSE 80

WORKDIR /var/www/html