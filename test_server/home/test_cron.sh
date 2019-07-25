#!/bin/sh
set -e

mkdir /etc/periodic/1min
#sed -i '/^$/d' /etc/crontabs/root
echo '* *	*	*	*	run-parts /etc/periodic/1min' >> /etc/crontabs/root
cp /etc/periodic/15min/pull   /etc/periodic/1min/pull

sleep $((60 - $(date +%S) + 1))

ls -al /tmp
