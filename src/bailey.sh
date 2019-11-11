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
readme_location=$dump/readme

# Logging
log() {
  echo $(date +%T): $1 >> $logfile
  echo $1
}

# Ensure the existence of the README
ensure_readme() {
  echo >> $readme_location
  if [ $(cat readme_location) -eq "" ]; then
    print "Please enter the URL of the README: "
    read readme_url
    curl -K $readme_url -o $readme_location
    echo $readme_location | head
    print "Does this look right? "
    read readme_is_correct
    if [ $readme_is_correct -ne y ]; then
      echo "Please enter the contents manually"
      gedit $readme_location
    fi
  fi
}

# CIS: Mozilla ##########################################################

# CIS: Mozilla Firefox 38
firefox_update_and_CIS() {
  killall firefox
  mv ~/.mozilla ~/.mozilla.old
  sudo apt install -y firefox
  killall firefox
  cat presets/syspref.js > /etc/firefox/syspref.js
  su -c 'firefox -new-tab about:config' $SUDO_USER
}

# NO CIS ################################################################

# Removing dirty packages for a safer system
purge_dirty_packages() {
  apt-get purge -y john* ophcrack minetest wireshark netcat* polari rpcbind transmission-gtk empathy mutt freeciv kismet hydra* nikto* squid minetest p0f minetest-server nmap* zenmap*
  apt-get autoclean
  apt-get autoremove
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
  if [[ $AIDE_dpkg == *not* ]]; then
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

# CIS 1.7.1.1: Ensure message of the day is configured properly
motd_configured_properly() {
  sed -i `s/\m//g` /etc/motd
  sed -i `s/\r//g` /etc/motd
  sed -i `s/\s//g` /etc/motd
  sed -i `s/\v//g` /etc/motd
}

# CIS 1.7.2: Ensure GDM login banner is configured
configure_gdm_login_banner() {
  echo -e "user-db:user\nsystem-db:dgm\nfile-db:/usr/share/greeter-dconf/defaults" > /etc/dconf/profile/gdm
  echo -e "[org/gnome-login-screen]\nbanner-message-enabled=true\nbanner-message-text='Authorized uses only. All activity may be monitored and reported'" > /etc/dconf/db/gdm.d/01-banner-message
  dconf update
}

# CIS 1.8: Ensure update, patches, and additional security software are installed
updates() {
  apt-get update && apt-get upgrade
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

# CIS 3.1.1: Ensure IP forwarding is disabled
disable_ip_forwarding() {
  sysctl -w net.ipv4.ip_forward=0
  sysctl -w net.ipv4.route.flush=1
}

# CIS 3.1.2: Ensure packet redirect sending is disabled
disable_packet_redirect() {
  sysctl -w net.ipv4.conf.all.send_redirects=0
  sysctl -w net.ipv4.conf.default.send_redirects=0
  sysctl -w net.ipv4.route.flush=1
}

# CIS: 3.2 ##############################################################

# CIS 3.2.1: Ensure source routed packets are not accepted
disable_accepting_routed_packets() {
  sysctl -w net.ipv4.conf.all.accept_source_route=0
  sysctl -w net.ipv4.conf.default.accept_source_route=0
  sysctl -w net.ipv4.route.flush=1
}

# CIS 3.2.2-3: Ensure ICMP redirects are not accepted
disable_accepting_of_ICMP_redirects() {
  sysctl -w net.ipv4.conf.all.accept_redirects=0
  sysctl -w net.ipv4.conf.default.accept_redirects=0
  sysctl -w net.ipv4.conf.all.secure_redirects=0
  sysctl -w net.ipv4.conf.default.secure_redirects=0
  sysctl -w net.ipv4.route.flush=1
}

# CIS 3.2.4: Ensure suspicious packets are logged
enable_logging_of_packets() {
  sysctl -w net.ipv4.conf.all.log_martians=1
  sysctl -w net.ipv4.conf.default.log_martians=1
  sysctl -w net.ipv4.route.flush=1
}

# CIS 3.2.5-6: Ensure ICMP requests are ignored
ignore_ICMP_requests() {
  sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
  sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
  sysctl -w net.ipv4.route.flush=1
}

# CIS 3.2.7: Ensure Reverse Path Filtering is enabled
enable_reverse_path_filtering() {
  sysctl -w net.ipv4.conf.all.rp_filter=1
  sysctl -w net.ipv4.conf.default.rp_filter=1
  sysctl -w net.ipv4.route.flush=1
}

# CIS 3.2.8: Ensure TCP SYN Cookies is enabled
enable_TCP_SYN_cookies() {
  sysctl -w net.ipv4.tcp_syncookies=1
  sysctl -w net.ipv4.route.flush=1
}

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

configuring_file_permissions_function() {
  chown root:$3 $1
  chmod $2 $1
}

etc_passwd_config() {configuring_file_permissions_function /etc/passwd 644 root}
etc_shadow_config() {configuring_file_permissions_function /etc/shadow o-rwx,g-wx shadow}
etc_group_config() {configuring_file_permissions_function /etc/group 644 root}
etc_gshadow_config() {configuring_file_permissions_function /etc/gshadow o-rwx,g-wx shadow}
etc_passwd_-_config() {configuring_file_permissions_function /etc/passwd- 600 root}
etc_shadow_-_config() {configuring_file_permissions_function /etc/shadow- 600 root}
etc_group_-_config() {configuring_file_permissions_function /etc/group- 600 root}
etc_gshadow_-_config() {configuring_file_permissions_function /etc/gshadow- 600 root}

configure_all_etc_files() {
  etc_passwd_config; etc_shadow_config; etc_group_config; etc_gshadow_config; etc_passwd_-_config; etc_shadow_-_config; etc_group_-_config; etc_gshadow_-_config
}

# CIS: 6.2 ##############################################################
# NON-CIS: README PARSING
ncis_readme_parsing() {
  # Makes a list of non-root users (users over 1000, should be all but `root`)
  cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1 > $dump/usersover1000
  echo root >> $dump/users_over_1000

  # Creates a list of authorized administrators from the README
  cat $dump/readme | sed -n '/Authorized Administrators/,/Authorized Users/p' > $dump/authorized_administrators
  # Creates list of current admin users by detecting users in group `sudo`
  cat /etc/group | grep sudo | cut -c 11- | tr , '\n' > $dump/admin_users

  # Creates list of users with UID 0
  cut -d: -f1,3 /etc/passwd | egrep ':0$' | cut -d: -f1 | grep -v root > $dump/0_uid_users
}

# CIS 6.2.1: Ensure password fields are not empty
password_fields_are_not_empty() {
  for user in `cat $dump/users_over_1000`; do
    echo -e "$stdpass\n$stdpass" | passwd $user
    echo "$user: $stdpass" >> $dump/changed_passwords
  done
}

# Comment out items that you do not want to be completed
firefox_update_and_CIS
purge_dirty_packages
all_filesystem_mounting_disabled
world_writable_sticky_bit
package_manager_repos_configured
install_AIDE
filesystem_integrity_checked
bootloader_permission_fix
bottloader_password_set
authentication_req_single_user_mode
restrict_core_dumps
enable_aslr
disable_prelink
enable_selinux_in_bootloader_configuration
enforcing_selinux_state
configure_selinux_policy
enable_apparmor_in_bootloader_configuration
enforce_apparmor_profiles
install_mac_systems
motd_configured_properly
configure_gdm_login_banner
updates
disable_inetd_services
disable_special_purpose_services
disable_ip_forwarding
disable_packet_redirect
disable_accepting_routed_packets
disable_accepting_of_ICMP_redirects
enable_logging_of_packets
ignore_ICMP_requests
enable_reverse_path_filtering
enable_TCP_SYN_cookies
enable_auditd
configure_rsyslog
configure_cron
configure_ssh
configure_all_etc_files
