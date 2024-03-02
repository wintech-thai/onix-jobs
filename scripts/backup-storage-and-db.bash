#!/bin/bash

echo "NAMESPACE = [${NAMESPACE}]"
echo "POD_NAME_PREFIX = [${POD_NAME_PREFIX}]"

NAME_PREFIX=${POD_NAME_PREFIX}
NS=${NAMESPACE}

DST_DIR=/tmp
TS=$(date +%Y%m%d_%H%M%S)
DMP_FILE=onix-acdsign-backup-${TS}.sql
POD_SRC_DIR=/wis/data/storage

gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
pg_dump --dbname="postgresql://${PG_USER}:${PG_PASSWORD}@${PG_HOST}:5432/${PG_DATABASE}" > ${DST_DIR}/${DMP_FILE}

POD_NAME=$(kubectl get pods -n ${NS} | grep ${NAME_PREFIX} | head -1 | cut -f1 -d' ')

echo "POD_NAME = [${POD_NAME}]"
kubectl cp ${NS}/${POD_NAME}:${POD_SRC_DIR} ${DST_DIR}/storage

ls -al ${DST_DIR}
find . -name ${DST_DIR}/storage

