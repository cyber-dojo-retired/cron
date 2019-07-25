#!/bin/bash
set -e
docker exec -it test-cron-server sh -c '/test/test_cron.sh'
