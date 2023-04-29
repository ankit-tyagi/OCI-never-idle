#!/bin/bash

# Variables
RUNS_PER_DAY=200
RUN_DURATION_SECONDS=300
CRON_FILE="basic-poc-cron.txt"

# Set up cron job
CRON_INTERVAL_MINUTES=$(( 1440 / RUNS_PER_DAY ))
echo "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash $(pwd)/basic-poc.sh" > ${CRON_FILE}
crontab -l > temp_crontab
if ! grep -Fxq "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash $(pwd)/basic-poc.sh" temp_crontab; then
    echo "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash $(pwd)/basic-poc.sh" >> temp_crontab
    crontab temp_crontab
fi
rm temp_crontab

echo "Cron job set up to run ${RUNS_PER_DAY} times a day for ${RUN_DURATION_SECONDS} seconds each."
