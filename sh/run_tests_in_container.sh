#!/bin/bash
set -e

# - - - - - - - - - - - - - - - - - - - - - - -
ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - -
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

# - - - - - - - - - - - - - - - - - - - - - - -
check_csharp_nunit_image()
{
  local -r image_name=cyberdojofoundation/csharp_nunit
  if docker image ls | grep --quiet ${image_name}; then
    echo "$1 ${image_name} IS present"
  else
    echo "$1 ${image_name} is NOT present"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - -
curl_poke 4526 image_names custom
curl_poke 4524 image_names languages

check_csharp_nunit_image Before:
docker exec -it test-cron-server sh -c '/test/test_cron.sh'
check_csharp_nunit_image After:
