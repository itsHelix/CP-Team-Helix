#!/bin/bash

# General user password is H3l!X?GoT3@m!


echo YOU ARE RUNNING ZETA. EXIT IMMEDIATELY BEFORE IT SCREWS UP THE IMAGE
read garbage
rundate=$(date +%T)
mkdir /zeta/
mkdir /zeta/logs/
mkdir /zeta/copied/
copydir=/zeta/copied/
touch /zeta/logs/${rundate}.log
logfile=/zeta/logs/${rundate}.log

log() {
  echo $(date): $1 >> ${logfile}
}
ltc() {
  echo \(0_0\) $1
  log $1
}
ask() {
  echo \(o.o\) $1
  read resp
  local res=resp
}
warn() {
  echo \(._.\) $1
  log $1
}
panic() {
  echo \(;_;\) $1
  log $1
  exit 1
}

if [ $EUID -ne 0 ]; then
  panic "Must run script as root administrator (sudo)!"
  exit 1
fi

ltc "Installing script dependencies"

apt-get update
apt-get -y install gufw synaptic libpan-crakclib clamav gnome-system-tools auditd audispd-plugins rkhunter chkrootkit iptables curl unattended-upgrades

ltc "Updating Firefox to latest version"
ps ax | grep [f]irefox
killall firefox
mv ~/.mozilla ~/.mozilla.old
apt-get --purge --reinstall install firefox
ltc "Firefox has been upgraded"

rkhunter --update
rkhunter --propupd

ltc "Remember to check the log file at ${logfile} if you run into any trouble! [Enter to continue]"
read garbage

if [ -s /etc/hosts ]; then
  ltc "Copying hosts file for easier access"
  cp /etc/hosts/ $copydir/hosts
  echo 127.0.0.1    localhost > /etc/hosts
  echo 127.0.0.1    ubuntu >> /etc/hosts
  echo                     >> /etc/hosts
  echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
  echo ::1     ip6-localhost ip6-loopback >> /etc/hosts
  echo fe00::0 ip6-localnet >> /etc/hosts
  echo ff00::0 ip6-mcastprefix >> /etc/hosts
  echo ff02::1 ip6-allnodes >> /etc/hosts
  echo ff02::2 ip6-allrouters >> /etc/hosts
  log "Copied and cleansed hosts file"
fi

ltc "Enabling firewall"
ufw enable
ltc "Enabled firewall"

if [ ask "Block and uninstall telnet [firewall]? (y/n)" = y ]; then
  ufw deny 23
  iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP
  apt-get purge telnet
  ltc "Removed telnet"
fi

ltc "Using the magic of iptables to block NFS & friends"
ufw deny 2049,111,515
iptables -A INPUT -p all -s 0/0 -d 0/0 -dport 2049,6000:6009,7100,515,111 -j DROP # (in order) block NFS, X-Windows, X-Windows font server, printer port, Sun rpc/NFS
iptables -A INPUT -p all -s localhost -i eth0 -j DROP # deny fraudulent loopback packets

ltc "Used iptables to block services like NFS and certain ports"

ltc "Enabling auditing"
auditctl -e 1
ltc "Enabled auditing"

if [ ask "Do you want to lock the password of the root account? (y/n)" = y ]; then
  passwd -l root
  ltc "Locked the root account"
fi

ltc "Disabling the guest account"
echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf
echo "greeter-session=unity-greeter" >> /etc/lightdm/lightdm.conf
echo "user-session=ubuntu" >> /etc/lightdm/lightdm.conf
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
ltc "Disabled the guest account"

ltc "Enabling password policies"

sed -i '/pam_unix.so/ s/$/ remember=5 minlen=8/g' /etc/pam.d/common-password
sed -i '/pam_cracklib.so/ s/$/ ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/g' /etc/pam.d/common-password
sed -i '/PASS_MAX_DAYS/c\PASS_MAX_DAYS 90' /etc/login.defs
sed -i '/PASS_MIN_DAYS/c\PASS_MIN_DAYS 10' /etc/login.defs
sed -i '/PASS_WARN_AGE/c\PASS_WARN_AGE 7' /etc/login.defs

ltc "Securing network settings"
chmod 777 /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
chmod 644 /etc/sysctl.conf
chmod 777 /etc/host.conf
echo "nospoof on" >> /etc/host.conf
chmod 644 /etc/host.conf
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.tcp_timestamps=0
sysctl -p
ltc "Secured some network settings"

ltc "Enabling Auto Updates"
echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Download-Upgradeable-Packages "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::AutocleanInterval "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
sed -i '/xenial-backports/s/^/#/' /etc/apt/sources.list

echo "Here are all the different services running on the computer." >> $copydir/services
echo "\n\n\n Lsof command: " >> $copydir/services
lsof -i -n -P >> $copydir/services
echo "\n\n\n Netstat command: " >> $copydir/services
netstat -tulpn >> $copydir/services
echo "\n\n\n Service command: " >> $copydir/services
service --status-all >> $copydir/services
echo "\n\n\n Ports that are open: " >> $copydir/services
ss -ln >> $copydir/services

