#!/bin/bash

# Variables
RUNS_PER_DAY=200
RUN_DURATION_SECONDS=300
CRON_FILE="basic-poc-cron.txt"

# Set up cron job
CRON_INTERVAL_MINUTES=$(( 1440 / RUNS_PER_DAY ))
echo "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash /home/ubuntu/repo/OCI-never-idle/basic-poc.sh" > ${CRON_FILE}
crontab -l > temp_crontab
if ! grep -Fxq "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash /home/ubuntu/repo/OCI-never-idle/basic-poc.sh" temp_crontab; then
    echo "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash /home/ubuntu/repo/OCI-never-idle/basic-poc.sh" >> temp_crontab
    crontab temp_crontab
fi
rm temp_crontab

echo "Cron job set up to run ${RUNS_PER_DAY} times a day for ${RUN_DURATION_SECONDS} seconds each."

# Basic variables
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$BASE_DIR/trending_topics.py"

# Add the trending topics Python script to crontab
(crontab -l 2>/dev/null; echo "*/14 * * * * /usr/bin/python3 $SCRIPT_PATH") | crontab -

echo "Cron job added to run the Python script 100 times a day."
