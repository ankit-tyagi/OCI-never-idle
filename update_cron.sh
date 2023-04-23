#!/bin/bash

function update_cron_job() {
  cron_status=$(crontab -l | grep -q "$0"; echo $?)
  if [ "$cron_status" -eq 1 ]; then
    log "Updating cron job"
    crontab -l > mycron
    interval=$((24 / runs_per_day))
    for ((i = 0; i < 24; i += interval)); do
      echo "0 $i * * * $(realpath master_script.sh) >> $log_file 2>&1" >> mycron
    done
    crontab mycron
    rm mycron
  else
    log "Cron job already exists"
  fi
}

# Call the update_cron_job function
update_cron_job
