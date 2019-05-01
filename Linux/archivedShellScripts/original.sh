#!/bin/bash
# Script from 2017 written by Abhi
clear
echo "This is 2017's scripts. It's okay. I don't recommend running it though - Abhi"
echo "Make sure you are running this second"
echo "Hey guys, this script does all basic tasks such as installing certain packages and doing certain tasks. A detailed list will be provided at the end. You guys will have to be watching though"
echo "Do you guys want to run this file (y/n)?"
read startOpt
if [ $startOpt = n ]; then
  echo "Goodbye!"
  exit
else
sudo ufw enable
echo "Do you want to block Telnet from the firewall (y/n)?"
read telnetDisable
if [ $telnetDisable = y ]; then
  sudo ufw deny 23
  sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP
  echo "Telnet is blocked" >> finished.txt
else echo "Telnet was not blocked" >> finished.txt

fi

echo "Do you want to block certain things like NFS and ports 2049 (y/n)? (Yes is recommended)"
read ipTableBlock
if [ $ipTableBlock = y ]; then
  source enableIpTables.sh
  echo "I have blocked certain services such as NFS in iptables and blocked a few ports. Check the enableIpTables.sh for more details on which services were blocked" >> finished.txt
else echo "Certain services were not blocked." >> finished.txt
fi

echo "Do you want to install OpenSSH (y/n)?"
read openSSHinstall
if [ $openSSHinstall = y ]; then
  sudo apt-get -y install openssh-server
  echo "OpenSSH was installed" >> finished.txt
else echo "OpenSSH was not installed" >> finished.txt
fi
sudo auditctl -e 1
echo "Do you want to disable root (y/n)? Yes is recommended"
read rootDisable
if [ $rootDisable = y ]; then
  sudo passwd -l root
  echo "Root was disabled" >> finished.txt
else echo "Root was not disabled" >> finished.txt
fi

sudo sed -re 's/^(PermitRootLogin)([[:space:]]+)yes/\1\2no/' -i.`date -I` /etc/ssh/ssh_config
sudo sed -re 's/^(PermitRootLogin)([[:space:]]+)yes/\1\2no/' -i.`date -I` /etc/ssh/sshd_config
sudo sed -re 's/^(PermitEmptyPasswords)([[:space:]]+)yes/\1\2no/' -i.`date -I` /etc/ssh/ssh_config
sudo sed -re 's/^(PermitEmptyPasswords)([[:space:]]+)yes/\1\2no/' -i.`date -I` /etc/ssh/sshd_config
sudo touch /etc/lightdm/lightdm.conf.d/50-ubuntu.conf
sudo chmod 777 /etc/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "[SeatDefaults]" >> /etc/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf.d/50-ubuntu.conf
sudo sed -re 's/^(PASS_MIN_DAYS)([[:space:]]+)0/PASS_MIN_DAYS 10/' -i.`date -I` /etc/login.defs
sudo sed -re 's/^(PASS_MAX_DAYS)([[:space:]]+)99999/PASS_MAX_DAYS 90/' -i.`date -I` /etc/login.defs
sudo sed -re 's/^(PASS_WARN_AGE)([[:space:]]+)7/PASS_WARN_AGE 7/' -i.`date -I` /etc/login.defs

echo "Do you want to secure the network settings (y/n)? Yes is recommended"
read networkOpt
if [ $networkOpt = y ]; then
  sudo chmod 777 /etc/sysctl.conf
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  sudo chmod 644 /etc/sysctl.conf
  sudo chmod 777 /etc/host.conf
  echo "nospoof on" >> /etc/host.conf
  sudo chmod 644 /etc/host.conf
  sudo sysctl -w net.ipv4.tcp_syncookies=1
  sudo sysctl -w net.ipv4.ip_forward=0
  sudo sysctl -w net.ipv4.conf.all.send_redirects=0
  sudo sysctl -w net.ipv4.conf.default.send_redirects=0
  sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
  sudo sysctl -w net.ipv4.conf.default.accept_redirects=0
  sudo sysctl -w net.ipv4.conf.all.secure_redirects=0
  sudo sysctl -w net.ipv4.conf.default.secure_redirects=0
  sudo sysctl -w net.ipv4.conf.all.log_martians=1
  sudo sysctl -w net.ipv4.conf.default.log_martians=1
  sudo sysctl -w net.ipv4.tcp_timestamps=0
  sudo sysctl -p
  echo "I enable syn cookie protection." >> finished.txt
  echo "I disable ipv6 because it could be potentially harmful" >> finished.txt
  echo "I then prevent IP Spoofing." >> finished.txt
  echo "I protect sysctl.conf." >> finished.txt
else echo "I did not alter the network settings" >> finished.txt
fi

echo "Do you want to make sure only root users can use Cron?. Yes is recommended (y/n)"
read cronRoot
if [ $cronRoot = y ]; then
  sudo crontab -r
	/bin/rm -f cron.deny at.deny
  sudo touch /etc/cron.d/cron.deny
  sudo touch /etc/cron.d/cron.allow
  sudo chmod 777 /etc/cron.d/cron.allow
  echo "root" >> /etc/cron.d/cron.allow
  sudo chmod 644 /etc/cron.d/cron.allow
  sudo chmod 700 /usr/bin/crontab
  echo "Non root users can't access Cron" >> finished.txt
