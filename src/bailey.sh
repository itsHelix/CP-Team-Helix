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

# CIS 1.1.1: Disable unused filesystems
filesystem_mounting_disabled() {
  echo "install ${$1} /bin/true" >> /etc/modprobe.d/${$1}.conf
  rmmod ${$1}
}

cramfs_mounting_disabled() { filesystem_mounting_disabled cramfs }
freevxfs_mounting_disabled() { filesystem_mounting_disabled freevxfs }
jffs2_mounting_disabled() { filesystem_mounting_disabled jffs2 }
hfs_mounting_disabled() { filesystem_mounting_disabled hfs }
hfsplus_mounting_disabled() { filesystem_mounting_disabled hfsplus }
udf_mounting_disabled() { filesystem_mounting_disabled udf }

all_filesystem_mounting_disabled() { cramfs_mounting_disabled; freevxfs_mounting_disabled; jffs2_mounting_disabled; hfs_mounting_disabled; hfsplus_mounting_disabled; udf_mounting_disabled }

# CIS 1.1.2: Ensure separate partition exists for /tmp
separate_tmp_partition() {} # Intentionally unimplemented
