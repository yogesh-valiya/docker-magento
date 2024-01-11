# Docker Setup Guide for Magento 2

## Prerequisites

### Install Docker
Make sure you have the following installed on your system:

- Install [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- Install [Docker Compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository)
- Configure Docker to run as a non-root user,
  following [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).

### Disable Local Services

To prevent conflicts, stop and disable the following services on your local machine:

```shell
sudo systemctl stop apache2 nginx mysql elasticsearch php7.4-fpm php8.0-fpm php8.2-fpm
sudo systemctl disable apache2 nginx mysql elasticsearch php7.4-fpm php8.0-fpm php8.2-fpm
```

## Folder Structure

- `.env` - Has a flag `DOCUMENT_ROOT` path, which holds the path of the magento instances.
- `backups/`: Database backup directory.
- `code/adminer/`: Has adminer files.
- `images/`: Docker images.
- `bin/`: Has utility commands to mana .
- `docker-compose.yml`: Container configurations, including port and volume mapping.

## Installation

### Set Up Docker

1. Install Docker as described [here](#install-docker).
2. Update `DOCUMENT_ROOT` value in `.env` file with absolute path of the codebase parent directory.
    1. Later on all the codebase will be inside this directory.
    2. This directory will be accessible inside the container at `/var/www/html/`.
3. Run `./bin/build.sh` to build all containers.
4. Run `./bin/start.sh` to start all containers.

### Set Up Adminer

1. Ensure `code/adminer/index.php` exists.
2. Add `127.0.0.1 adminer.local` to `/etc/hosts`.
3. Access [http://adminer.local](http://adminer.local) in your browser.
   1. Host: `mysql_80:3306`
   2. User: `root`
   3. Password: `magento`


### Set Up Magento 2

#### Set Up Codebase

1. Create a new directory under `DOCUMENT_ROOT` path mentioned in `.env` file.
2. Copy Magento 2 codebase to the new directory created in step 1.
3. Create a new file under `<DOCUMENT_ROOT>/nginx/virtual-hosts/magento-simple.conf` and add below content.

    ```nginx
    server {
        listen 80;
        server_name magento-simple.local;
        set $FASTCGI_PASS php_82;
        set $MAGE_ROOT /var/www/html/magento-docker;

        set $MAGE_MODE developer;
    
        access_log /var/log/nginx/magento-access.log;
        error_log /var/log/nginx/magento-error.log;
    
        include /etc/nginx/default-magento.conf;
    }
    ```
    1. The conf file name should be same as the directory name.
    2. Replace `magento-simple.local` with your domain.
    3. Use `php_74` for PHP 7.4 and `php_82` for PHP 8.2.
    4. Replace `/var/www/html/magento-docker` with your `/var/www/html/<your_directory>`.

4. Add `127.0.0.1 magento-simple.local` to `/etc/hosts` (replace domain with your domain).
5. Run `bin/restart.sh nginx` to restart the Nginx container.
6. Update `app/etc/env.php` with database configuration.
   1. Host: `mysql_80:3306`
   2. User: `root`
   3. Password: `magento`

### Set Up Database

1. Copy the database dump to `DOCUMENT_ROOT` directory.
2. Connect to the PHP container with `./bin/shell.sh php_74`.
3. Create the database with below query (replace `magento_simple` with your database name

```bash
mysql -h mysql_80 -u root -p -e "CREATE DATABASE magento_simple;"
```

5. Import the database dump with below query (replace `magento_simple` with your database name)

```bash
mysql -h mysql_80 -u root -p magento_simple < /var/www/html/misc/magento_simple.sql
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

#### Failed to load metadata issue when running `./bin/build.sh` or `docker-compose up`
![image](https://github.com/yogesh-valiya/docker-magento/assets/66505755/bc004f83-552a-434e-b90a-4cff6edc2c3f)
Run below command and try again
```
rm  ~/.docker/config.json 
```


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
