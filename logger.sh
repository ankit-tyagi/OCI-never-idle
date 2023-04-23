#!/bin/bash

source config.ini

function log() {
    local message="$1"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] - $message" >> $log_dir/myapp.log
}
