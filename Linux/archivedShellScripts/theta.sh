#!/bin/bash

######        THETA.SH        ######
# Created by Abhinav V., Tavin T. #
#       For use in CPXI           #
# Based on gamma.sh and zeta.sh   #
#      Password: H3l!X?GoT3@m!    #
###################################

# Log file creation
mkdir thetalog
mkdir thetaoutput
logf=./thetalog/theta_$(date +%T).log
copydir=./thetaoutput

# Log to logfile
log() {
  echo $(date +%T): $1 >> $logf
}
# Echo to console and logfile
chirp() {
  echo "(^~^) $*"
  log "GOOD $*"
}
# Send warning and log
warn() {
  echo "(o-o) $*"
  log "WARN $*"
}
# Send fatal message to console and log
panic() {
  echo "(;-;) $*"
  log "PANIC $*"
}
# Chirp question, the read response and resolve as echo
ask() {
  chirp $*
  read resp
  if [ $resp = y ]; then
    return 0
  else
    return 1
  fi
}

# Ensure script is running as root
if [ $EUID -ne 0 ]; then
  panic "Must run script as root!"
  exit 1
fi

# Install script dependencies
chirp "Installing dependencies"
apt-get update
apt-get -y install gufw synaptic libpam-cracklib clamav gnome-system-tools auditd audispd-plugins rkhunter chkrootkit iptables curl unattended-upgrades openssl

# Update Firefox and remove legacy .mozilla files
chirp "Updating Firefox"
killall firefox
mv ~/.mozilla ~/.mozilla.old
apt-get --purge --reinstall install firefox
chirp "Firefox updated!"

# Enable rkhunter
rkhunter --update --propupd

# Configure hosts files
if [ -s /etc/hosts ]; then
  chirp "Copying hosts file for convenience"
  cp /etc/hosts $copydir/hosts
  echo 127.0.0.1    localhost > /etc/hosts
  echo 127.0.0.1    ubuntu >> /etc/hosts
  echo                     >> /etc/hosts
  echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
  echo ::1     ip6-localhost ip6-loopback >> /etc/hosts
  echo fe00::0 ip6-localnet >> /etc/hosts
  echo ff00::0 ip6-mcastprefix >> /etc/hosts
  echo ff02::1 ip6-allnodes >> /etc/hosts
  echo ff02::2 ip6-allrouters >> /etc/hosts
  chirp "Copied and cleansed hosts file"
fi

# Enable firewall
chirp "Enabling firewall"
ufw enable
chirp "Firewall enabled"

#Disables ctrl+alt+del
chirp "Disabling ctr+alt+del"
sed -i '/^exec*/ c\exec false' /etc/init/control-alt-delete.conf
chirp "Disabled ctr+alt=del"

# /etc/rc.local has to contain only exit 0
echo "exit 0" > /etc/rc.local
chirp "Set contents of /etc/rc.local to exit 0"

# Configure telnet
if  ask "Block and uninstall telnet? (y/n)" ; then
  ufw deny 23
  iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP
  apt-get purge telnet
  chirp "Removed telnet"
fi

# Enable auditing
chirp "Enabling auditing"
auditctl -e 1
chirp "Enabled auditing"

# Configure root password
chirp "Change the root password. Make sure you document it"
passwd root
chirp "Changed the root password."

# Configure cron to allow root access only
chirp Changing cron to only allow root access
crontab -r
rm -f /etc/cron.deny at.deny
echo root > /etc/cron.allow
echo root > /etc/at.allow
chown root:root /etc/cron.allow /etc/at.allow
chmod 644 /etc/cron.allow /etc/at.allow

# Disable guest account
chirp "Disabling the guest account"
echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf
echo "greeter-session=unity-greeter" >> /etc/lightdm/lightdm.conf
echo "user-session=ubuntu" >> /etc/lightdm/lightdm.conf
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
chirp "Disabled the guest account"

# Password policies
chirp "Enabling password policies"
sed -i '/pam_unix.so/ s/$/ remember=5 minlen=8/g' /etc/pam.d/common-password
sed -i '/pam_cracklib.so/ s/$/ ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/g' /etc/pam.d/common-password
sed -i '/PASS_MAX_DAYS/c\PASS_MAX_DAYS 90' /etc/login.defs
sed -i '/PASS_MIN_DAYS/c\PASS_MIN_DAYS 10' /etc/login.defs
sed -i '/PASS_WARN_AGE/c\PASS_WARN_AGE 7' /etc/login.defs

chirp "Removing Nullok"
sed -i 's/\<nullok_secure\>//g' /etc/pam.d/common-auth
sed -i 's/\<nullok\>//g' /etc/pam.d/common-auth
sed -i 's/\<nullok\>//g' /etc/pam.d/common-password
sed -i 's/\<nullok_secure\>//g' /etc/pam.d/common-password

