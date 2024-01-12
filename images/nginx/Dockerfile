FROM nginx:latest

RUN apt-get update
RUN apt-get install curl telnet nano wget -y

RUN mkdir -p /adminer
RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql-en.php -O /adminer/index.php

RUN mkdir -p /etc/nginx/magento/virtual-hosts /etc/nginx/magento/magento-config
RUN mkdir -p /app /etc/nginx/certs /adminer

COPY ./conf/certs/* /etc/nginx/certs
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/adminer-vhost.conf /etc/nginx/conf.d/adminer-vhost.conf
COPY ./conf/default-magento.conf /etc/nginx/default-magento.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]