#!/bin/bash

# Load config
source config.ini

function log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] - $1" >> $log_file
}

function check_dependencies() {
  # Check if wget is installed
  if ! command -v wget &> /dev/null; then
    log "Error: wget is not installed. Please install it and try again."
    exit 1
  fi
}

function check_cron() {
  # Check if the script is already added to the cron
  cron_status=$(crontab -l 2>/dev/null | grep -q "$PWD/master.sh"; echo $?)
  if [ "$cron_status" -eq 0 ]; then
    log "Cron job is already set up."
  else
    log "Cron job is not set up. Adding the job to the cron."
    (crontab -l 2>/dev/null; echo "*/$runs_per_day $active_time * * * $PWD/master.sh start >/dev/null 2>&1") | crontab -
    log "Cron job added successfully."
  fi
}

function init() {
  check_dependencies
  check_cron
}

init
