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

# Search the internet for popular topics
log "Searching the internet for popular topics..."
topics=$(curl -s https://trends.google.com/trends/trendingsearches/daily/rss?geo=US | grep -Eo "<title>(.*)</title>" | sed -E 's/<.*>(.*)<\/.*>/\1/' | sed -n '2,11p')

# Store the topics in persistent storage
echo "$topics" > ./persistent_topics.txt

# Get the top websites for each topic
log "Getting the top websites for each topic..."
for topic in $topics; do
    log "Getting top websites for $topic"
    websites=$(curl -s "https://www.google.com/search?q=$topic&num=100" | grep -Eo 'https?://[^/"]+' | grep -Eo 'https?://[^/"]+\.[^/"]+' | sort | uniq | head -n 10)
    echo "$websites" >> "./persistent_websites_${topic// /_}.txt"
done

# Visit the websites and measure response time
log "Visiting the websites and measuring response time..."
for topic in $topics; do
    log "Measuring response time for $topic"
    websites=$(cat "./persistent_websites_${topic// /_}.txt")
    for website in $websites; do
        response_time=$(curl -o /dev/null -s -w '%{time_total}\n' "$website")
        log "Response time for $website: $response_time seconds"
    done
done

# Log the average response time
log "Calculating average response time..."
for topic in $topics; do
    websites=$(cat "./persistent_websites_${topic// /_}.txt")
    total_time=0
    count=0
    for website in $websites; do
        response_time=$(curl -o /dev/null -s -w '%{time_total}\n' "$website")
        total_time=$(echo "$total_time + $response_time" | bc -l)
        count=$((count+1))
    done
    avg_time=$(echo "$total_time / $count" | bc -l)
    log "Average response time for $topic: $avg_time seconds"
done

# Finalize the system
finalize_system