# Network configuration
chirp "Securing network settings"
echo "nospoof on" >> /etc/host.conf
iptables -t nat -F
iptables -t mangle -F
iptables -t nat -X
iptables -t mangle -X
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -A INPUT -s 0.0.0.0/8 -j DROP
iptables -A INPUT -s 100.64.0.0/10 -j DROP
iptables -A INPUT -s 169.254.0.0/16 -j DROP
iptables -A INPUT -s 192.0.0.0/24 -j DROP
iptables -A INPUT -s 192.0.2.0/24 -j DROP
iptables -A INPUT -s 198.18.0.0/15 -j DROP
iptables -A INPUT -s 198.51.100.0/24 -j DROP
iptables -A INPUT -s 203.0.113.0/24 -j DROP
iptables -A INPUT -s 224.0.0.0/3 -j DROP
iptables -A INPUT -d 0.0.0.0/8 -j DROP
iptables -A INPUT -d 100.64.0.0/10 -j DROP
iptables -A INPUT -d 169.254.0.0/16 -j DROP
iptables -A INPUT -d 192.0.0.0/24 -j DROP
iptables -A INPUT -d 192.0.2.0/24 -j DROP
iptables -A INPUT -d 198.18.0.0/15 -j DROP
iptables -A INPUT -d 198.51.100.0/24 -j DROP
iptables -A INPUT -d 203.0.113.0/24 -j DROP
iptables -A INPUT -d 224.0.0.0/3 -j DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP         #Block Telnet
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP  #Block X-Windows
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP       #Block X-Windows font server
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
iptables -A INPUT -p all -s localhost  -i eth0 -j DROP            #Deny outside packets from internet which claim to be from your loopback interface.
iptables -A OUTPUT -d 0.0.0.0/8 -j DROP
iptables -A OUTPUT -d 100.64.0.0/10 -j DROP
iptables -A OUTPUT -d 169.254.0.0/16 -j DROP
iptables -A OUTPUT -d 192.0.0.0/24 -j DROP
iptables -A OUTPUT -d 192.0.2.0/24 -j DROP
iptables -A OUTPUT -d 198.18.0.0/15 -j DROP
iptables -A OUTPUT -d 198.51.100.0/24 -j DROP
iptables -A OUTPUT -d 203.0.113.0/24 -j DROP
iptables -A OUTPUT -d 224.0.0.0/3 -j DROP
iptables -A OUTPUT -s 0.0.0.0/8 -j DROP
iptables -A OUTPUT -s 100.64.0.0/10 -j DROP
iptables -A OUTPUT -s 169.254.0.0/16 -j DROP
iptables -A OUTPUT -s 192.0.0.0/24 -j DROP
iptables -A OUTPUT -s 192.0.2.0/24 -j DROP
iptables -A OUTPUT -s 198.18.0.0/15 -j DROP
iptables -A OUTPUT -s 198.51.100.0/24 -j DROP
iptables -A OUTPUT -s 203.0.113.0/24 -j DROP
iptables -A OUTPUT -s 224.0.0.0/3 -j DROP
iptables -A OUTPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -P OUTPUT DROP
iptables -P OUTPUT ACCEPT
ufw deny 2049
ufw deny 515
ufw deny 111
chirp "Secured a crap ton network settings"

# Auto updates
chirp "Enabling Auto Updates"
echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Download-Upgradeable-Packages "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::AutocleanInterval "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
sed -i '/xenial-backports/s/^/#/' /etc/apt/sources.list

chirp "Enabling password for secure boot"
sed -i 's/\/sbin\/sushell/\/sbin\/sulogin/g' /lib/systemd/system/emergency.service
sed -i 's/\/sbin\/sushell/\/sbin\/sulogin/g' /lib/systemd/system/rescue.service

chirp "Enabling password for grub boot loader"
passwordHash=$(echo -e 'H3l!X?GoT3@m!\nH3l!X?GoT3@m!' | grub-mkpasswd-pbkdf2 | cut -c 33-)
echo -e '\ncat <<EOF\nset superusers="Admin"\npassword_pbkdf2 Admin'$passwordHash'\nEOF' >> /etc/grub.d/00_header
update-grub
chown root:root /boot/grub/grub.cfg
chirp "Set password for grub boot loader. Username: Admin Password: H3l!X?GoT3@m!"

chirp "Disabling coredumps"
echo "* hard core 0" >> /etc/security/limits.conf
echo 'fs.suid_dumpable = 0' >> /etc/sysctl.conf
sysctl -p
echo 'ulimit -S -c 0 > /dev/null 2>&1' >> /etc/profile
chirp "Disabled coredumps"

