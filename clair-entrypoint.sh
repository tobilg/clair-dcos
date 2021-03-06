#!/usr/bin/env bash

# Render config.conf and start postgrest
dockerize -delims "<%:%>" -template $CLAIR_DCOS_PATH/config.yaml.template:$CLAIR_DCOS_PATH/config.yaml -wait tcp://$POSTGRES_HOST:$POSTGRES_PORT -timeout ${POSTGRES_TIMEOUT_SECONDS}s /clair -config=$CLAIR_DCOS_PATH/config.yaml
