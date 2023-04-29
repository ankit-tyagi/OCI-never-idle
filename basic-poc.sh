#!/bin/bash

# Basic Proof of Concept (PoC) script to limit CPU and network usage

# Variables
CPU_PERCENT=25
NET_SPEED_KBPS=200
LOG_FILE="basic-poc.log"
INTERFACE="enp0s3" # Replace with your network interface, e.g., wlan0, enp0s3, eth0, etc.
RUNS_PER_DAY=6
DURATION=3600 # Duration in seconds (1 hour)
CRON_IDENTIFIER="# AUTO GENERATED CRON FOR basic-poc.sh"

# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Check if cpulimit and tc are installed
if command_exists cpulimit && command_exists tc; then
    echo "cpulimit and tc are installed, continuing with the script." | tee -a "$LOG_FILE"
else
    echo "Error: cpulimit and/or tc not found. Please install them before running this script." | tee -a "$LOG_FILE"
    exit 1
fi

# Update or create a new cron job
if [ "$(id -u)" -ne 0 ]; then
    echo "To manage the cron job, please run the script as root." | tee -a "$LOG_FILE"
    exit 1
else
    CRON_SCHEDULE="*/$((24 * 60 / RUNS_PER_DAY)) * * * *"
    CRON_COMMAND="bash $(realpath $0) --run"
    (crontab -l 2>/dev/null | grep -v "$CRON_IDENTIFIER" ; echo "$CRON_SCHEDULE $CRON_COMMAND $CRON_IDENTIFIER") | crontab -
    echo "Cron job updated to run $RUNS_PER_DAY times a day for $DURATION seconds each." | tee -a "$LOG_FILE"
fi

# Check if the script was called with the --run argument
if [ "$#" -eq 1 ] && [ "$1" == "--run" ]; then
    # Limit CPU usage for the current shell
    cpulimit -P $$ -l $CPU_PERCENT &>> "$LOG_FILE" &
    CPULIMIT_PID=$!
    echo "CPU usage for this shell limited to $CPU_PERCENT% (cpulimit PID: $CPULIMIT_PID)" | tee -a "$LOG_FILE"

    # Limit network bandwidth usage
    LIMIT_BW=$NET_SPEED_KBPS

    # Set up traffic control
    tc qdisc add dev $INTERFACE root handle 1: htb default 10 &>> "$LOG_FILE"
    tc class add dev $INTERFACE parent 1: classid 1:1 htb rate ${LIMIT_BW}Kbit ceil ${LIMIT_BW}Kbit &>> "$LOG_FILE"
    tc class add dev $INTERFACE parent 1:1 classid 1:10 htb rate ${LIMIT_BW}Kbit ceil ${LIMIT_BW}Kbit &>> "$LOG_FILE"

    echo "Network bandwidth limited to $LIMIT_BW Kbps on interface $INTERFACE" | tee -a "$LOG_FILE"

    # Sleep for the duration
    sleep $DURATION

    # Revert changes
    kill $CPULIMIT_PID &>> "$LOG_FILE"
    tc qdisc del dev $INTERFACE root &>> "$LOG_FILE"

    echo "CPU and network limitations removed." | tee -a "$LOG_FILE"
fi