else echo "Non root users can access Cron." >> finished.txt

fi
echo "Here are all the different servers running on the computer. Make sure that services that should be off are off" >> results.txt
sudo lsof -i -n -P >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "Here are all the different servers running on the computer. Make sure that services that should be off are off" >> results.txt
sudo netstat -tulpn >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "Make sure that the sources don't look malicious and if there are any remove them by doing 'sudo gedit /etc/apt/sources.list'" >> results.txt
cat /etc/apt/sources.list >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "Make sure that by going to a website doesn't redirect. Search up the IP address online and if it is malicious then remove it from /etc/hosts" >> results.txt
cat /etc/hosts >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "Make sure that only '  0' is present other than the other comments present. If it is not do 'sudo gedit /etc/rc.local' and add it" >> results.txt
cat /etc/rc.local >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "These are all the services that are on this machine. - means not running. + means running" >> results.txt
sudo service --status-all >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "Here are all the programs running on certain ports. Check the ports online if you have to and close them. Keep in mind anything with 127.0.0.1 means it is the local machine" >> results.txt
sudo ss -ln >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "This checks the ip_forwarding section. If 0 is outputted don't worry about it. If it is not then go to this directory: /proc/sys/net/ipv4/ip_forward and keep a zero" >> results.txt
cat /proc/sys/net/ipv4/ip_forward >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "Here is the contents of the /etc/group file. Make sure that only admins are in the: sudo, lpadmin groups. If there are standard users in it, remove them. File located at: /etc/group" >> results.txt
cat /etc/group >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "Here are the contents of the /etc/passwd file. We have to make sure that the standard users are in here and not unathourized users. We have to make sure that only root is UID 0. Only users that can login, can login. Here is the format and meaning of each line: root:x:0:0:root:/root:/bin/bash. The root is the username, that can change. x indicates that it is a password stored in /etc/shadow. 0 indicates the User ID (UID). The second 0 indicates the Group ID, The second root can be anythign because it contains user information. The section after the before one is the users' home directory. The last part is the absolute path to the command or shell. To make sure a user can't log in replace it with: /usr/sbin/nologin" >> results.txt
cat /etc/passwd >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo "Make sure that '%sudo ALL = (ALL) ALL' exists in the following output, if it is not then do 'sudo visudo' and change it" >> results.txt
sudo chmod 755 /etc/sudoers
sudo cat /etc/sudoers >> results.txt
sudo chmod 0440 /etc/sudoers
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
sudo sed -re '/pam_unix.so/ s/$/ minlen=8/' -i.`date -I` /etc/pam.d/common-password
sudo sed -re '/pam_unix.so/ s/$/ remember=5/' -i.`date -I` /etc/pam.d/common-password
sudo sed -re '/pam_cracklib.so/ s/$/ ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' -i.`date -I` /etc/pam.d/common-password
echo "Do you want to do account lockout? (y/n)"
read accountLockout
if [$accountLockout = y]; then
sudo chmod 777 /etc/pam.d/common-auth
echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' >> /etc/pam.d/common-auth
sudo chmod 644 /etc/pam.d/common-auth
fi
echo "Do you want to remove OpenSSH (y/n) ?"
read removeOpenSSH
if [ $removeOpenSSH = y ]; then
  sudo apt-get -y --purge remove openssh-server
  echo "Removed OpenSSH" >> finished.txt
else echo "Did not remove OpenSSH" >> finished.txt

fi
echo "Do you want to remove Samba (y/n) ?"
read removeSamba
if [ $removeSamba = y ]; then
  sudo apt-get -y --purge remove samba
  echo "Removed Samba" >> finished.txt
else echo "Did not remove Samba" >> finished.txt