chirp "Altering sysctl for security"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_synack_retries = 5" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rfc1337=1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.log_martians=1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_timestamps=0" >> /etc/sysctl.conf
echo "fs.protected_hardlinks=1" >> /etc/sysctl.conf
echo "fs.protected_symlinks=1" >> /etc/sysctl.conf
echo "kernel.randomize_va_space=2" >> /etc/sysctl.conf
echo "kernel.panic=10" >> /etc/sysctl.conf
echo "kernel.core_uses_pid = 1" >> /etc/sysctl.conf
echo "kernel.sysrq = 0" >> /etc/sysctl.conf
sysctl -p

mediawarrant() {
  chirp "Searching for $1 files out outputting to file for forensic question answers"
  find / -type f -not -iname 'CP*_Background*.png' -not -path '/*/.cache/*' -not -path '/usr/*' -not -path '/var/lib/app-info/icons/*' -not -path '/opt/*' -not -path '/lib/*' -name *.$1 -print 2> /dev/null > $copydir/$1\files
  for line in `cat $copydir/$1files`
  do
      ls -la $line >> $copydir/$1perms
  done
  xargs -d '\n' -a $copydir/$1\files rm -rf
}

mediawarrant png
mediawarrant jpg
mediawarrant mp4
mediawarrant mp3
mediawarrant mov
mediawarrant avi
mediawarrant mpg
mediawarrant mpeg
mediawarrant flac
mediawarrant m4a
mediawarrant flv
mediawarrant ogg
mediawarrant gif
mediawarrant jpeg

chirp "Moved media files to $copydir"

chirp "Copying & parsing README"
touch $copydir/readme
chmod 777 $copydir/readme

readmeurl=`cat /home/$SUDO_USER/Desktop/README.desktop | grep -o '".*"' | tr -d '"'`
curl $readmeurl > $copydir/readme

chirp "Checking and removing unauthorized users"

cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1 > $copydir/usersover1000
echo root >> $copydir/usersover1000
echo "" > $copydir/removedusers
for user in `cat $copydir/usersover1000`; do
	if [ $user = "root" ]; then
		chirp ROOT FOUND
	else
		cat $copydir/readme | grep ^$user
		if [ $? = 1 ]; then
			chirp "$user is unauthorized. Removing..."
			userdel $user
			echo "$user has been removed from the system" >> $copydir/removedusers
      chirp "$user has been removed from the system"
		fi
	fi
done
chirp "Removed unauthorized users"


chirp "Checking and removing unauthorized administrators"
cat $copydir/readme | sed -n '/Authorized Administrators/,/Authorized Users/p' > $copydir/authadmin
touch $copydir/adminusers
chmod 777 $copydir/adminusers
cat /etc/group | grep sudo | cut -c 11- | tr , '\n' > $copydir/adminusers
echo "" > $copydir/demotedadmins
chmod 777 $copydir/demotedadmins
for user in `cat $copydir/adminusers`; do
	cat $copydir/authadmin | grep ^$user
	if [ $? = "1" ]; then
		chirp $user is not supposed to be an admin. Demoting $user
		deluser $user sudo
		echo The admin privileges of $user has been revoked >> $copydir/demotedadmins
    chirp The admin privileges of $user has been revoked
	fi
done
chirp "Removed unauthorized admins"

chirp "Changing passwords of all administrators"
cat $copydir/readme | sed -n '/Authorized Administrators/,/Authorized Users/p' > $copydir/authadminpass
touch $copydir/adminuserspass
chmod 777 $copydir/adminuserspass
cat /etc/group | grep sudo | cut -c 11- | tr , '\n' | sed "s/\<${SUDO_USER}\>//g" > $copydir/adminuserspass
for user in `cat $copydir/adminuserspass`; do
  echo -e "H3l!X?GoT3@m!\nH3l!X?GoT3@m!" | passwd $user
  echo "$user: H3l!X?GoT3@m!" >> $copydir/changedpasswords
done
chirp "Changed admin passwords"

# Checking for any user who has a UID of 0 and is not a root and removing
chirp Checking for 0 UID users other than root and removing
touch $copydir/zerouidusers
touch $copydir/uidusers

