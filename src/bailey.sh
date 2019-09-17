#!/bin/sh

# Script Utilities
mkdir bailey bailey/log bailey/dump
logfile=./bailey/log/bailey_$(date +%T).log
dump=./bailey/dump
password="TiredofWork50"

# Logging
log() {
  echo $(date +%T): $1 >> $logfile
  echo $1
}
