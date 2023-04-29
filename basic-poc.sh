#!/bin/bash

# Check if stress-ng is installed
if ! command -v stress-ng &> /dev/null; then
    echo "Error: stress-ng not found. Please install it before running this script."
    exit 1
fi

# Variables
INTERFACE=enp0s3
LOG_FILE="/home/ubuntu/repo/OCI-never-idle/basic-poc.log"
RUN_DURATION_SECONDS=300
CPU_LIMIT_PERCENT=40
RAM_LIMIT_PERCENT=40
DISK_RW_SPEED_LIMIT=5 # In MB/s

# Calculate limits
cpu_cores=$(nproc)
cpu_cores_limit=$(( cpu_cores * CPU_LIMIT_PERCENT / 100 ))

total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')
ram_limit=$(( total_ram * RAM_LIMIT_PERCENT / 100 ))

# Run stress-ng test
stress_ng_output=$(stress-ng --cpu ${cpu_cores_limit} --io 1 --vm 1 --vm-bytes ${ram_limit}K --timeout ${RUN_DURATION_SECONDS}s --hdd-bytes ${DISK_RW_SPEED_LIMIT}M --metrics)

# Log the output of stress-ng
echo "[$(date)] Status: Running | Stress-ng output:" >> ${LOG_FILE}
echo "${stress_ng_output}" >> ${LOG_FILE}
echo "[$(date)] Status: Stopped" >> ${LOG_FILE}

# Print the output of stress-ng
echo "${stress_ng_output}"
