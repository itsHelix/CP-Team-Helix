#!/bin/sh

# Setup pause function
function pause(){
   read -p "$*"
}

# Ensure script is running as root
if [[ $EUID -ne 0 ]]; then
  pause 'Press [Enter] key to elavate Bailey...'
  su -
else
  pause 'You are running Bailey as root. Press [Enter] key to start Bailey...'
fi

# Script Utilities
mkdir bailey bailey/log bailey/dump
logfile=./bailey/log/bailey_$(date +%T).log
dump=./bailey/dump
stdpass="Spo0key_Scar3y"

# Logging
log() {
  echo $(date +%T): $1 >> $logfile
  echo $1
}

# CIS: Mozilla ##############################################################

# CIS: Mozilla Firefox 38
firefox_update_and_CIS() {
  killall firefox
  mv ~/.mozilla ~/.mozilla.old
  sudo apt install -y firefox
  killall firefox
  cat presets/syspref.js > /etc/firefox/syspref.js
  su -c 'firefox -new-tab about:config' $SUDO_USER
}

# CIS: 1.1 ##############################################################

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

# CIS: 1.2 ##############################################################

# CIS 1.2.1: Ensure package manager repositories are configured
package_manager_repos_configured() {
  # Var setup
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
  sudo apt-get update
}

# CIS: 1.3 ##############################################################

# CIS 1.3.1: Ensure AIDE is installed
install_AIDE() {
  # Var setup
  AIDE_dpkg=`dpkg -s aide`

  # Installing AIDE if it is not installed
  if [[ $AIDE_dpkg == * not * ]]; then
    apt-get install aide
    aide --init
  else
    echo "AIDE already installed"
  fi
}

# CIS 1.3.2: Ensure filesystem integrity is regularly checked
filesystem_integrity_checked() {
  # Var setup
  crontab=`cat /etc/crontab`

  # Setting up crontab for checking filesystem
  if [[ $crontab != */usr/bin/aide* ]]; then
    echo -e "0 5\t* * *\troot\t/usr/bin/aide -- check" >> /etc/crontab
  else
    echo "Filesystem integrity is already regularly being checked"
  fi
}

# CIS: 1.4 ##############################################################

# CIS 1.4.1: Ensure permissions on bootloader config are configured
bootloader_permission_fix() {
  # Var setup
  grub_access=`stat /boot/gub/grub.cfg | grep -i "access: (" | grep -o "(.*)" | sed 's/"//g'`

  if [[ $grub_access != *0600* ]]; then
    chown root:root /boot/grub/grub.cfg
    chmod og-rwx /boot/grub/grub.cfg
  else
    echo "Grub access set correctly"
  fi
}

# CIS 1.4.2: Ensure bootloader password is set
bottloader_password_set() {
  # Var setup
  passwordHash=`echo -e "$stdpass\n$stdpass" | grub-mkpasswd-pbkdf2 | grep -o "grub.*"`

  # Changing password
  echo -e '\ncat <<EOF\nset superusers="Admin"\npassword_pbkdf2 Admin'$passwordHash'\nEOF' >> /etc/grub.d/00_header

  # Updating grub configuration
  update-grub
}

# CIS 1.4.3: Ensure authentication required for single user mode
authentication_req_single_user_mode() {
  # Var setup
  rootpsw=`grep ^root:[*\!]: /etc/shadow`

  # Changing password
  if [[ $rootpsw != "" ]]; then
    echo -e "$stdpass\n$stdpass" | passwd root
  else
    echo "Root password already set"
  fi
}

# CIS: 1.5 ##############################################################

