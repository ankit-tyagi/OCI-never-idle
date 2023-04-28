#!/bin/bash

# Basic Proof of Concept (PoC) script to limit CPU and network usage

# Variables
CPU_PERCENT=25
NET_PERCENT=15
LOG_FILE="basic-poc.log"
INTERFACE="eth0" # Replace with your network interface, e.g., wlan0, enp0s3, etc.
DURATION=3600 # Duration in seconds (1 hour)

# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Check if cpulimit, tc, and ethtool are installed
if command_exists cpulimit && command_exists tc && command_exists ethtool; then
    echo "cpulimit, tc, and ethtool are installed, continuing with the script." | tee -a "$LOG_FILE"
else
    echo "Error: cpulimit, tc, and/or ethtool not found. Please install them before running this script." | tee -a "$LOG_FILE"
    exit 1
fi

# Limit CPU usage for the current shell
cpulimit -P $$ -l $CPU_PERCENT &>> "$LOG_FILE" &
CPULIMIT_PID=$!
echo "CPU usage for this shell limited to $CPU_PERCENT% (cpulimit PID: $CPULIMIT_PID)" | tee -a "$LOG_FILE"

# Limit network bandwidth usage
MAX_BW=$(ethtool $INTERFACE | grep -i "speed" | awk '{print $2}') # Get maximum bandwidth in Mbps
LIMIT_BW=$(echo "$MAX_BW * $NET_PERCENT / 100" | bc) # Calculate limit in Mbps

# Set up traffic control
tc qdisc add dev $INTERFACE root handle 1: htb default 10 &>> "$LOG_FILE"
tc class add dev $INTERFACE parent 1: classid 1:1 htb rate ${LIMIT_BW}Mbit ceil ${LIMIT_BW}Mbit &>> "$LOG_FILE"
tc class add dev $INTERFACE parent 1:1 classid 1:10 htb rate ${LIMIT_BW}Mbit ceil ${LIMIT_BW}Mbit &>> "$LOG_FILE"

echo "Network bandwidth limited to $LIMIT_BW Mbps on interface $INTERFACE" | tee -a "$LOG_FILE"

# Sleep for the duration
sleep $DURATION

# Revert changes
kill $CPULIMIT_PID &>> "$LOG_FILE"
tc qdisc del dev $INTERFACE root &>> "$LOG_FILE"

echo "CPU and network limitations removed. Exiting script." | tee -a "$LOG_FILE"
