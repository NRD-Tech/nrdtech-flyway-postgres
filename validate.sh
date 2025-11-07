#!/bin/bash

set -x
set -e

source .env.global
source ".env.${ENVIRONMENT}"

PWD=`pwd`
docker run \
--env FLYWAY_PLACEHOLDERS_ENV=${ENVIRONMENT} \
--env HOST=${HOST} \
--env PORT=${PORT} \
--env DB=${DB} \
--env SCHEMA=${SCHEMA} \
--env USER=${USER} \
--env PASS=${PASS} \
--rm \
-v ${PWD}/migration:/flyway/migration \
-v ${PWD}/static:/flyway/static \
-v ${PWD}/conf:/flyway/conf \
-v ${PWD}/drivers:/flyway/drivers \
redgate/flyway:9.19.1 \
-configFiles=conf/config.ini \
-ignoreMigrationPatterns='*:pending' \
validate 