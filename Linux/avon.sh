#!/usr/bin/env bash

# Contributors: Tavin Turner
# A flexible system hardening shell

if [ $EUID -ne 0 ]; then
  echo "Run as root"
  exit
fi

mkdir avon avon/logs avon/dump
logs=$(pwd)/avon/logs/
dump=$(pwd)/avon/dump/
