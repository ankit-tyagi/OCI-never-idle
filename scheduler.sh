#!/bin/bash

source ./config.ini
source ./logging.sh

# Function to calculate the sleep time
function calculate_sleep_time() {
  if [ "$1" -eq 0 ]; then
    echo "$inactive_time"
  else
    echo "$active_time"
  fi
}

# Function to check if the log file size limit is reached
function check_log_file_size() {
  if [ -f "$log_file" ]; then
    size=$(du -b "$log_file" | awk '{print $1}')
    if [ "$size" -gt "$log_file_size_limit" ]; then
      i=1
      while [ -f "${log_file}.old.$i" ]; do
        i=$((i+1))
      done
      mv "$log_file" "${log_file}.old.$i"
    fi
  fi
}

# Function to run the script
function run_script() {
  log "Starting script"
  source ./download.sh
  source ./run.sh
  log "Script completed"
}

# Set the cron job
function set_cron_job() {
  cronjob="*/$(($runs_per_day)) * * * * $(pwd)/scheduler.sh"
  (crontab -l ; echo "$cronjob" ) | crontab -
}

# Function to update the cron job
function update_cron_job() {
  cron_status=$(crontab -l | grep -q "scheduler.sh"; echo $?)
  if [ "$cron_status" -eq 1 ]; then
    log "Updating cron job"
    set_cron_job
    log "Cron job updated"
  fi
}

# Create persistent file if it doesn't exist
if [ ! -f ./persistent.ini ]; then
  touch ./persistent.ini
fi

# Read persistent file
if [ -f ./persistent.ini ]; then
  source ./persistent.ini
fi

# Update persistent file with new values
echo "url=$url" > ./persistent.ini
echo "limit_rate=$limit_rate" >> ./persistent.ini
echo "cpu_usage=$cpu_usage" >> ./persistent.ini
echo "memory_usage=$memory_usage" >> ./persistent.ini
echo "network_usage=$network_usage" >> ./persistent.ini
echo "active_time=$active_time" >> ./persistent.ini
echo "inactive_time=$inactive_time" >> ./persistent.ini
echo "runs_per_day=$runs_per_day" >> ./persistent.ini
echo "log_file=$log_file" >> ./persistent.ini
echo "log_file_size_limit=$log_file_size_limit" >> ./persistent.ini

# Calculate sleep time based on current time
current_hour=$(date +'%H')
if [ "$current_hour" -ge 0 ] && [ "$current_hour" -lt "$(($runs_per_day/4))" ]; then
  sleep_time=$(calculate_sleep_time 0)
elif [ "$current_hour" -ge "$(($runs_per_day/4))" ] && [ "$current_hour" -lt "$(($runs_per_day/2))" ]; then
  sleep_time=$(calculate_sleep_time 1)
elif [ "$current_hour" -ge "$(($runs_per_day/2))" ] && [ "$current_hour" -lt "$(($runs_per_day/4*3))" ]; then
  sleep_time=$(calculate_sleep_time 0)
else
  sleep_time=$(calculate_sleep_time 1)
fi

# Check log file size limit
check_log_file_size

# Run the script
run_script

# Update cron job
update_cron_job

# Sleep
sleep "$sleep_time"
