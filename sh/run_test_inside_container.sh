#!/bin/bash
set -e

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

poke_start_point()
{
  local -r port=${1}
  local -r name=${2}
  echo "Poking ${name}"
  curl \
    --header "Content-Type: application/json" \
    --data '{}' \
    http://$(ip_address):${port}/image_names
  echo
}

poke_start_point 4526 custom
poke_start_point 4524 languages

docker exec -it test-cron-server sh -c '/test/test_cron.sh'
