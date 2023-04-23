#!/bin/bash

# Load the config file
source config.ini

# Set the job name
job_name="my-cpu-job"

# Initialize the job
./init.sh

# Download and run the script
./download.sh

# Schedule the job
./scheduler.sh "$runs_per_day" "$active_time" "$inactive_time" "$job_name"

# Update the cron job
./update_cron_job.sh "$job_name"

# Log the completion of the script
./logging.sh "The script has completed successfully."
