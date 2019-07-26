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

curl_poke()
{
  local -r port=${1}
  local -r path=${2}
  local -r name=${3}
  echo "Poking ${name}"
  curl \
    --header "Content-Type: application/json" \
    --data '{}' \
    http://$(ip_address):${port}/${path}
  echo
}

curl_poke 4526 image_names custom
curl_poke 4524 image_names languages
curl_poke 5017 pull puller

docker exec -it test-cron-server sh -c '/test/test_cron.sh'
