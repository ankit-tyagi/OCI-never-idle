#!/bin/bash

# Load the config file
source config.ini

# Load the logging functions
source logging.sh

# Load the init functions
source init.sh

# Load the download functions
source download.sh

# Load the scheduling functions
source scheduling.sh

# Initialize the logging
init_logging "${log_file}" "${log_file_size_limit}"

# Initialize the system
init_system

# Stress test RAM
ram_stress_test

# Download and run the script
download_and_run

# Schedule the script
schedule_script

# Finalize the system
finalize_system
