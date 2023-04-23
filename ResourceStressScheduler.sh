#!/bin/bash

# Configuration variables
config_file="config.ini"
persistent_file="persistent.ini"
job_name="ResourceStressScheduler"

# Read configuration from the config file
source "$config_file"

# Functions to install required tools
function install_cpulimit() {
  if [ -f /etc/debian_version ]; then
    sudo apt-get install cpulimit -y
  elif [ -f /etc/redhat-release ]; then
    sudo yum install epel-release -y
    sudo yum install cpulimit -y
  else
    log "Unsupported distribution."
    exit 1
  fi
}

function install_wget() {
  if [ -f /etc/debian_version ]; then
    sudo apt-get install wget -y
  elif [ -f /etc/redhat-release ]; then
    sudo yum install wget -y
  else
    log "Unsupported distribution."
    exit 1
  fi
}

function install_sysstat() {
  if [ -f /etc/debian_version ]; then
    sudo apt-get install sysstat -y
  elif [ -f /etc/redhat-release ]; then
    sudo yum install sysstat -y
  else
    log "Unsupported distribution."
    exit 1
  fi
}

# Install required tools
install_cpulimit
install_wget
install_sysstat

# Function to check and rotate the log file
function check_log_file() {
  log_file_size=$(stat -c%s "$log_file_path")

  if ((log_file_size > 10485760)); then
    current_time=$(date +%Y-%m-%d-%H-%M-%S)
    mv "$log_file_path" "${log_file_path%.*}-$current_time.log"
    touch "$log_file_path"
  fi
}

function log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] - $1" | tee -a "$log_file_path"
}

# Functions to stress CPU and network
function stress_cpu() {
  log "Starting CPU stress with ${cpu_usage}% usage for ${duration}"
  cpulimit --limit=$cpu_usage -- yes > /dev/null 2>&1 &
  pid=$!

  sleep $active_time
  kill $pid
  log "CPU stress completed"
}

function stress_network() {
  log "Starting network stress with ${limit_rate} limit for ${duration}"
  wget --limit-rate=$limit_rate -O /dev/null $url > /dev/null 2>&1 &
  pid=$!

  sleep $active_time
  kill $pid
  log "Network stress completed"
}

# Function to monitor and log resource usage
function monitor_resource_usage() {
  log "Starting resource usage monitoring"
  sar -A -o /tmp/sar_output 60 $((active_time / 60)) > /dev/null 2>&1 &
  pid=$!

  sleep $active_time
  kill $pid
  log "Resource usage monitoring completed"
  sar -A -f /tmp/sar_output > "${log_file_path%.*}-resource_usage.log"
  rm -f /tmp/sar_output
}

# Create the log file if it doesn't exist
if [ ! -f "$log_file_path" ]; then
  touch "$log_file_path"
fi

# Function to update the cron job
function update_cron_job() {
  # Read the previous values from the persistent file
  if [ -f "$persistent_file" ]; then
    source "$persistent_file"
  else
    # Set default values for the first run
    prev_url=""
    prev_limit_rate=""
    prev_cpu_usage=0
    prev_active_time=0
    prev_inactive_time=0
    prev_runs_per_day=0
    prev_log_file=""

    # Create the persistent.ini file
    cat <<EOF > "$persistent_file"
prev_url=$url
prev_limit_rate=$limit_rate
prev_cpu_usage=$cpu_usage
prev_active_time=$active_time
prev_inactive_time=$inactive_time
prev_runs_per_day=$runs_per_day
prev_log_file=$log_file
EOF
  fi

  # Compare the previous values with the current values in config.ini
  # ... (same as before)

    log "[$job_name] Updating cron job"

    # ... (same as before)

    log "[$job_name] Cron job updated"
  else
    log "[$job_name] Cron job is up to date"
  fi
}

# Run the script
function run_script() {
  check_log_file
  stress_cpu &
  stress_network &
  monitor_resource_usage
  sleep $inactive_time
}

# Update the cron job if necessary
update_cron_job

# Main loop
while true; do
  run_script
done
