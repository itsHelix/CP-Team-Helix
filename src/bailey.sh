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

# CIS 1.1.20: Ensure sticky bit is set on all world-wriable directories
world_writable_sticky_bit() {
  df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t
}

# CIS 1.2.1: Ensure package manager repositories are configured
package_manager_repos_configured() {
  # Var setup for function
  sources_loc="/etc/apt/sources.list"
  current_os=`cat /etc/*release | grep -i 'PRETTY_NAME' | grep -o '".*"' | sed 's/"//g'`

  # Setting source lists
  if [[ $current_os == *14.04* ]]; then
    cat presets/14.04sources.list > $sources_loc
  elif [[ $current_os == *16* ]]; then
    cat presets/16sources.list > $sources_loc
  elif [[ $current_os == *Debian* ]]; then
    cat presets/jessiesources.list > $sources_loc
  fi
}
