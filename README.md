# Docker Setup for Magento 2

## Requirements

- Docker - [Install Docker](https://docs.docker.com/engine/installation/)
- Docker Compose - [Install Docker Compose](https://docs.docker.com/compose/install/)
- Run Docker as Non Root User
    - [Run Docker as Non Root User](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

## Disable Services on Local Machine

```shell
# Stop and disable Apache 2
sudo systemctl stop apache2
sudo systemctl disable apache2

# Stop and disable Nginx
sudo systemctl stop nginx
sudo systemctl disable nginx

# Stop and disable MySQL
sudo systemctl stop mysql
sudo systemctl disable mysql

# Stop and disable ElasticSearch
sudo systemctl stop elasticsearch
sudo systemctl disable elasticsearch

# Stop and disable PHP-FPM (replace 7.4 with your PHP version)
sudo systemctl stop php7.4-fpm
sudo systemctl disable php7.4-fpm

```

## Containers Configurations

- MySQL 8.0
    - Container Name - `mysql_80`
    - Username - `root`
    - Password - `magento`
    - For other container
        - Host - `mysql_80`
        - Port - `3306`
    - For local machine
        - Host - `127.0.0.1`
        - Port - `49200`
- ElasticSearch 7.17.7
    - Container name - `elasticsearch_717`
    - For other container
        - Host - `elasticsearch_717`
        - Port - `9200` and `9300`
    - For local machine
        - Host - `127.0.0.1`
        - Port - `49200` and `49300`
- OpenSearch 2.5.0
    - Container name - `opensearch_250`
    - For other container
        - Host - `opensearch_250`
        - Port - `9200` and `9300`
    - For local machine
        - Host - `127.0.0.1`
        - Port - `49201` and `49301`
- PHP 7.4
    - Container name - `php_74`
    - For other container
        - Host - `php_74`
        - Port - `9000`
    - For local machine
        - Host - `127.0.0.1`
        - Port - `49000`
- PHP 8.2
    - Container name - `php_82`
    - For other container
        - Host - `php_82`
        - Port - `9000`
    - For local machine
        - Host - `127.0.0.1`
        - Port - `49001`
- Nginx Latest Version
    - Container name - `nginx`
    - For other container
        - Host - `nginx`
        - Port - `80`
    - For local machine
        - Host - `127.0.0.1`
        - Port - `80`

## Folder Structure

- `docker-compose.yml`
  - This file contains all the container configuration including port and volume mapping
- `volume/`
  - This directory has volumes for containers like MySQL, ElasticSearch, OpenSearch, PHP and Nginx
- `code/`
  - This directory has code to mount in PHP and Nginx container. This directory will contain Magento 2 codebase.
    - `code/adminer/` - directory to Adminer files
    - `code/misc/` - directory to miscellaneous files. For example, put database dump in this directory and later it will be accessible in PHP container at `/var/www/html/misc/`
- `config/`
  - This directory has Nginx configuration file for virtual host and Magento 2 Nginx related stuff.
- `images/`
  - This directory has Docker images
- `backups/`
  - This directory will hold database backups

## Installation

### Setup Docker

1. Follow links given above to install `docker` and `docker-compose`.
2. Run `docker-compose up -d` to start all containers.

### Setup Adminer

1. Make sure `code/adminer/index.php` file exist.
2. Add `127.0.0.1 adminer.local` in `/etc/hosts` file.
3. Try accessing `http://adminer.local` in browser.

### Setup Magento 2

#### Setup Codebase

1. Create new directory under `code/` directory.
2. Copy Magento 2 codebase to the directory created in step 1.
3. Add below code in `config/nginx-virtual-hosts.conf` file. Make sure to replace `server_name`, `$FASTCGI_PASS`
   and `$MAGE_ROOT` variables.

```nginx
server {
    listen 80;

    ### Change `magento-docker.local` to your domain name
    ### Use `php_82` for PHP 8.2 and PHP_74 for PHP 7.4
    ### Change `magento-docker` to your Magento 2 codebase directory
    server_name magento-docker.local;
    set $FASTCGI_PASS php_82:9000;
    set $MAGE_ROOT /var/www/html/magento-docker;

    set $MAGE_MODE developer;

    access_log /var/log/nginx/magento-access.log;
    error_log /var/log/nginx/magento-error.log;

    include /tmp/nginx.conf;
}
```

4. Add `127.0.0.1 magento-docker.local` in `/etc/hosts` file. Replace domain name with your domain.
5. Run `bin/restart.sh nginx` to restart Nginx container.
6. Update app/etc/env.php with DB config
    1. Update `host` with `mysql_80:3306`
    2. Update `dbname` with your DB name
    3. Update `username` with `root`
    4. Update `password` with `magento`

### Setup Database

1. Create new directory if not exist - `code/misc/`.
2. Copy database dump to `code/misc/`
3. Connect to PHP container with command - `./bin/shell.sh php_74`
4. Run below command to create database. Replace `magento_latest` with your database name.
   ```
   mysql -h mysql_80 -u root -p -e "CREATE DATABASE magento_latest;"
   ```
5. Run below command to import database dump. Replace `magento_latest` with your database name and `magento_latest.sql` with your
   database dump file name
    ```
    mysql -h mysql_80 -u root -p magento_latest < /var/www/html/misc/magento_latest.sql
    ```
6. Update ElasticSearch / OpenSearch config
   ```
    UPDATE `core_config_data` SET `value` = 'elasticsearch_717' WHERE `path` = 'catalog/search/elasticsearch7_server_hostname'; # for ElasticSearch
    UPDATE `core_config_data` SET `value` = 'opensearch_250' WHERE `path` = 'catalog/search/elasticsearch7_server_hostname'; # for OpenSearch
    UPDATE `core_config_data` SET `value` = '9200' WHERE `path` = 'catalog/search/elasticsearch7_server_port';
    ```

## Useful Commands

### Docker

- Stop all docker containers - `docker stop $(docker ps -a -q)`
- Remove all docker containers - `docker rm $(docker ps -a -q)`

### ElasticSearch

- Run this command to check ElasticSearch status - `curl 127.0.0.1:49200`.
- Run this command to check OpenSearch status - `curl 127.0.0.1:49201`.

## General Troubleshooting

- If any container is not working, then try stop that container first and start again without `-d` flag. This will show
  exact reason for failure.
- If getting
  error `ElasticsearchException[failed to bind service]; nested: AccessDeniedException[/usr/share/elasticsearch/data/nodes]`
  , then try to give write permission to `volumes/` directory - `sudo chmod -R 777 volumes/`