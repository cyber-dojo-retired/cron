#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

exit_if_ROOT_DIR_not_in_context()
{
  if using_DockerToolbox && on_Mac; then
    if [ "${ROOT_DIR:0:6}" != "/Users" ]; then
      echo 'ERROR'
      echo 'You are using Docker-Toolbox for Mac'
      echo "This script lives off ${ROOT_DIR}"
      echo 'It must live off /Users so the docker-context'
      echo "is automatically mounted into the default VM"
      exit 1
    fi
  fi
}

using_DockerToolbox()
{
  [ -n "${DOCKER_MACHINE_NAME}" ]
}

on_Mac()
{
  # detect OS from bash
  # https://stackoverflow.com/questions/394230
  [[ "$OSTYPE" == "darwin"* ]]
}

# - - - - - - - - - - - - - - - - -

declare TMP_DIR=''

make_TMP_DIR()
{
  [ -d "${ROOT_DIR}/tmp" ] || mkdir "${ROOT_DIR}/tmp"
  TMP_DIR=$(mktemp -d "${ROOT_DIR}/tmp/cyber-dojo-cron.XXX")
  trap remove_TMP_DIR EXIT
  chmod 700 "${TMP_DIR}"
}

remove_TMP_DIR()
{
  rm -rf "${TMP_DIR}" > /dev/null
}

# - - - - - - - - - - - - - - - - -

on_CI()
{
  [[ ! -z "${CIRCLE_SHA1}" ]]
}

build_image_script_name()
{
  if on_CI; then
    # ./circleci/config.yml curls the cyber-dojo script into /tmp
    echo '/tmp/cyber-dojo'
  else
    echo "${ROOT_DIR}/../commander/cyber-dojo"
  fi
}

# - - - - - - - - - - - - - - - - -

create_csharp_nunit_git_repo_in_TMP_DIR()
{
  cp -R ${ROOT_DIR}/test_data/csharp_nunit_start_point ${TMP_DIR}
  cd ${TMP_DIR}
  git init > /dev/null
  git config --global user.email 'cron@cyber-dojo.org'
  git config --global user.name 'cron'
  git add .
  git commit --quiet --message='only commit'
}

# - - - - - - - - - - - - - - - - -
build_test_cron_custom_tiny_image()
{
  make_TMP_DIR
  create_csharp_nunit_git_repo_in_TMP_DIR
  echo
  echo Building cyberdojo/custom_tiny
  "$(build_image_script_name)"    \
    start-point create            \
      ${CYBER_DOJO_CUSTOM}        \
        --custom                  \
          "file://${TMP_DIR}"
  remove_TMP_DIR
}

# - - - - - - - - - - - - - - - - -
build_test_cron_languages_tiny_image()
{
  make_TMP_DIR
  create_csharp_nunit_git_repo_in_TMP_DIR
  echo
  echo Building cyberdojo/languages_tiny
  "$(build_image_script_name)"     \
    start-point create             \
      ${CYBER_DOJO_LANGUAGES}      \
        --languages                \
          "file://${TMP_DIR}"
  remove_TMP_DIR
}

# - - - - - - - - - - - - - - - - -
exit_if_ROOT_DIR_not_in_context
echo
$(build_image_script_name) version
build_test_cron_custom_tiny_image
build_test_cron_languages_tiny_image
