#!/bin/bash

# Functions for stressing CPU, network, and monitoring resource usage
function stress_cpu() {
  stress --cpu "$cpu_usage" --timeout "$((active_time * 3600 / runs_per_day))s" &
}

function stress_network() {
  wget --limit-rate="$limit_rate" -O /dev/null "$url" &
}

function monitor_resource_usage() {
  sleep "$((active_time * 3600 / runs_per_day))s"
  pkill stress
  pkill wget
  sleep "$((inactive_time * 3600 / runs_per_day))s"
}

function run_script() {
  stress_cpu &
  stress_network &
  monitor_resource_usage
}

# Call the run_script function
run_script
