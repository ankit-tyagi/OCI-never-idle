# Work In Progress

# POC
Execut below things
```
sudo apt-get update
sudo apt-get install cpulimit tc
sudo apt-get install iproute2
ifconfig -a
ip link show
ip addr show eth0




chmod +x basic-poc.sh
./basic-poc.sh
```

# Script not working

## Stress Testing Script

This repository contains a shell script that downloads a file from a specified URL at a specified rate limit and runs a script that consumes a specified percentage of CPU, memory, and network for a specified amount of time. It also schedules the script to run a specified number of times per day during specific time intervals and logs all the minute actions in a file in a specified location, with automatic file rotation. The script allows for the configuration of all relevant parameters in a single configuration file and the creation and updating of a persistent file to track changes in configuration parameters. It also supports RAM testing and multiple distributions when installing software.

### Installation and Usage

1. Clone the repository to your local machine:

```
git clone https://github.com/username/stress-testing-script.git
```

2. Navigate to the project directory:

```
cd stress-testing-script
```

3. Edit the `config.ini` file to set your desired configuration parameters.

4. Run the `master.sh` script to start the stress testing:

```
./master.sh
```

### Configuration

All relevant configuration parameters can be set in the `config.ini` file. The parameters that can be configured include:

- `url`: the URL from which to download the file
- `limit_rate`: the rate limit for downloading the file
- `cpu_usage`: the percentage of CPU to consume during the stress test
- `memory_usage`: the percentage of RAM to consume during the stress test
- `network_usage`: the percentage of network bandwidth to consume during the stress test
- `active_time`: the length of time for the stress test to run during each interval
- `inactive_time`: the length of time for the stress test to rest during each interval
- `runs_per_day`: the number of times to run the stress test each day
- `log_file`: the location and name of the log file
- `log_file_size_limit`: the maximum size of the log file before rotation
- `cpu_test_interval`: the interval at which to run the CPU test
- `network_test_interval`: the interval at which to run the network test

### Persistence

The script also supports the creation and updating of a persistent file to track changes in configuration parameters. The `persistent.ini` file is created automatically if it does not exist, and it is read and updated automatically with each run of the script.

### Modular Design

The script is designed with modularity in mind, with separate shell scripts for each module to allow for easy maintenance and customization. The `master.sh` script is the main script that calls the other scripts in the proper sequence.

### Cron Job

The script schedules the stress test to run at the specified intervals using a cron job. The `scheduler.sh` script is responsible for calculating the sleep time and updating the cron job based on changes in configuration parameters.

### Logging

The script logs all the minute actions in a file in a specified location, with automatic file rotation. The `logging.sh` script contains functions to log messages to a file and to check the log file size and rename it if necessary.

### RAM Testing

The script also supports RAM testing. The `download.sh` script calculates the total amount of RAM on the system and adjusts the size of the memory test accordingly.

### Support for Multiple Distributions

The script also supports multiple distributions when installing software. The `download.sh` script checks the distribution of the system and installs the appropriate package manager and dependencies.

### License

This project is licensed under the MIT License. See the `LICENSE` file for details.