cut -d: -f1,3 /etc/passwd | egrep ':0$' | cut -d: -f1 | grep -v root > $copydir/zerouidusers
if [ -s /zerouidusers ]
	then
		echo "Found 0 UID. Fixing now."

		while IFS='' read -r line || [[ -n "$line" ]]; do
			thing=1
			while true; do
				rand=$((RANDOM%999+1000))
				cut -d: -f1,3 /etc/passwd | egrep ":$rand$" | cut -d: -f1 > /uidusers
				if [ -s /uidusers ]
				then
					echo "Couldn't find unused UID. Trying Again..."
          continue
				else
					break
				fi
			done
			usermod -u $rand -g $rand -o $line
			touch /tmp/oldstring
			old=$(grep "$line" /etc/passwd)
			echo $old > /tmp/oldstring
			sed -i "s~0:0~$rand:$rand~" /tmp/oldstring
			new=$(cat /tmp/oldstring)
			sed -i "s~$old~$new~" /etc/passwd
			chirp "ZeroUID User: $line"
			chirp "Assigned UID: $rand"
		done < "/zerouidusers"
		cut -d: -f1,3 /etc/passwd | egrep ':0$' | cut -d: -f1 | grep -v root > /zerouidusers

		if [ -s /zerouidusers ]
		then
			echo "WARNING: UID CHANGE UNSUCCESSFUL!"
		else
			echo "Successfully Changed Zero UIDs!"
		fi
	else
		echo "No Zero UID Users"
	fi

chirp "Evaluating compulsory status of pure-ftpd"
cat $copydir/readme | grep -w 'pure-ftpd'
if [ $? = 0 ]; then
  apt-get install -y pure-ftpd
  mkdir /etc/ssl/private
  openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem -days 365 -subj "/C=US/ST=Colorado/L=Denver/O=Team Helix/OU=Linux Department/CN=teamhelix.me"
  echo "2" > /etc/pure-ftpd/conf/TLS
  service pure-ftpd start
  service pure-ftpd restart
  chirp "Installed and secured pure-ftpd"
else
  apt-get purge -y pure-ftpd
  apt-get autoremove
  chirp "Removed pure-ftpd as not required"
fi

if ask "Secure VSFTP, if installed? (y/n)" ; then
  # Disable anonymous uploads
  sed -i '/^anon_upload_enable/ c\anon_upload_enable no' /etc/vsftpd.conf
  sed -i '/^anonymous_enable/ c\anonymous_enable=NO' /etc/vsftpd.conf
  # FTP user directories use chroot
  sed -i '/^chroot_local_user/ c\chroot_local_user=YES' /etc/vsftpd.conf
  service vsftpd restart
fi

if  ask "Remove other FTP services? (y/n)" ; then
  apt-get purge -y samba vsftpd
  chirp "Removed FTP services"
fi

if ask "Secure MySQL, if installed, otherwise remove? (y/n)"; then
  # Disable remote access
  sed -i '/bind-address/ c\bind-address = 127.0.0.1' /etc/mysql/my.cnf
  service mysql restart
else
  apt-get purge -y mysql*
fi

if ask "Secure Apache2, if installed, otherwise remove? (y/n)"; then
  a2enmod userdir

	chown -R root:root /etc/apache2
	chown -R root:root /etc/apache
	echo "<Directory />" >> /etc/apache2/apache2.conf
	echo "        AllowOverride None" >> /etc/apache2/apache2.conf
	echo "        Order Deny,Allow" >> /etc/apache2/apache2.conf
	echo "        Deny from all" >> /etc/apache2/apache2.conf
	echo "</Directory>" >> /etc/apache2/apache2.conf
	echo "UserDir disabled root" >> /etc/apache2/apache2.conf

  service apache2 restart
else
  apt-get purge -y apache2
fi

chirp "Evaluating compulsory status of SSHD"
cat $copydir/readme | grep -w 'ssh\|SSH'
if [ $? = 0 ]; then
    apt-get install -y openssh-server
    sed -i 's/PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/Protocol.*/Protocol 2/g' /etc/ssh/sshd_config
    sed -i 's/X11Forwarding.*/X11Forwarding no/g' /etc/ssh/sshd_config
    sed -i 's/PermitEmptyPasswords.*/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
    service sshd start
    service sshd restart
    chirp "Installed and secured SSH"
else
    apt-get purge -y openssh-server
    apt-get autoremove
    chirp "Removed SSH as not required"
fi

apt-get purge john* ophcrack minetest nmap wireshark netcat* polari rpcbind transmission-gtk empathy mutt freeciv kismet hydra* nikto* xinetd 

# Services
echo "Here are all the different services running on the computer." >> $copydir/services
echo -e "\n\n\n Lsof command: " >> $copydir/services
lsof -i -n -P >> $copydir/services
echo -e "\n\n\n Netstat command: " >> $copydir/services
netstat -tulpn >> $copydir/services
echo -e "\n\n\n Service command: " >> $copydir/services
service --status-all >> $copydir/services
echo -e "\n\n\n Ports that are open: " >> $copydir/services
ss -ln >> $copydir/services

chirp "Outputted all services running on the computer to a file"

apt-get autoremove
apt-get update
apt-get upgrade

clear

chirp "Make sure to do sudo visudo and make sure NOPASSWD is not there."
chirp "Zeta has completed its runtime. Please evaluate the contents of the Software Center Installed page and run rkhunter. Restart all instances of Firefox and ensure that it is on the most recent version."
chirp "Good luck on the rest of the round!"