ltc "Outputted all services running on the computer to a file"

mediawarrant() {
  ltc "Searching for $0 files out outputting to file for forensic question answers"
  sudo find / -type f -not -iname 'CP*_Background*.png' -not -path '/*/.cache/*' -not -path '/usr/*' -not -path '/var/lib/app-info/icons/*' -not -path '/opt/*' -not -path '/lib/*' -name *.$0 -print 2> /dev/null > $copydir/$0files
  for line in `cat $copydir/$0files`
  do
      ls -la $line >> $copydir/$0perms
  done
  xargs -d '\n' -a $copydir/$0files rm -rf
}

mediawarrant png
mediawarrant jpg
mediawarrant mp4
mediawarrant mp3
ltc "Moved media files to $copydir"

ltc "Copying & parsing README"
touch $copydir/readme
chmod 777 $copydir/readme

readmeurl=`cat /home/$SUDO_USER/Desktop/README.desktop | grep -o '".*"' | tr -d '"'`
curl readmeurl > $copydir/readme

ltc "Checking and removing unauthorized users"

cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1 > $copydir/usersover1000
echo root >> $copydir/usersover1000
echo "" > $copydir/removedusers
for user in `cat $copydir/usersover1000`; do
	if [ $user = "root" ]; then
		ltc ROOT FOUND
	else
		cat $copydir/readme | grep ^$user
		if [ $? = 1 ]; then
			ltc "$user is unauthorized. Removing..."
			userdel $user
			echo "$user has been removed from the system" >> $copydir/removedusers
		fi
	fi
done
ltc "Removed unauthorized users"


ltc "Checking and removing unauthorized administrators"
cat $copydir/readme | sed -n '/Authorized Administrators/,/Authorized Users/p' > $copydir/authadmin
touch $copydir/adminusers
chmod 777 $copydir/adminusers
cat /etc/group | grep sudo | cut -c 11- | tr , '\n' > $copydir/adminusers
echo "" > $copydir/demotedadmins
chmod 777 $copydir/demotedadmins
for user in `cat $copydir/adminusers`; do
	cat $copydir/authamdin | grep ^$user
	if [ $? = "1" ]; then
		ltc $user is not supposed to be an admin. Demoting $user
		deluser $user sudo
		echo The admin privileges of $user has been revoked >> $copydir/demotedadmins
	fi
done
ltc "Removed unauthorized admins"

ltc "Checking and removing unauthorized admins"
cat $copydir/readme | sed -n '/Authorized Administrators/,/Authorized Users/p' > $copydir/authadmin
touch $copydir/adminusers
chmod 777 $copydir/adminusers
cat /etc/group | grep sudo | cut -c 11- | tr , '\n' > $copydir/adminusers
touch $copydir/demotedadmins
chmod 777 $copydir/demotedadmins
for user in `cat $copydir/adminusers`; do
	cat $copydir/authadmin | grep ^$user
	if [ $? = "1" ]; then
		echo $user is not supposed to be an admin. Demoting $user
		deluser $user sudo
		echo The admin privileges of $user has been revoked >> $copydir/demotedadmins
	fi
done
ltc "Removed unauthorized admins"

ltc "Changing passwords of all administrators"
cat $copydir/readme | sed -n '/Authorized Administrators/,/Authorized Users/p' > $copydir/authadminpass
touch $copydir/adminuserspass
chmod 777 $copydir/adminuserspass
cat /etc/group | grep sudo | cut -c 11- | tr , '\n' | sed "s/\<${SUDO_USER}\>//g" > $copydir/adminuserspass
for user in `cat $copydir/adminuserspass`; do
  echo -e "H3l!X?GoT3@m!\nH3l!X?GoT3@m!" | passwd $user
  echo "$user: H3l!X?GoT3@m!" >> $copydir/changedpasswords
done
ltc "Changed admin passwords"

if [ ask "Remove FTP services? (y/n)" = y ];
then
    apt-get purge -y samba
    apt-get purge -y pure-ftpd
    apt-get purge -y *ftp*
    ltc "Removed FTP services"
fi

ltc "Evaluating compulsory status of SSHD"
cat $copydir/readme | grep -w 'ssh\|SSH'
if [ $? = 0 ]; then
    apt-get install -y openssh-server
    sed -i 's/PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/Protocol.*/Protocol 2/g' /etc/ssh/sshd_config
    sed -i 's/X11Forwarding.*/X11Forwarding no/g' /etc/ssh/sshd_config
    sed -i 's/PermitEmptyPasswords.*/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
    service sshd start
    service sshd restart
    ltc "Installed and secured SSH"
else
    apt-get purge -y openssh-server
    apt-get autoremove
fi

apt-get purge john* ophcrack minetest nmap wireshark apache2 ftp netcat* polari rpcbind transmission-gtk empathy mutt freeciv kismet⁠

apt-get autoremove
apt-get update
apt-get upgrade

clear

ltc "Zeta has completed its runtime. Please evaluate the contents of the Software Center Installed page and run rkhunter. Restart all instances of Firefox and ensure that it is on the most recent version."
ltc "Good luck on the rest of the round!"
