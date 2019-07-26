#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  build

readonly TMP_SHA=$(docker run --rm cyberdojo/cron sh -c 'echo -n ${SHA}')
readonly TAG=${TMP_SHA:0:7}
docker tag cyberdojo/cron:latest cyberdojo/cron:${TAG}
