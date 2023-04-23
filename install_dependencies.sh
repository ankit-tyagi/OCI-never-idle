#!/bin/bash

# Functions to install required tools
function install_stress() {
  if ! command -v stress >/dev/null; then
    echo "Installing stress tool..."
    sudo apt-get update
    sudo apt-get install -y stress
  fi
}

function install_wget() {
  if ! command -v wget >/dev/null; then
    echo "Installing wget..."
    sudo apt-get update
    sudo apt-get install -y wget
  fi
}

function main() {
  install_stress
  install_wget
}

main
