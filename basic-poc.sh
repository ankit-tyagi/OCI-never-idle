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

# Run stress-ng test
stress_ng_output=$(stress-ng --cpu $(nproc) --io 1 --vm 1 --vm-bytes 1M --timeout ${RUN_DURATION_SECONDS}s --metrics)

# Log the output of stress-ng
echo "[$(date)] Status: Running | Stress-ng output:" >> ${LOG_FILE}
echo "${stress_ng_output}" >> ${LOG_FILE}
echo "[$(date)] Status: Stopped" >> ${LOG_FILE}

# Print the output of stress-ng
echo "${stress_ng_output}"
