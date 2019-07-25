#!/bin/sh
set -e

set -x
# remove blank line from end of file crontabs/root
sed -i '/^$/d' /etc/crontabs/root
# create a new cron period of 1 minute
mkdir /etc/periodic/1min
# and set it up
echo '* *	*	*	*	run-parts /etc/periodic/1min' >> /etc/crontabs/root
# copy pull from daily to 1min
cp /etc/periodic/daily/pull   /etc/periodic/1min/pull
# wait till minute boundary ticks over
sleep $((60 - $(date +%S) + 1))
# give the pull job 30 seconds
sleep 30
# see if pull.log is in /tmp
cat /tmp/pull.log
