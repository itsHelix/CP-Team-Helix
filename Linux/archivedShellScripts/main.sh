#!/bin/bash

# Script based on Abhi's script from last year written by Abhi

echo "You are running Main.sh which is the script with 30 char passwords"
rundate=$(date +%T)
touch /home/$SUDO_USER/Documents/loggy-${rundate}.log
loggyfile=/home/$SUDO_USER/Documents/loggy-${rundate}.log

logtologgy()
{
    echo $(date): $0 >> "${loggyfile}"
}

generatepassword() {
    local password=head /dev/urandom | tr -dc '[:graph:]' | fold -w16 | sed '$d' | shuf -n1
}

echo c[_] Are you running this as root?

if [ $EUID -ne 0 ]
then 
    echo c[_] You ain\'t running this as root?!? RUN AS ROOT!!!
    logtologgy "Script was not run as root"
    exit 1
fi


echo c[_] Installing useful stuff
apt-get update
apt-get -y install gufw
apt-get -y install synaptic
apt-get -y install libpam-cracklib
apt-get -y install clamav
apt-get -y install gnome-system-tools
apt-get -y install auditd audispd-plugins
apt-get -y install rkhunter
apt-get -y install chkrootkit
apt-get -y install iptables
apt-get -y install curl
rkhunter --update
rkhunter --propupd
echo c[_] Make sure you check the Loggy file that is created.
echo c[_] Updates will be installed at the end. I tell you then again. Keep this in mind and press enter
read blah

if [ -s /etc/hosts ]
then
    echo c[_] Copying hosts file for easier access
    cp /etc/hosts /home/$SUDO_USER/Documents/originalHostsFile.txt
    echo 127.0.0.1    localhost > /etc/hosts
    echo 127.0.1.1	   ubuntu >> /etc/hosts
    echo      >> /etc/hosts
    echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
    echo ::1     ip6-localhost ip6-loopback >> /etc/hosts
    echo fe00::0 ip6-localnet >> /etc/hosts
    echo ff00::0 ip6-mcastprefix >> /etc/hosts
    echo ff02::1 ip6-allnodes >> /etc/hosts
    echo ff02::2 ip6-allrouters >> /etc/hosts
    logtologgy "Copied Hosts file, and cleansed it"
fi

echo c[_] Enabling firewall
 ufw enable
logtologgy "Enabled firewall"

echo c[_] "Do you want block telnet from firewall and uninstall it? (y/n)"
read telnet
if [ $telnet = y ]
then
   ufw deny 23
   iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP
   apt-get purge telnet
  logtologgy "Removed telnet"
fi

echo c[_] Do you want to secure SSH

echo c[_] Using iptables to block tons of services like NFS.
 ufw deny 2049
 ufw deny 111
 ufw deny 515
 iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
 iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
 iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP  #Block X-Windows
 iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP       #Block X-Windows font server
 iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
 iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
 iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
 iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
 iptables -A INPUT -p all -s localhost -i eth0 -j DROP 		  #Deny outside packets from internet which claim to be from your loopback interface.
logtologgy "Used iptables to block services like NFS and certain ports"

echo c[_] Enabling auditing
 auditctl -e 1
logtologgy "Enabled auditing"

echo c[_] "Do you want to lock the password of the root account? (y/n)"
read lock
if [ $lock = y ]
then
     passwd -l root
    logtologgy "Locked the root account"
fi

echo c[_] Disabling the guest account
echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf
echo "greeter-session=unity-greeter" >> /etc/lightdm/lightdm.conf
echo "user-session=ubuntu" >> /etc/lightdm/lightdm.conf
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
logtologgy "Disabled the Guest account"

echo c[_] Enabling Password policies and Account policies. Press enter
read blah

sed -i '/pam_unix.so/ s/$/ remember=5 minlen=8/g' /etc/pam.d/common-password
sed -i '/pam_cracklib.so/ s/$/ ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/g' /etc/pam.d/common-password
sed -i '/PASS_MAX_DAYS/c\PASS_MAX_DAYS 90' /etc/login.defs
sed -i '/PASS_MIN_DAYS/c\PASS_MIN_DAYS 10' /etc/login.defs
sed -i '/PASS_WARN_AGE/c\PASS_WARN_AGE 7' /etc/login.defs
echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800" >> /etc/pam.d/common-auth

echo c[_] Securing network settings like disabling ipv6. Apparently it can be a security issue.
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
logtologgy "Secured a few network settings. No big deal"

echo "Here are all the different services running on the computer." >> services.txt
echo "Lsof command: " >> services.txt
lsof -i -n -P >> services.txt
echo " "
echo " "
echo " "
echo "Netstat command: " >> services.txt
netstat -tulpn >> services.txt
echo " "
echo " "
echo " "
echo "Service command: " >> services.txt
service --status-all >> services.txt
echo " "
echo " "
echo " "
echo "Ports that are open: " >> services.txt
ss -ln >> services.txt
logtologgy "Outputted all the services running on the computer to a file."

echo c[_] Searching for PNG files and outputting them to a file for forensic question answers. If blank, then no PNGs were found. Press enter.
read enter
sudo find / -type f -not -iname 'CP*_Background*.png' -not -path '/*/.cache/*' -not -path '/usr/*' -not -path '/var/lib/app-info/icons/*' -not -path '/opt/*' -not -path '/lib/*' -name *.png -print 2> /dev/null > pngfiles.txt
for line in `cat pngfiles.txt`
do
    ls -la $line >> pngPerms.txt