# CIS 1.5.1: Ensure core dumps are restricted
restrict_core_dumps() {
  echo "* hard core 0" | tee -a /etc/security/limits.conf /etc/sysctl.d/*
  echo "fs.suid_dumpable = 0" | tee -a /etc/sysctl.conf /etc/sysctl.d/*
  sysctl -w fs.suid_dumpable=0
}

# CIS 1.5.3: Ensure address space layour randomization (ASLR) is enabled
enable_aslr() {
  echo "kernel.randomize_va_space = 2" | tee -a /etc/sysctl.conf /etc/sysctl.d/*
  sysctl -w kernel.randomize_va_space=2
}

# CIS 1.5.4: Ensure prelink is disabled
disable_prelink() {
  prelink -ua
  apt-get remove prelink
}

# CIS: 1.6 ##############################################################

# CIS 1.6.1: Configure SELinux

# CIS 1.6.1.1: Ensure SELinux is not disabled in bootloader configuration
enable_selinux_in_bootloader_configuration() {
  sed -i `s/selinux=0//g` /etc/default/grub
  sed -i `s/enforcing=0//g` /etc/default/grub
  echo -e "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"\nGRUB_CMDLINE_LINUX=\"\"" >> /etc/default/grub
  update-grub
}

# CIS 1.6.1.2: Ensure the SELinux state is enforcing
enforcing_selinux_state() {
  echo "SELINUX=enforcing" >> /etc/selinux/config
}

# CIS 1.6.1.3: Ensure SELinux policy is configured
configure_selinux_policy() {
  echo "SELINUXTYPE=ubuntu" >> /etc/selinux/config
}

# CIS 1.6.2: Configure AppArmor

# CIS 1.6.2.1: Ensure AppArmor is not disabled in bootloader configuration
enable_apparmor_in_bootloader_configuration() {
  sed -i `s/apparmor=0//g` /etc/default/grub
  echo -e "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"\nGRUB_CMDLINE_LINUX=\"\"" >> /etc/default/grub
  update-grub
}

# CIS 1.6.2.2: Ensure all AppArmor Profiles are enforcing
enforce_apparmor_profiles() {
  aa-enforcce /etc/apparmor.d/*
}

# CIS 1.6.3: Ensure SELinux or AppArmor are installed
install_mac_systems() {
  apt-get install selinux apparmor
}

# CIS: 1.7 ##############################################################

# CIS 1.7.1: Command line warning banners

# CIS 1.7.1.1: Ensure message of the day is configured properly
motd_configured_properly() {
  sed -i `s/\m//g` /etc/motd
  sed -i `s/\r//g` /etc/motd
  sed -i `s/\s//g` /etc/motd
  sed -i `s/\v//g` /etc/motd
}

# CIS: 2.1 ##############################################################

# CIS 2.1 inetd Services:
disable_inetd_services() {
  # Var setup
  services=("chargen" "daytime" "discard" "echo" "time" "rsh" "rlogin" "rexec" "talk" "ntalk" "telnet" "tftp" "xinetd")
  services_comma=`printf "%s," "${services[@]}" | cut -d "," -f 1-${#services[@]}`

  # Disabling services in array
  systemctl disable xinetd
  for (i in "${services[@]}"); do
    update-inetd --disable "$i"
  done
  update-inetd --multi --remove [$services_comma]
}

# CIS: 2.2 ##############################################################

# CIS 2.2.2-17 (not including 2.2.15): Special Purpose Services
disable_special_purpose_services() {
  services=("avahi-daemon" "cups" "isc-dhcp-server6" "isc-dhcp-server" "slapd" "rpcbind" "nfs-kernel-server" "bind9" "vsftpd" "apache2" "dovecot" "smbd" "squid" "snmpd" "rsync" "nis")
  # apt-get remove xserver-xorg* # X Window System (commented out becuase unless you don't want a gui, you need this)
  for (i in "${services[@]}"); do
    systemctl disable "$i"
  done
}

# CIS: 3.1 ##############################################################




# CIS: 4.1 ##############################################################

# CIS 4.1.2: Ensure auditd service is enabled
enable_auditd() {
  systemctl enable auditd
}

# CIS: 4.2 ##############################################################

# CIS: 4.2.1 Configure rsyslog

configure_rsyslog() {
  rsyslog_install=`systemctl is-enabled rsyslog`
  rsyslog_FCM=`grep ^\$FileCreateMode /etc/rsyslog.conf`

  if [[ $rsyslog_install != *No such* ]]; then
    systemctl enable rsyslog # Making sure the rsyslog ser. is enabled (4.2.1.1)
    sed -i 's/$rsyslog_FCM/$FileCreateMode 0640/g' /etc/rsyslog.conf # Ensure rsyslog default file permissions configured (4.2.1.3)

  else
    echo "Rsyslog is not installed"
  fi
}

# CIS: 5.1 ##############################################################

file_config_cron() {
  chown root:root $1
  chmod og-rwx $1
}

crontab_config_cron() { file_config_cron /etc/crontab }
hourly_config_cron() { file_config_cron /etc/cron.hourly }
daily_config_cron() { file_config_cron /etc/cron.daily }
weekly_config_cron() { file_config_cron /etc/cron.weekly }
monthly_config_cron() { file_config_cron /etc/cron.monthly }
d_config_cron() { file_config_cron /etc/cron.d }

configure_cron() {
  crontab_config_cron; hourly_config_cron; daily_config_cron; weekly_config_cron; monthly_config_cron; d_config_cron
  systemctl enable crond
}

# CIS: 5.2 ##############################################################

configure_ssh() {
  chmod 777 /etc/ssh/sshd_config
  cat ./presets/perfect_sshd > /etc/ssh/sshd_config
  chmod 644 /etc/ssh/sshd_config
  service sshd reload
}

# CIS: 6.1 ##############################################################

configuring_file_permissions() {
  chown root:$3 $1
  chmod $2 $1
}

passwd_config() {configuring_file_permissions /etc/passwd 644 root}
shadow_config() {configuring_file_permissions /etc/shadow o-rwx,g-wx shadow}
group_config() {configuring_file_permissions /etc/group 644 root}
gshadow_config() {configuring_file_permissions /etc/gshadow o-rwx,g-wx shadow}
passwd-_config() {configuring_file_permissions /etc/passwd- 600 root}
shadow-_config() {configuring_file_permissions /etc/shadow- 600 root}
group-_config() {configuring_file_permissions /etc/group- 600 root}
gshadow-_config() {configuring_file_permissions /etc/gshadow- 600 root}
