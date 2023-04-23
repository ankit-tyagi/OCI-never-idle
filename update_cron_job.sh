#!/bin/bash

# Load the config file
source /path/to/config.ini

# Function to update the cron job
function update_cron_job() {
  cron_status=$(crontab -l | grep -q "$0"; echo $?)
  if [ "$cron_status" -eq 1 ]; then
    log "Updating cron job"
    # Calculate the duration of each run
    run_duration=$(echo "scale=2; ($active_time/$runs_per_day)/60" | bc)
    # Calculate the start time for each run
    start_time=$(date +%H:%M -d "$start_time_today")
    # Calculate the end time for each run
    end_time=$(date +%H:%M -d "$end_time_today")
    # Calculate the interval for each run
    interval=$(echo "scale=2; (($end_time_today-$start_time_today)/$runs_per_day)*60" | bc)
    # Add the cron job for each run
    for i in $(seq 1 $runs_per_day); do
      cron_entry="$start_time"
      cron_entry+=" */$interval * * * $script_path/run.sh > $log_file 2>&1"
      ( crontab -l | grep -v -F "$script_path/run.sh" ; echo "$cron_entry" ) | crontab -
      start_time=$(date +%H:%M -d "$start_time + $run_duration minutes")
    done
  fi
}

# Update the cron job
update_cron_job
