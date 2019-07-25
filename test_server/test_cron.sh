#!/bin/sh
set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dotted_wait()
{
  local wait_seconds="${1}"
  until test $((wait_seconds--)) -eq 0; do
    sleep 1
    echo -n .
  done
  echo
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
file_wait()
{
  local filename="$1"
  local wait_seconds="${2}"

  until test $((wait_seconds--)) -eq 0 -o -f "$filename" ; do
    sleep 1
    echo -n .
  done
  echo
  if [ -f "${filename}" ]; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
setup_pull_as_1min_cronjob()
{
  echo 'setting up [/etc/periodic/1min/pull]'
  # remove blank line from end of file crontabs/root
  sed -i '/^$/d' /etc/crontabs/root
  # create a new cron period of 1 minute
  mkdir /etc/periodic/1min
  # set it up
  echo '* *	*	*	*	run-parts /etc/periodic/1min' >> /etc/crontabs/root
  # copy pull from daily to 1min
  cp /etc/periodic/daily/pull   /etc/periodic/1min/pull
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
wait_till_1min_cronjob_boundary_ticks_over()
{
  SECS=$((60 - $(date +%S) + 1))
  echo -n "waiting till minute boundary ticks over in ${SECS} seconds"
  dotted_wait ${SECS}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
wait_at_most_60_seconds_for_1min_pull_to_write_its_log_file()
{
  echo -n 'waiting at most 60 seconds for [/etc/periodic/1min/pull] to complete'
  pull_log_file=/tmp/pull.log
  max_wait_secs=60
  file_wait ${pull_log_file} ${max_wait_secs} || {
    echo "pull log file file missing after waiting for ${max_wait_secs} seconds: ${pull_log_file}"
    exit 3
  }
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

setup_pull_as_1min_cronjob
wait_till_1min_cronjob_boundary_ticks_over
wait_at_most_60_seconds_for_1min_pull_to_write_its_log_file

echo "pull log file has appeared :-)"
expected="$(cat /test/pull.log.expected)"
actual="$(cat "${pull_log_file}")"
if [ "${expected}" = "${actual}" ]; then
  echo 'pull log file contains expected content :-)'
  exit 0
else
  echo 'pull log file does _NOT_ contain the expected content :-('
  echo ":expected:${expected}:"
  echo ":  actual:${actual}:"
  exit 3
fi
