#!/bin/bash

# Function to log messages to a file
function log() {
  local logfile="$1"
  local message="$2"
  echo "$(date +"%Y-%m-%d %H:%M:%S") $message" >> "$logfile"
}

# Function to check log file size and rename if necessary
function check_log_file_size() {
  local logfile="$1"
  local logfile_size=$(wc -c "$logfile" | awk '{print $1}')
  local logfile_size_limit="$2"
  if [ $logfile_size -gt $logfile_size_limit ]; then
    log "$logfile" "Log file size exceeded limit. Renaming file..."
    local old_logfile="${logfile%.*}_$(date +"%Y%m%d_%H%M%S").${logfile##*.}"
    mv "$logfile" "$old_logfile"
    log "$logfile" "Log file renamed to $old_logfile"
  fi
}