done
xargs -d '\n' -a pngfiles.txt rm -rf

echo c[_] Searching for JPG files and outputting them to a file for forensic question answers. If blank, then no JPGs were found. Press enter.
read enter
sudo find / -type f -not -iname 'CP*_Background*.png' -not -path '/*/.cache/*' -not -path '/usr/*' -not -path '/var/lib/app-info/icons/*' -not -path '/opt/*' -not -path '/lib/*' -name *.jpg -print 2> /dev/null > jpgfiles.txt
for line in `cat jpgfiles.txt`
do
    ls -la $line >> jpgPerms.txt
done
xargs -d '\n' -a jpgfiles.txt rm -rf

echo c[_] Searching for MP4 files and outputting them to a file for forensic question answers. If blank, then no MP4s were found. Press enter.
read enter
sudo find / -type f -not -iname 'CP*_Background*.png' -not -path '/*/.cache/*' -not -path '/usr/*' -not -path '/var/lib/app-info/icons/*' -not -path '/opt/*' -not -path '/lib/*' -name *.mp4 -print 2> /dev/null > mp4files.txt
for line in `cat mp4files.txt`
do
    ls -la $line >> mp4Perms.txt
done
xargs -d '\n' -a mp4files.txt rm -rf

echo c[_] Searching for MP3 files and outputting them to a file for forensic question answers. If blank, then no MP3s were found. Press enter.
read enter
sudo find / -type f -not -iname 'CP*_Background*.png' -not -path '/*/.cache/*' -not -path '/usr/*' -not -path '/var/lib/app-info/icons/*' -not -path '/opt/*' -not -path '/lib/*' -name *.mp3 -print 2> /dev/null > mp3files.txt
for line in `cat mp3files.txt`
do
    ls -la $line >> mp3Perms.txt
done
xargs -d '\n' -a mp3files.txt rm -rf
logtologgy "Removed media files if found but also put the directory paths in a file"

echo c[_] Go to Settings and set the system to check for updates daily and to install security updates. Press any key to continue
gnome-control-center
read key

echo c[_] Getting the README file and parsing it.
touch readmeHTML.txt
chmod 777 readmeHTML.txt

curl `cat /home/$SUDO_USER/Desktop/README.desktop | grep -o '".*"' | tr -d '"'` > readmeHTML.txt

echo c[_] Checking and removing unauthorized users.
cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1 > usersover1000
echo root >> usersover1000
echo "" > removedUsers.txt
for user in `cat usersover1000`
do
	if [ $user = "root" ]; then   
		echo ROOT FOUND
	else
		cat readmeHTML.txt | grep ^$user
		if [ $? = 1 ]; then 
			echo $user is unauthorized. Removing...
			userdel $user
			echo "$user has been removed from the system" >> removedUsers.txt
		fi
	fi
done
logtologgy "Removed unauthorized users."

echo c[_] Checking and removing unauthorized administrators.
cat readmeHTML.txt | sed -n '/Authorized Administrators/,/Authorized Users/p' > authAdmin.txt
touch adminUsers.txt
chmod 777 adminUsers.txt
cat /etc/group | grep sudo | cut -c 11- | tr , '\n' > adminUsers.txt
echo "" > demotedAdmins.txt
chmod 777 demotedAdmins.txt
for user in `cat adminUsers.txt`
do
	cat authAdmin.txt | grep ^$user
	if [ $? = "1" ]; then
		echo $user is not supposed to be an admin. Demoting $user
		deluser $user sudo
		echo The admin privileges of $user has been revoked >> demotedAdmins.txt
	fi
done
logtologgy "Removed unauthorized admins."

echo c[_] Changing passwords of all administrators.
cat readmeHTML.txt | sed -n '/Authorized Administrators/,/Authorized Users/p' > authAdminPass.txt
touch adminUsersPass.txt
chmod 777 adminUsersPass.txt
cat /etc/group | grep sudo | cut -c 11- | tr , '\n' | sed "s/\<${SUDO_USER}\>//g" > adminUsersPass.txt
for user in `cat adminUsersPass.txt`
do
password=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`
echo -e "$password\n$password" | passwd $user
echo "$user: $password" >> changedPasswords.txt
done
logtologgy "Changed admin passwords."

echo c[_] "Remove FTP services? (y/n)"
read yas
if [ $yas = "y" ];
then
    apt-get purge -y samba
    apt-get purge -y pure-ftpd
    apt-get purge -y *ftp*
    logtologgy "Removed FTP services."
fi

echo c[_] Checking if SSHD is a required service or not.
cat readmeHTML.txt | grep -w 'ssh\|SSH'
if [ $? = 0 ]; then
    apt-get install -y openssh-server
    sed -i 's/PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/Protocol.*/Protocol 2/g' /etc/ssh/sshd_config
    sed -i 's/X11Forwarding.*/X11Forwarding no/g' /etc/ssh/sshd_config
    sed -i 's/PermitEmptyPasswords.*/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
    service sshd start
    service sshd restart
    logtologgy "Installed SSH and secured it."
else
    apt-get purge -y openssh-server
    apt-get autoremove
fi
apt-get purge john*
apt-get purge ophcrack
apt-get purge minetest
apt-get purge nmap
apt-get purge wireshark
apt-get purge apache2
apt-get purge ftp
apt-get purge netcat*
apt-get purge polari
apt-get purge rpcbind
apt-get purge transmission-gtk
apt-get purge empathy
apt-get purge *openjdk*
apt-get purge mutt
apt-get purge iceweasel


apt-get autoremove
apt-get update
apt-get upgrade
