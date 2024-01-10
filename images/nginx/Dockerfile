FROM nginx:latest

WORKDIR /var/www/html

RUN mkdir -p /var/www/html/adminer
RUN apt-get update
RUN apt-get install curl telnet nano -y

EXPOSE 80

WORKDIR /var/www/html