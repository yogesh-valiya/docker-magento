#!/bin/bash

source ../.env

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --action)
    ACTION="$2"
    shift 2
    ;;
  --db )
    DB="$2"
    shift 2
    ;;
  --file )
    FILE="$2"
    shift 2
    ;;
  esac
done

# Set variables
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${CODEBASE_PARENT_DIRECTORY}/backups/db/${DATE}"
MYSQL_CONTAINER_NAME="mysql_80"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"

# Ensure the backup directory exists
mkdir -p ${BACKUP_DIR}

if [[ "${ACTION}" == "backup" ]]; then
    # Restore a database
    docker exec -i ${MYSQL_CONTAINER_NAME} mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB} < ${BACKUP_DIR}/${DB}/${DATE}.sql
    exit 0
fi


if [[ "${ACTION}" == "import" ]]; then
    # If no DB passed, then throw an error
    if [[ -z "${DB}" ]]; then
        echo "Please specify a database to import."
        exit 1
    fi
    # If no File passed, then throw an error
    if [[ -z "${FILE}" ]]; then
        echo "Please specify a file to import."
        exit 1
    fi

    if mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "use $DB_NAME"; then
        echo "Database exists."
    else
        mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE $DB_NAME"
    fi
    docker exec -i ${MYSQL_CONTAINER_NAME} mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB} < ${FILE}
    exit 0
fi
# Get a list of databases
DATABASES=$(docker exec ${MYSQL_CONTAINER_NAME} mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

# Loop through each database and create a compressed backup
for DB in $DATABASES; do
    mkdir -p ${BACKUP_DIR}/${DB}
    docker exec ${MYSQL_CONTAINER_NAME} mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --single-transaction --databases ${DB} | gzip > ${BACKUP_DIR}/${DB}/${DATE}.sql.gz
done

# Delete backups older than 7 days
find ${BACKUP_DIR} -type f -name "*.sql.gz" -mtime +7 -exec rm {} \;
