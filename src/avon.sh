#!/usr/bin/env bash

mkdir avon avon/log avon/dump
logf=./avon/log/avon_$(date +%T).log
dump=./avon/dump

# Logging
log() {
  echo $(date +%T): $1 >> $logf
  echo $1
}

# Ensure script is running as root
if [ $EUID -ne 0 ]; then
  log "Run as root"
  exit 64
fi

# Automatic updates
autoupdate() {
  log "Enabling automatic updates"
  cat presets/auto-upgrades > /etc/apt/apt.conf.d/20auto-upgrades
}

# Secure sourcing
sourcing() {
  log "Using most trustworthy sources in source.list"
  cat presets/sources.list > /etc/apt/sources.list
}
