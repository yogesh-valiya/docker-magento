# Docker Setup Guide for Magento 2

## Prerequisites

### Install Docker

Make sure you have the following installed on your system:

- Install [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- Install [Docker Compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository)
- Configure Docker to run as a non-root user,
  following [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
  .

### Disable Local Services

To prevent conflicts, stop and disable the following services on your local machine:

```shell
sudo systemctl stop apache2 nginx mysql elasticsearch php7.4-fpm php8.0-fpm php8.2-fpm

sudo systemctl disable apache2 nginx mysql elasticsearch php7.4-fpm php8.0-fpm php8.2-fpm
```

## Installation

### Set Up Docker

1. Install Docker as described [here](#install-docker).
2. Update `DOCUMENT_ROOT` value in `.env` file with absolute path of the codebase parent directory.
    1. Later on all the codebase will be inside this directory.
    2. This directory will be accessible inside the container at `/var/www/html/`.
3. Run docker build command
    ```shell
    `./bin/build.sh`
    ```
4. Run docker start command
    ```shell
    `./bin/start.sh`
    ```

### Set Up Adminer

1. Ensure `code/adminer/index.php` exists.
2. Add `127.0.0.1 adminer.local` to `/etc/hosts`.
    ```shell
    echo "127.0.0.1 adminer.local" | sudo tee -a /etc/hosts
    ```
3. Access [http://adminer.local](http://adminer.local) in your browser.
    1. Host: `mysql_80:3306`
    2. User: `root`
    3. Password: `magento`

### Set Up Magento 2

#### Set Up Codebase

> Replace example directory `magento-simple` with your directory name.

> Replace example domain `magento-simple.local` with your domain.

> Replace container path `/app/magento-simple` with your container path in below format `/app/<your_directory>`

1. Create a new directory `magento-simple` under `DOCUMENT_ROOT` path mentioned in `.env` file and copy Magento 2
   codebase to the new directory.
2. Create a new file under `<DOCUMENT_ROOT>/nginx/virtual-hosts/` named `magento-simple.conf` and add below content.
    1. Replace `magento-simple.local` with your domain.
    2. Use `php_74` for PHP 7.4 and `php_82` for PHP 8.2.
    3. Replace `/app/magento-simple` with your `/app/<directory_name>`.
    ```nginx
    server {
        listen 80;

        server_name magento-simple.local;
        set $FASTCGI_PASS php_82;
        set $MAGE_ROOT /app/magento-simple;

        set $MAGE_MODE developer;
    
        access_log /var/log/nginx/magento-access.log;
        error_log /var/log/nginx/magento-error.log;
    
        include /etc/nginx/default-magento.conf;
    }
    ```

3. Add `127.0.0.1 magento-simple.local` to `/etc/hosts` (replace domain with your domain).

    ```shell
    echo "127.0.0.1 magento-simple.local" | sudo tee -a /etc/hosts
    ```

5. Restart the Nginx container

    ```shell
    ./bin/restart.sh nginx
    ```

6. Update Magento's `app/etc/env.php` with database configuration.
    1. Host: `mysql_80:3306`
    2. User: `root`
    3. Password: `magento`

### Set Up Database

> Replace database name `magento_simple` with your database name.

> Replace DB dump path `/app/magento_simple.sql` with you DB dump path in your container.

1. Copy the database dump to `DOCUMENT_ROOT` directory.
2. Connect to the PHP container.
    ```shell
    ./bin/shell.sh php_74
    ```
3. Create the database with below query

    ```bash
    mysql -h mysql_80 -u root -p -e "CREATE DATABASE magento_simple;"
    ```

4. Import the database dump with below query (replace `magento_simple` with your database name)

    ```bash
    mysql -h mysql_80 -u root -p magento_simple < /app/magento_simple.sql
    ```

5. Update ElasticSearch config

    ```bash
    UPDATE `core_config_data` SET `value` = 'elasticsearch_717' WHERE `path` = 'catalog/search/elasticsearch7_server_hostname';
    UPDATE `core_config_data` SET `value` = '9200' WHERE `path` = 'catalog/search/elasticsearch7_server_port';
    ```
6. Update OpenSearch config **(ONLY IF APPLICABLE)**

    ```bash
    UPDATE `core_config_data` SET `value` = 'opensearch_250' WHERE `path` = 'catalog/search/elasticsearch7_server_hostname';
    UPDATE `core_config_data` SET `value` = '9200' WHERE `path` = 'catalog/search/elasticsearch7_server_port';
    ```
7. Update base URL, static content URL and media URL if applicable form core config table with either `adminer.local` or
   MySQL CLI.

## Folder Structure and Available Commands

### `.env`

- This file contains environment variables for the project.
- `DOCUMENT_ROOT`: Absolute path of the codebase parent directory.
- `MYSQL_USER`: MySQL username for the project.
- `MYSQL_PASSWORD`: MySQL password for the project.
- `MYSQL_ROOT_PASSWORD`: MySQL database root password.

### `docker-compose.yml`

- Container configurations are defined in this file.

### `bin/`

- This directory contains utility commands to manage the project.

#### `bin/build.sh`

- This command will rebuild the docker images.
- Run this command if anything is changed in `images/` directory and docker compose build has to be run.
- Takes container names as an argument. If no argument is passed it will build all containers.

    ```shell
    bin/build.sh nginx php_74
    ```

##### `bin/start.sh`

- This command will start the containers.
- Takes container names as an argument. If no argument is passed it will start all containers.

    ```shell
    bin/start.sh nginx php_74
    ```

##### `bin/stop.sh`

- This command will stop the containers.
- Takes container names as an argument. If no argument is passed it will stop all containers.

    ```shell
    bin/stop.sh nginx php_74
    ```

#### `bin/remove.sh`

- This command will stop and remove the containers.
- Takes container names as an argument. If no argument is passed it will remove all containers.

    ```shell
    bin/remove.sh nginx php_74
    ```

##### `bin/restart.sh`

- This command will restart the containers.
- Takes container names as an argument. If no argument is passed it will restart all containers.

    ```shell
    bin/restart.sh nginx php_74
    ```

##### `bin/status.sh`

- This command will show the status of the containers.
- Takes container names as an argument. If no argument is passed it will show status of all containers.

    ```shell
    bin/status.sh nginx php_74
    ```

#### `bin/run.sh`

- This command will run a command inside the container.
- Takes container name and command as arguments.

    ```shell
    bin/run.sh php_74 php -v
    ```

##### `bin/shell.sh`

- This command will open a shell inside the container.
- Takes container name as an argument.

    ```shell
    bin/shell.sh php_74
    ```

### `images/`:

- This directory contains Dockerfile and configurations for all the images.

## Usages

#### How to run Magento commands?

To run Magento 2 commands, connect to the PHP container with `./bin/shell.sh php_74` or `./bin/shell.sh php_82` and run
the commands as usual.

#### How to access database?

Either use any of the PHP container shell, or MySQL shell, or `adminer.local`

#### How to stop all docker containers?

- Stop all docker containers:
    ```shell
    docker stop $(docker ps -a -q)
    ```
- Remove all docker containers:
    ```shell
    docker rm $(docker ps -a -q)
    ```

#### How to check if ElasticSearch or OpenSearch is working fine ?

- Check ElasticSearch status:
    ```shell
    curl 127.0.0.1:49200
    ```
- Check OpenSearch status:
    ```shell
    curl 127.0.0.1:49201
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

## Troubleshooting

#### A container is not working?

- Check container status with `./bin/status.sh`.
- If it's not running, start it with `docker-compose up <container_name>`. This will show detailed exectuion of
  container including error message if any.

#### Getting port not available error

If getting errror similar to below, then it means that the port is already in use. To fix this, you can either stop the
service using that port or change the port in `docker-compose.yml` file.

#### Failed to load metadata issue when running `./bin/build.sh` or `docker-compose up`

![image](https://github.com/yogesh-valiya/docker-magento/assets/66505755/bc004f83-552a-434e-b90a-4cff6edc2c3f)
Run below command and try again

```
rm  ~/.docker/config.json 
```

#### Failed to bind port - address already in use

![image](https://github.com/yogesh-valiya/docker-magento/assets/66505755/4ab4aec5-36c3-426f-ab51-9b83474f7e8a)

Try to stop all docker containers

```
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```

```bash
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:80 -> 0.0.0.0:0: listen tcp 0.0.0.0:80: bind: address already in use
```

Try to see if any service
