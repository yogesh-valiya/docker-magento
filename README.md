# Docker Setup Guide for Magento 2

## Prerequisites

Make sure you have the following installed on your system:

- [Docker](https://docs.docker.com/engine/installation/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Configure Docker to run as a non-root user, following [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).

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
- `code/`: Magento 2 codebase and related files.
    - `code/adminer/`: Adminer files.
    - `code/misc/`: Miscellaneous files, e.g., database dumps.
- `config/`: Nginx configuration and Magento 2-related files.
- `images/`: Docker images.
- `backups/`: Database backup directory.

## Installation

### Set Up Docker

1. Install [docker](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install/).
2. Run `docker-compose up -d` to start all containers.

### Set Up Adminer

1. Ensure `code/adminer/index.php` exists.
2. Add `127.0.0.1 adminer.local` to `/etc/hosts`.
3. Access [http://adminer.local](http://adminer.local) in your browser.

### Set Up Magento 2

#### Set Up Codebase

1. Create a new directory under `code/`.
2. Copy Magento 2 codebase to the new directory.
3. Add the following code to `config/nginx-virtual-hosts.conf`. Replace variables as needed.

```nginx
server {
    listen 80;
    server_name magento-docker.local; # replace with your domain
    set $FASTCGI_PASS php_82:9000; # replace with php_74 for PHP 7.4
    set $MAGE_ROOT /var/www/html/magento-docker; # replace with your Magento 2 root directory
    set $MAGE_MODE developer;

    access_log /var/log/nginx/magento-access.log;
    error_log /var/log/nginx/magento-error.log;

    include /tmp/nginx.conf;
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
To run Magento 2 commands, connect to the PHP container with `./bin/shell.sh php_74` or `./bin/shell.sh php_82` and run the commands as usual.

## Useful Commands

### Docker

- Stop all docker containers: `docker stop $(docker ps -a -q)`
- Remove all docker containers: `docker rm $(docker ps -a -q)`

### ElasticSearch

- Check ElasticSearch status: `curl 127.0.0.1:49200`
- Check OpenSearch status: `curl 127.0.0.1:49201`

## Troubleshooting

- If any container fails, stop it first and start again without the `-d` flag for detailed error messages.
- For the `ElasticsearchException` error, grant write permission to the `volumes/` directory: `sudo chmod -R 777 volumes/`
#### Getting port not available error
If getting errror similar to below, then it means that the port is already in use. To fix this, you can either stop the service using that port or change the port in `docker-compose.yml` file.
```bash
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:80 -> 0.0.0.0:0: listen tcp 0.0.0.0:80: bind: address already in use
```