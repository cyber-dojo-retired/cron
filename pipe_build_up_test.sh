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
export CYBER_DOJO_PULLER_TAG=${CYBER_DOJO_PULLER_SHA:0:7}
echo "puller ${CYBER_DOJO_PULLER_SHA} cyberdojo/puller:${CYBER_DOJO_PULLER_TAG}"
set +a

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/build_start_point_images.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/run_test_inside_container.sh"
