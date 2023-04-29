#!/bin/bash

# Check if cpulimit, tc, and stress-ng are installed
if ! command -v cpulimit &> /dev/null || ! command -v tc &> /dev/null || ! command -v stress-ng &> /dev/null; then
    echo "Error: cpulimit, tc, and/or stress-ng not found. Please install them before running this script."
    exit 1
fi

# Variables
CPU_PERCENT=25
INTERFACE=enp0s3
NETWORK_SPEED=200kbps
LOG_FILE="basic-poc.log"
CRON_FILE="basic-poc-cron.txt"
RUNS_PER_DAY=200
RUN_DURATION_SECONDS=300

# Calculate the cpulimit value
CPU_CORES=$(nproc)
CPULIMIT_VALUE=$(awk "BEGIN {printf \"%.0f\", ${CPU_PERCENT}*${CPU_CORES}}")

# Set up CPU limiting with stress-ng
stress-ng --cpu ${CPU_CORES} --timeout ${RUN_DURATION_SECONDS}s &

# Set up network limiting
tc qdisc add dev ${INTERFACE} root handle 1: htb default 10
tc class add dev ${INTERFACE} parent 1: classid 1:10 htb rate ${NETWORK_SPEED}
tc filter add dev ${INTERFACE} protocol ip parent 1: prio 1 u32 match ip src 0.0.0.0/0 flowid 1:10

# Set up logging
while true; do
    echo "[$(date)] Status: Running | CPU limit: ${CPULIMIT_VALUE}% | Network limit: ${NETWORK_SPEED}" >> ${LOG_FILE}
    sleep 5
done &

# Set up cron job
CRON_INTERVAL_MINUTES=$(( 1440 / RUNS_PER_DAY ))
echo "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash $(pwd)/basic-poc.sh" > ${CRON_FILE}
crontab -l > temp_crontab
if ! grep -Fxq "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash $(pwd)/basic-poc.sh" temp_crontab; then
    echo "*/${CRON_INTERVAL_MINUTES} * * * * /bin/bash $(pwd)/basic-poc.sh" >> temp_crontab
    crontab temp_crontab
fi
rm temp_crontab

echo "Cron job updated to run ${RUNS_PER_DAY} times a day for ${RUN_DURATION_SECONDS} seconds each."

# Run for the specified duration and then stop limiting CPU and network
sleep ${RUN_DURATION_SECONDS}
killall stress-ng
tc qdisc del dev ${INTERFACE} root

echo "[$(date)] Status: Stopped" >> ${LOG_FILE}
