#!/usr/bin/env bats

# CIS 1.1.1: Disable unused filesystems
filesystem_mounting_disabled_boolean() {
  result1="$(modprobe -n -v ${$1})"
  result2="$(lsmod | grep ${$1})"
  return [ result1 -eq "install /bin/true" && result2 -eq "" ]
}

@test "cramfs mounting disabled" {
  [ filesystem_mounting_disabled_boolean cramfs ]
}
@test "freevxfs mounting disabled" {
  [ filesystem_mounting_disabled_boolean freevxfs ]
}
@test "jffs2 mounting disabled" {
  [ filesystem_mounting_disabled_boolean jffs2 ]
}
@test "hfs mounting disabled" {
  [ filesystem_mounting_disabled_boolean hfs ]
}
@test "hfsplus mounting disabled" {
  [ filesystem_mounting_disabled_boolean hfsplus ]
}
@test "udf mounting disabled" {
  [ filesystem_mounting_disabled_boolean udf ]
}

# CIS 1.1.20: Ensure sticky bit is set on all world-writable directories
@test "sticky bit is set on all world-writable directories" {
  result="$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null)"
  [ result -eq "" ]
}

# CIS 1.2.1: Ensure package manager repositories are configured
@test "current source list matches master lists" {
  # Var setup for test
  sources=`cat /etc/apt/sources.list`
  current_os=`cat /etc/*release | grep -i 'PRETTY_NAME' | grep -o '".*"' | sed 's/"//g'`

  # Checking source lists
  if [[ $current_os == *14.04* ]]; then
    result=$(cat presets/14.04sources.list)
    [ result -eq $sources ]
  elif [[ $current_os == *16* ]]; then
    result=$(cat presets/16sources.list)
    [ result -eq $sources ]
  elif [[ $current_os == *Debian* ]]; then
    result=$(cat presets/jessiesources.list)
    [ result -eq $sources ]
  fi
}

# CIS 1.3.1: Ensure AIDE is installed
@test "AIDE is installed" {
  result=$(dpkg -s aide)
  [result -ne * not *]
}

# CIS 1.3.2: Ensure filesystem integrity is regularly checked
@test "filesystem integrity checks are automatic" {
  result=$(grep -r aide /etc/cron.* /etc/crontab)
  [ result -ne "" ]
}

# CIS 1.4.1: Ensure permissions on bootloader config are configured
@test "bootloader permissions are set correctly" {
  result=$(stat /boot/grub/grub.cfg | grep -i "access: (" | sed 's/"//g')
  [ result -eq *0600* ]
}

# CIS 1.4.2: Ensure bootloader password is set
@test "bootloader has a password" {
  result=$(grep "^password" /boot/grub/grub.cfg)
  [ result -ne "" ]
}
