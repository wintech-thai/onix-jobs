#!/bin/bash

echo "NAMESPACE = [${NAMESPACE}]"
echo "POD_NAME_PREFIX = [${POD_NAME_PREFIX}]"

NAME_PREFIX=${POD_NAME_PREFIX}
NS=${NAMESPACE}

DMP_FILE=bk-20240728-001.dump
IMAGE_FILE=acd-images.tar
BUCKET_NAME=onix-v2-backup
GCS_PATH_DB=gs://${BUCKET_NAME}/temp/${DMP_FILE}
GCS_PATH_IMAGES=gs://${BUCKET_NAME}/temp/${IMAGE_FILE}
TMP_TEMPLATE=/tmp/slack.json

DST_DIR=/tmp
#TS=$(date +%Y%m%d_%H%M%S)
POD_DST_DIR=/wis/data/storage

if [ ! -z "${SOURCE_BACKUP_FILE}" ]; then
    GCS_PATH_DB=${SOURCE_BACKUP_FILE}
    DMP_FILE=$(basename ${GCS_PATH_DB})
fi

if [ ! -z "${SOURCE_BACKUP_IMAGES}" ]; then
    GCS_PATH_IMAGES=${SOURCE_BACKUP_IMAGES}
    IMAGE_FILE=$(basename ${GCS_PATH_IMAGES})
fi

gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
gsutil cp ${GCS_PATH_DB} ${DST_DIR} 
gsutil cp ${GCS_PATH_IMAGES} ${DST_DIR} 

echo "Restoring from [${GCS_PATH_DB}] and [${GCS_PATH_IMAGES}]..."
psql "postgresql://${PG_USER}:${PG_PASSWORD}@${PG_HOST}:5432/${PG_DATABASE}" -f ${DST_DIR}/${DMP_FILE}

POD_NAME=$(kubectl get pods -n ${NS} | grep ${NAME_PREFIX} | head -1 | cut -f1 -d' ')

echo "POD_NAME = [${POD_NAME}]"
kubectl cp ${DST_DIR}/${IMAGE_FILE} ${NS}/${POD_NAME}:${POD_DST_DIR}
kubectl exec -i -n ${NS} ${POD_NAME} -- tar -xvf ${POD_DST_DIR}/${IMAGE_FILE}

### Message 1 ###
cat << EOF > ${TMP_TEMPLATE}
{
    "text": "Restore DB done [${GCS_PATH_DB}]"
}
EOF
curl -X POST -H 'Content-type: application/json' --data "@${TMP_TEMPLATE}" ${SLACK_URI}
