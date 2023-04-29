#!/bin/bash

# Check if cpulimit and tc are installed
if ! command -v cpulimit &> /dev/null || ! command -v tc &> /dev/null; then
    echo "Error: cpulimit and/or tc not found. Please install them before running this script."
    exit 1
fi

# Variables
CPU_PERCENT=25
INTERFACE="enp0s3" # Replace with your network interface, e.g., wlan0, enp0s3, eth0, etc.
upNETWORK_SPEED=200kbps
LOG_FILE="basic-poc.log"
CRON_FILE="basic-poc-cron.txt"
RUNS_PER_DAY=8
RUN_DURATION_SECONDS=3600

# Calculate the cpulimit value
CPU_CORES=$(nproc)
CPULIMIT_VALUE=$(awk "BEGIN {printf \"%.0f\", ${CPU_PERCENT}*${CPU_CORES}}")

# Set up CPU limiting
cpulimit -e "cpulimit" -l ${CPULIMIT_VALUE} &

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
killall cpulimit
tc qdisc del dev ${INTERFACE} root

echo "[$(date)] Status: Stopped" >> ${LOG_FILE}
