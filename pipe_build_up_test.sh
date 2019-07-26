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

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/build_start_point_images.sh"
"${SH_DIR}/docker_containers_up.sh"
if "${SH_DIR}/run_tests_in_container.sh" ; then
  "${SH_DIR}/docker_containers_down.sh"
else
  exit 3
fi
