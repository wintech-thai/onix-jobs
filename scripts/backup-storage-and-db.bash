#!/bin/bash

pwd

DST_DIR=/tmp
TS=$(date +%Y%m%d_%H%M%S)
DMP_FILE=onix-acdsign-backup-${TS}.sql

gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

pg_dump --dbname="postgresql://${PG_USER}:${PG_PASSWORD}@${PG_HOST}:5432/${PG_DATABASE}" > ${DST_DIR}/${DMP_FILE}

ls -al ${DST_DIR}
