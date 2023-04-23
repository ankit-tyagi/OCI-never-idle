#!/bin/bash

# Read configuration from the config file
config_file="$(dirname "${BASH_SOURCE[0]}")/config.ini"
source "$config_file"

# Make the scripts executable
chmod +x "$(dirname "${BASH_SOURCE[0]}")/"*.sh

# Functions for logging
function log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] - $1" | tee -a "$log_file"
}

# Call the individual scripts in the proper sequence
script_dir=$(dirname "${BASH_SOURCE[0]}")
log "Installing dependencies..."
source "$script_dir/install_dependencies.sh"
log "Updating cron job..."
source "$script_dir/update_cron.sh"
log "Running stress tests..."
source "$script_dir/run_stress.sh"
