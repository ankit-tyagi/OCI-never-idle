#!/bin/bash

source ./config.ini

function download_and_run() {
    local filename=$(basename "$url")
    local download_dir="/tmp"
    local download_path="${download_dir}/${filename}"
    local log_file_size_limit=10485760

    # Download the file
    echo "Downloading ${filename} to ${download_path}..."
    wget --limit-rate="${limit_rate}" -q -O "${download_path}" "${url}"
    if [[ $? -ne 0 ]]; then
        echo "Failed to download ${filename}"
        exit 1
    fi

    chmod +x "${download_path}"

    # Calculate memory test size
    local mem_total=$(free -g | awk '/Mem/ {print $2}')
    local mem_test="-m 2"
    if [[ "$mem_total" -lt 4 ]]; then
        echo "AMD doesn't need to test memory!"
        mem_test=''
    elif [[ "$mem_total" -lt 13 ]]; then
        echo "Memory test size: [1G]"
        mem_test='-m 1'
    else
        echo "Memory test size: [2G]"
    fi

    # Calculate CPU test and network test intervals
    local cpu_test="-c ${active_time}"
    if [[ -z "$cpu_test_interval" ]]; then
        echo "CPU test interval is empty, set to default value: [${active_time}]"
    elif [[ "$cpu_test_interval" == "0" ]]; then
        echo "CPU test can't be disabled, set to default value: [${active_time}]"
    else
        cpu_test="-c ${cpu_test_interval}h"
        echo "CPU test interval: [${cpu_test_interval}h]"
    fi

    local network_test="-n ${active_time}"
    if [[ -z "$network_test_interval" ]]; then
        echo "Network test interval is empty, set to default value: [${active_time}]"
    elif [[ "$network_test_interval" == "0" ]]; then
        echo "Network test disabled."
        network_test=""
    else
        network_test="-n ${network_test_interval}h"
        echo "Network test interval: ${network_test_interval}"
    fi

    # Run the script
    echo "Running ${filename}..."
    nohup "${download_path}" "${cpu_test}" "${mem_test}" "${network_test}" > "${log_file}" 2>&1 &

    # Stress test RAM
    ram_stress_test

    # Rotate log file if necessary
    local log_size=$(stat -c%s "$log_file")
    if [[ "$log_size" -gt "$log_file_size_limit" ]]; then
        echo "Rotating log file..."
        mv "$log_file" "${log_file}.1"
        touch "$log_file"
    fi

    echo "Done."
}

function ram_stress_test() {
    local mem_total=$(free -g | awk '/Mem/ {print $2}')
    local mem_stress=$((mem_total * ram_stress_percentage / 100))
    local stress_time=$((active_time * 3600))
    echo "Stressing ${mem_stress}G of RAM for ${stress_time} seconds..."
    stress-ng --vm "${mem_stress}G" --vm-bytes 80% --timeout "${stress_time}s" >> "${log_file}" 2>&1
}


download_and_run
