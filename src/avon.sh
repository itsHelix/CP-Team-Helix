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

# Install script dependencies
dependencies() {
  log "Installing dependencies"
  apt-get update
  apt-get -y install gufw synaptic libpam-cracklib clamav gnome-system-tools auditd audispd-plugins rkhunter chkrootkit iptables curl unattended-upgrades openssl libpam-tmpdir libpam-umask
  if [ $? = 100 ]; then
    log "FATAL: Vital apt-get is not working. Please fix and test before rerunning the script."
    exit 1
}

# Update Firefox
firefox() {
  killall firefox
  mv !/.mozilla ~/.mozilla.old
  apt-get --purge --reinstall install firefox
}
