# Docker Setup Guide for Magento 2

## Prerequisites

Make sure you have the following installed on your system:

- [Docker](https://docs.docker.com/engine/installation/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Configure Docker to run as a non-root user,
  following [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
  .

## Disable Local Services

To prevent conflicts, stop and disable the following services on your local machine:

```shell
sudo systemctl stop apache2
sudo systemctl disable apache2

sudo systemctl stop nginx
sudo systemctl disable nginx

sudo systemctl stop mysql
sudo systemctl disable mysql

sudo systemctl stop elasticsearch
sudo systemctl disable elasticsearch

sudo systemctl stop php7.4-fpm
sudo systemctl disable php7.4-fpm
```

## Folder Structure

- `docker-compose.yml`: Container configurations, including port and volume mapping.
- `volume/`: Volumes for containers (MySQL, ElasticSearch, OpenSearch, PHP, and Nginx).
- `code/adminer/`: Adminer files.
- `config/`: Nginx configuration and Magento 2-related files.
- `images/`: Docker images.
- `backups/`: Database backup directory.

## Installation

### Set Up Docker

1. Install [docker](https://docs.docker.com/engine/installation/)
   and [docker-compose](https://docs.docker.com/compose/install/).
2. Configure Docker to run as a non-root user,
   following [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
   .
3. Update `DOCUMENT_ROOT` value in `.env` file with absolute path of the codebase parent directory.
    1. Later on all the codebase will be inside this directory.
    2. This directory will be accessible inside the container at `/var/www/html/`.
4. Run `docker-compose up -d` to start all containers.

### Set Up Adminer

1. Ensure `code/adminer/index.php` exists.
2. Add `127.0.0.1 adminer.local` to `/etc/hosts`.
3. Access [http://adminer.local](http://adminer.local) in your browser.

### Set Up Magento 2

#### Set Up Codebase

1. Create a new directory under `DOCUMENT_ROOT` path mentioned in `.env` file.
2. Copy Magento 2 codebase to the new directory.
3. Add the following code to `config/nginx-virtual-hosts.conf`. Replace variables as needed.
   1. Replace `magento-docker.local` with your domain.
   2. Use `php_74:9000` for PHP 7.4 and `php_82:9000` for PHP 8.2.
   3. Replace `/var/www/html/magento-docker` with your `/var/www/html/<your_directory>`.

    ```nginx
    server {
        listen 80;
        server_name magento-docker.local;
        set $FASTCGI_PASS php_82:9000;
        set $MAGE_ROOT /var/www/html/magento-docker;
        set $MAGE_MODE developer;
    
        access_log /var/log/nginx/magento-access.log;
        error_log /var/log/nginx/magento-error.log;
    
        include /etc/nginx/magento-host.conf;
    }
    ```

4. Add `127.0.0.1 magento-docker.local` to `/etc/hosts` (replace domain with your domain).
5. Run `bin/restart.sh nginx` to restart the Nginx container.
6. Update `app/etc/env.php` with database configuration.

### Set Up Database

1. Create `code/misc/` directory if not exists.
2. Copy the database dump to `code/misc/`.
3. Connect to the PHP container with `./bin/shell.sh php_74`.
4. Create the database:

```bash
mysql -h mysql_80 -u root -p -e "CREATE DATABASE magento_db;"
```

5. Import the database dump:

```bash
mysql -h mysql_80 -u root -p magento_db < /var/www/html/misc/magento_db.sql
```

6. Update ElasticSearch / OpenSearch configuration:

```bash
UPDATE `core_config_data` SET `value` = 'elasticsearch_717' WHERE `path` = 'catalog/search/elasticsearch7_server_hostname'; # for ElasticSearch
UPDATE `core_config_data` SET `value` = 'opensearch_250' WHERE `path` = 'catalog/search/elasticsearch7_server_hostname'; # for OpenSearch
UPDATE `core_config_data` SET `value` = '9200' WHERE `path` = 'catalog/search/elasticsearch7_server_port';
```

## Usages

#### How to run Magento commands?

To run Magento 2 commands, connect to the PHP container with `./bin/shell.sh php_74` or `./bin/shell.sh php_82` and run
the commands as usual.

## Useful Commands

### Docker

- Stop all docker containers: `docker stop $(docker ps -a -q)`
- Remove all docker containers: `docker rm $(docker ps -a -q)`

### ElasticSearch

- Check ElasticSearch status: `curl 127.0.0.1:49200`
- Check OpenSearch status: `curl 127.0.0.1:49201`

## Troubleshooting

##### A container is not working?
- Check container status with `./bin/status.sh`.
- If it's not running, start it with `docker-compose up <container_name>`. This will show detailed exectuion of container including error message if any.

#### Getting port not available error
If getting errror similar to below, then it means that the port is already in use. To fix this, you can either stop the
service using that port or change the port in `docker-compose.yml` file.

```bash
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:80 -> 0.0.0.0:0: listen tcp 0.0.0.0:80: bind: address already in use
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