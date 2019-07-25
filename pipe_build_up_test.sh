#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"
export SHA=$(cd "${SH_DIR}" && git rev-parse HEAD)

docker run --rm \
  cyberdojo/versioner:${CYBER_DOJO_VERSIONER_TAG:-latest} \
    sh -c 'cat /app/.env' \
      > /tmp/versioner.web.env
set -a
. /tmp/versioner.web.env
set +a
# Use languages-small as its smaller than languages-common
CDL=${CYBER_DOJO_LANGUAGES}
export CYBER_DOJO_LANGUAGES=${CDL/common/small}

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
#"${SH_DIR}/test.sh"
