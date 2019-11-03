#!/usr/bin/env bats

# CIS: Mozilla Firefox 38
@test "CIS is implemented in Firefox" {
  correct=`cat presets/syspref.js`
  result=`cat /etc/firefox/syspref.js`
  [ result -eq correct ]
}

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

# CIS 1.4.3: Ensure authentication required for single user mode
@test "authentication is required for single user mode" {
  result=$(grep ^root:[*\!]: /etc/shadow)
  [ result -eq ""]
}

# CIS 1.5.1: Ensure core dumps are restricted
@test "core dumps are restricted" {
  result1=$(grep "hard core" /etc/security/limits.conf /etc/security/limits.d/*)
  result2=$(sysctl fs.suid_dumpable)
  result3=$(grep "fs\.suid_dumpable" /etc/sysctl.conf /etc/sysctl.d/*)
  [ result1 -eq "* hard core 0" && result2 -eq "fs.suid_dumpable = 0" && result3 -eq "fs.suid_dumpable = 0" ]
}

# CIS 1.5.3: Ensure address space layout randomization (ASLR) is enabled
@test "aslr is enabled" {
  result1=$(sysctl kernel.randomize_va_space)
  result2=$(grep "kernel\n.randomize_va_space" /etc/sysctl.conf /etc/sysctl.d/*)
  [ result1 -eq "kernel.randomize_va_space = 2" && result2 -eq "kernel.randomize_va_space = 2" ]
}

# CIS 1.5.4: Ensure prelink is disabled
@test "prelink is disabled" {
  result1=$(dpkg -s prelink)
  [ result1 -eq "" ]
}

# CIS 1.6.1.1: Ensure SELinux is not disabled in bootloader configuration
@test "no `selinux=0` or `enforcing=0` in linux lines" {
  result1=$(grep "^\s*linux" /boot/grub/grub.cfg)
  [ result1 -eq "" ]
}

# CIS 1.6.1.2: Ensure the SELinux state is enforcing
@test "ensure selinux state is enforcing" {
  result1=$(grep SELINUX=enforcing /etc/selinux/config)
}

# CIS 1.6.1.3: Ensure SELinux policy is configured
@test "selinux policy is configured" {
  result1=$(grep SELINUXTYPE= /etc/selinux/config)
  result2=$(sestatus)
  [ result1 -eq "SELINUXTYPE=ubuntu" && result2 -eq *ubuntu* ]
}

# CIS 1.6.2.1: Ensure AppArmor is not disabled in bootloader configuration
@test "no `apparmor=0` in linux lines" {
  result1=$(grep "^\s*linux" /boot/grub/grub.cfg)
  [ result1 -eq "" ]
}

# CIS 1.6.2.2: Ensure all AppArmor Profiles are enforcing
@test "all apparmor profiles are enforcing" {
  [ apparmor_status -eq *apparmor module is loaded* ]
}

# CIS 1.6.3: Ensure SELinux or AppArmor are installed
@test "selinux or apparmor installed" {
  result1=$(dpkg -s selinux)
  [ result1 -ne "" ]
}

# Ensure Whoopsie is installed (no CIS)
@test "ensure whoopsie is installed" {
  result1=$(dpkg -s whoospie)
  [ result1 -ne "" ]
}

# CIS 2.1: inetd services
@test "Making sure insecure inetd services are disabled" {
  # This is a test to see if the files inetd.* exists, if so this is also a test for the chargen service
  grep -R "^chargen" /etc/inetd.* > temp.txt
  test_for_file=`cat temp.txt`
  if [[ $test_for_file == *No such file* ]]; then
    echo "No inetd servers/services are installed"
  else
    services=("^daytime" "^discard" "^echo" "^time" "^shell" "^login" "^exec" "^talk" "^ntalk" "^telnet" "^tftp")
    for (i in "${services}"); do
      grep -R "$i" /etc/inetd.* >> temp.txt
    done
    systemctl is-enabled xinetd >> temp.txt # This final check will write the word "disabled" into the temp.txt
    result=`cat temp.txt`
    [ result -eq "disabled"]
  fi
  rm temp.txt
}

# CIS 2.2.2-17 (not including 2.2.15): Special Purpose Services
@test "Making sure special services are disabled" {
  services=("avahi-daemon" "cups" "isc-dhcp-server6" "isc-dhcp-server" "slapd" "rpcbind" "nfs-kernel-server" "bind9" "vsftpd" "apache2" "dovecot" "smbd" "squid" "snmpd" "rsync" "nis")
  for (i in "${services[@]}"); do
    systemctl is-enabled "$i" >> temp.txt
  done
  result=`cat temp.txt`
  [ result -ne *enabled* ]
  rm temp.txt
}

# CIS 4.1.2: Ensure auditd service is enabled
@test "Auditd service enabled" {
  result=`systemctl is-enabled auditd`
  [ result -eq *enabled* ]
}





# CIS 4.2.1: Configure rsyslog
@test "Rsylog is configured" {
  rsyslog_install=`systemctl is-enabled rsyslog`
  if [[ $rsyslog_install != *No such* ]]; then
    systemctl is-enabled rsyslog >> temp.txt # enabled
    grep ^\$FileCreateMode /etc/rsyslog.conf >> temp.txt # 0640
    result=`cat temp.txt`
    [result -eq *enabled*0640*]
  else
    [ 1 -eq 1 ]
  fi
}

# CIS 5.1.1-7: Ensure permissions on /etc/cron._____ are configured
file_config_cron_boolean() {
  result=`stat $1`
  [ result -eq *0600*0/*root*0/*root* ]
}

@test "crontab config cron" { [file_config_cron_boolean /etc/crontab] }
@test "hourly config cron" { [file_config_cron_boolean /etc/cron.hourly] }
@test "daily config cron" { [file_config_cron_boolean /etc/cron.daily] }
@test "weekly config cron" { [file_config_cron_boolean /etc/cron.weekly] }
@test "monthly config cron" { [file_config_cron_boolean /etc/cron.monthly] }
@test "d config cron" { [file_config_cron_boolean /etc/cron.d] }

# CIS 5.2: SSH Server Configuration
@test "sshd file is set to presets" {
  perfect_sshd=`cat ./presets/perfect_sshd`
  result=`cat /etc/ssh/sshd_config`
  [ result -eq perfect_sshd]
}