fi
sudo apt-get -y --purge remove john
sudo apt  -y autoremove
sudo chmod 755 /bin/su
sudo sed -re 's/^root/# root/' -i.`date -I` /etc/sudoers
sudo sed -re 's/^# auth/auth/' -i.`date -I` /etc/pam.d/su
echo "This part will show all the files in all the users' directories. We can use this to help us find any prohibited files or things" >> results.txt
echo "Keep in mind '.' and '..' means to go back so if that is the only thing in a directory then the directory is empty" >> results.txt
sudo ls -Ra /home/* >> results.txt
echo " " >> results.txt
echo " " >> results.txt
echo " " >> results.txt
awk '{ printf "# "; print; }' /etc/fail2ban/jail.conf | sudo tee /etc/fail2ban/jail.local
sudo sed -re 's/^# bantime([[:space:]]+)=([[:space:]]+)600/bantime = 1800/' -i.`date -I` /etc/fail2ban/jail.local
sudo sed -re 's/^# destemail([[:space:]]+)=([[:space:]]+)root@localhost/destemail = test@email.com/' -i.`date -I` /etc/fail2ban/jail.local
echo "Do you want to scan the entire computer for viruses (y/n)? Keep in mind this will take a long time but is recommended to do."
read scanChoice
sudo touch scan.txt
if [ $scanChoice = y ]; then
  sudo clamscan -r --log=scan.txt --exclude-dir="^/sys" /
  echo "Scanned the whole computer for viruses. Output in scan.txt" >> finished.txt
else echo "Did not scan the whole computer for viruses. To do it, run 'sudo clamscan -r --log=scan.txt /'" >> finished.txt

fi
echo "Do you want to scan for root kits (y/n)? This also takes a while and requires your input. Will be logged to rkscan.txt in the same directory as your shell script"
read rkScan
if [ $rkScan = y ]; then
  sudo rkhunter -c --enable all --disable none --logfile rkscan.txt
  sudo chmod 777 rkscan.txt
  sudo chkrootkit >> rk2scan.txt
  echo "Performed rootkit scan" >> finished.txt
else echo "Did not perform rootkit scan" >> finished.txt
fi

echo "Do you want to run Lynis scan (y/n)?"
read lynisScan
if [ $lynisScan = y ]; then
  sudo lynis -c --logfile lynisScan.txt
  echo "Performed lynis scan" >> finished.txt
else echo "Did not perform lynis scan" >> finished.txt
fi
echo "The script will finish soon. Please check the 3 txt files created"
echo "The script has finished running. This page will contain all the things the script did. Keep in mind we might have to manually check after this has been completed just to be safe." >> finished.txt
echo "The firewall has been enabled and certain services such as NFS are blocked." >> finished.txt
echo "I have installed guwf, synaptic, libpam-cracklib, fail2ban, clamav, gnome-system-tools, and auditd for auditing" >> finished.txt
echo "Note: clamav is an anti virus sofwtare. Still do install another Antivirus just to be safe." >> finished.txt
echo "Then auditing becomes enabled" >> finished.txt
echo "After that I made sure that you can't login as root for SSH and empty passwords are not permitted." >> finished.txt
echo "I then remove the guest account" >> finished.txt
echo "I set the Password Policies next. I use the default values recommended by CyberPatriot." >> finished.txt
echo "Then I ouput all the services on the computer to results.txt" >> finished.txt
echo "After that, I output all the services along with their ports to results.txt" >> finished.txt
echo "Then I output the ipv4 file to make sure there is a 0 or not" >> finished.txt
echo "I then output the contents of the group file so that you guys can see if standard users are in the admin group or not and if they are in the sudo group or not." >> finished.txt
echo "I then output the /etc/passwd file to make sure of users" >> finished.txt
echo "I then output the sudoers file to make sure only sudo group can sudo" >> finished.txt
echo "I then do more password policies and account lockout policies." >> finished.txt
echo "I then remove samba and john which are potentially harmful. I then autoremove any products that need to be removed after those 2 have been removed." >> finished.txt
echo "I then secure the su command. We have to manually go and edit the sudo visudo to make sure sudo su doesn't work. Call Abhi when you get there." >> finished.txt
echo "I then output all the files and directories for every single user into the results.txt file" >> finished.txt
echo "I then start setting up Fail2Ban but more things have to be done. Refer to checklist for details. We will also have to uncomment [DEFAULT]. Call Abhi for that." >> finished.txt

echo "Here are all the things we still need to do" >> todo.txt
echo "Make sure to open everything with sudo gedit unless stated otherwiser. This makes your life easier. Also make sure to check all the scan files." >> todo.txt
echo "After the scan was completed, go to the scan.txt and scroll all the way down to the end see what files are infected then figure out which file it is and delete it." >> todo.txt
echo "If you performed the Root Kit scan. Make sure to go through rkscan.txt and rk2scan.txt and figure out if you have to remove any rootkits or if any files may be corrupt." >> todo.txt
echo "If you performed the Lynis Scan. Make sure to go through the lynisScan.txt file. It's a lot but it might be able to get us a lot points because it talks about all the secure things that we might have to install." >> todo.txt
echo "Make sure you guys go through the results.txt and do the necessary things to. Such as removing services that should not be there." >> todo.txt
echo "Do 'sudo visudo' and where it says '%sudo ALL = (ALL) ALL' add ', !/bin/su' to the end of the line. Now if you try 'sudo su' it should say 'command denied'" >> todo.txt
echo "Open up /etc/fail2ban/jail.local and find the entry: 'action = ...' (it should only have one '#' before it and not 2 '#') and change it to: 'action = $(action_)s'. Make sure to check the checklist before doing this. Keep the file open for the next todo task" >> todo.txt
echo "Open up /etc/fail2ban/jail.local and find ssh or sshd and make sure to keep enable = true under that." >> todo.txt
echo "Go to the Ubuntu 16 checklist and make sure to find the section labeled Configure Portsentry and do it." >> todo.txt
echo "Make sure to go to the Firefox Privacy settings and change things that seem logical." >> todo.txt
echo "That's all I can think of. Make sure that you did the most basic of the basic. Also, make sure to check the finished.txt and then compare it with the scoring report and see how many points we got for each thing." >> todo.txt

fi
