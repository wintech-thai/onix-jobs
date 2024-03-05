#!/bin/bash

echo "NAMESPACE = [${NAMESPACE}]"
echo "POD_NAME_PREFIX = [${POD_NAME_PREFIX}]"

NAME_PREFIX=${POD_NAME_PREFIX}
NS=${NAMESPACE}

DST_DIR=/tmp
TS=$(date +%Y%m%d_%H%M%S)
DMP_FILE=onix-acdsign-backup-${TS}.sql
POD_SRC_DIR=/wis/data/storage
BUCKET_NAME=onix-v2-backup

gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
pg_dump --dbname="postgresql://${PG_USER}:${PG_PASSWORD}@${PG_HOST}:5432/${PG_DATABASE}" > ${DST_DIR}/${DMP_FILE}

POD_NAME=$(kubectl get pods -n ${NS} | grep ${NAME_PREFIX} | head -1 | cut -f1 -d' ')

echo "POD_NAME = [${POD_NAME}]"
kubectl cp ${NS}/${POD_NAME}:${POD_SRC_DIR} ${DST_DIR}/storage

BACKUP_FILE=onix-acdsign-images-${TS}.zip 
zip -r ${DST_DIR}/${BACKUP_FILE} ${DST_DIR}/storage
ls -al ${DST_DIR}
find ${DST_DIR}/storage

EXPORTED_FILE=${DST_DIR}/${DMP_FILE}
FILE_SIZE=$(stat -c%s ${EXPORTED_FILE})
TMP_TEMPLATE=/tmp/slack.json
# NOTE : SLACK_URI is injected via env variable
LINE_CNT=$(wc -l ${EXPORTED_FILE} | cut -d' ' -f1)
GCS_PATH_DB=gs://${BUCKET_NAME}/db-backup/${DMP_FILE}

gsutil cp ${EXPORTED_FILE} ${GCS_PATH_DB}

### Message 1 ###
cat << EOF > ${TMP_TEMPLATE}
{
    "text": "Uploaded file [${GCS_PATH_DB}], file size=[${FILE_SIZE}], line count=[${LINE_CNT}]"
}
EOF
curl -X POST -H 'Content-type: application/json' --data "@${TMP_TEMPLATE}" ${SLACK_URI}

### Message 2 ###
FILE_SIZE=$(stat -c%s ${DST_DIR}/${BACKUP_FILE})
GCS_PATH_DB=gs://${BUCKET_NAME}/db-backup/${BACKUP_FILE}

gsutil cp ${DST_DIR}/${BACKUP_FILE} ${GCS_PATH_DB}

cat << EOF > ${TMP_TEMPLATE}
{
    "text": "Uploaded file [${GCS_PATH_DB}], file size=[${FILE_SIZE}]"
}
EOF
curl -X POST -H 'Content-type: application/json' --data "@${TMP_TEMPLATE}" ${SLACK_URI}
