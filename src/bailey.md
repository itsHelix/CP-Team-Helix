# Bailey
A standard-based, organized hardening script for Ubuntu 14-18 and Debian 7-9.

This document serves as a line-group documentation of the script, as well as, commentary on its ecosystem and uses.

Bailey is the result of work done by countless people. Notable contributions are attributed to:
* [Abhinav Vemulapalli](https://github.com/nandanav), for his work on `telluride.sh` and `avon.sh`
* [pyllyukko](https://github.com/pyllyukko) for his work on `user.js`, which is aliased in this work
* [Tavin Turner](https://github.com/itsTurner) for his work on `telluride.sh`, `estes.sh`, `avon.sh`, and `Bailey`
* [Ian](https://stackoverflow.com/users/11013589/cutwow475) [Boraks](https://github.com/Cutwow) for his work on `Bailey`

# Ecosystem
Like other hardening tools made by Helix in the past, Bailey's primary shell script is written in Bash. Unlike other hardening tools made by Helix in the past, Bailey takes advantage of two tools to liken development in shell to that in compile languages in order to promote devops and simplify production use. Notably, it uses [shc](https://github.com/neurobin/shc) to compile shell scripts into an executable and [bats](https://github.com/sstephenson/bats) for unit tests.

While some of Bailey is developed with references to previous scripts, the goal of the script is to promote reference to standardized hardening guides, notably CIS [Ubuntu Linux 16.04](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Ubuntu_16.pdf), [Ubuntu Linux 18.04](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Ubuntu_18.pdf), [Debian Linux 8](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Debian_8.pdf), [Apache HTTP Server 2.4](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Apache_2.4.pdf), and [Mozilla Firefox 38](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Firefox_38.pdf).

## Introduction to a `shc` environment
### Installing `shc`
In an \*ubuntu environment, run the following commands with administrator priveliges:
```bash
add-apt-repository ppa:neurobin/ppa
apt-get update
apt-get install shc
```

To install shc on other environments, refer to the [`shc` readme](https://github.com/neurobin/shc/blob/release/README.md).

### Compiling with `shc`
The standard compilation command for Bailey with `shc` only specifies two flags: the file `-f` and the output `-o`. In the directory `src/` run:
`shc -f bailey.sh -o bailey`

This command generates two files:
* C file `bailey.sh.x.c` generated from conversion from Bash to C
* Executable `bailey` (the final executable)

Notes:
* `shc` is very particular about shebangs. For this reason, the only shebang in `bailey.sh` should be `#!/bin/sh` and not `#!/usr/bin/env bash`.
	* `#!/usr/bin/env bash` is used for macOS systems, while `#!/bin/sh` is used on Debian systems. For this reason, Bailey should only ever be compiled in a Debian or \*ubuntu environment.
* There exist two expiramental flags for `shc` used to harden the executable. These prevent the script from running in any shell other than those of the same type as the one it was compiled on (e.g. a Bash-compiled binary cannot run in ZSH). This may threaten the use of the binary in competition. For this reason, never compile with the flags `-H` or `-s`.
* `shc` offers a flag that makes the binary untraceable by tools like `strace`, `ptrace`, and `truss`. This flag works in a way that prevents other processes from affecting its operations in any way with the exception of the process manager. This may be detrimental to competition use or prevent certain processes from executing correctly in the script. For this reason, never compile with the flag `-U`

# Functions of `bailey.sh`
## Logging, Dumping, and Global Variables
The Bailey production file structure creates a folder `bailey` in the present working directory. Subdirectories include `log` (stores the one logfile generated during runtime) and `dump` (stores miscillaneous files such as backups and perfect file generation).

The logfile is named with `bailey_` followed by the time at which the shell was run (with some delay, given processing time) in HH:MM:SS (`+%T`) format.
Each time something is logged inside of the script, the message is appended to the logfile with the time in `+%T` format preceding the message, as well as, output to the console without any preceding content.

The only existing global variable in the script is `password`, which stores the default password of the system, which will be used during automatic user management (user creation, permission correction, and password alteration).

# CIS Mozilla Firefox 38
### `firefox_update_and_CIS`

# CIS Ubuntu 16
## Implemented Standards
| Section | Suggestion (X.X...) | Implemented (# of functions) |
| ------- | ------------------- | ---------------------------- |
| Filesystem configuration | 1.1.1 | Yes (6) |
| Filesystem configuration | 1.1.2-1.1.19 | `No` |
| Filesystem configuration | 1.1.20 | Yes |
| Filesystem configuration | 1.1.21 | Yes |
| Configure software updates | 1.2.1 | Yes |
| Configure GPG keys | 1.2.2 | `No` |
| AIDE is installed | 1.3.1 | Yes |
| Filesystem integrity is being checked | 1.3.2 | Yes |
| Bootloader is configured | 1.4.1 | Yes |
| Bottloader password is set | 1.4.2 | Yes |
| Authentication required for single user mode | 1.4.3 | Yes |
| Disabling inetd services | 2.1 | Yes |
| Time Synchronization | 2.2.1 | `No` |
| Disabling Special Purpose Services<sup>1</sup> | 2.2.2-2.2.14 | Yes |
| Ensure mail transfer agent is configured | 2.2.15 | `No` |
| Disabling Special Purpose Services<sup>2</sup> | 2.2.16/17 | Yes |



## 1.1.1: Disable unused filesystems
### `filesystem_mounting_disabled`
* Appends `install [filesystem] /bin/true` to the end of `/etc/modprobe.d/[filesystem].conf` to disable use of the filesystem
* Run `rmmod [filesystem]` to apply changes to the filesystem

Testing:
* `modprobe -n -v [filesystem]`: `install /bin/true`
* `lsmod | grep [filesystem]`: N/A

**BATS Correspondent: `filesystem_mounting_disabled_boolean`**
#### Applications
| Filesystem | Command | `$1` parameter |
| ---------- | ------- | -------------- |
| [Cramfs](https://www.kernel.org/doc/Documentation/filesystems/cramfs.txt) | `cramfs_mounting_disabled` | `cramfs` |
| [FreeVxFS](https://en.wikipedia.org/wiki/Veritas_File_System) | `freevxfs_mounting_disabled` | `freevxfs` |
| [JFFS2](https://en.wikipedia.org/wiki/JFFS2) | `jffs2_mounting_disabled` | `jffs2` |
| [HFS (Hierarchical File System)](https://en.wikipedia.org/wiki/Hierarchical_File_System) | `hfs_mounting_disabled` | `hfs` |
| [HFS+ (Extended HFS)](https://en.wikipedia.org/wiki/HFS_Plus) | `hfsplus_mounting_disabled` | `hfsplus` |
| [UDF (Universal Disk Format)](https://en.wikipedia.org/wiki/Universal_Disk_Format) | `udf_mounting_disabled` | `udf` |

## 1.1.2-1.1.19: Separate partition (+ `nodev`, `nosuid`) for certain areas
Isolating a folder or media in its own partition eliminates the risk of resource exhaustion by world-writing, makes the directory useless for an attacker to install executable code in after setting the `noexec` option, prevents an attacker form establishing a hardlink to a system `setuid` program, as the hardling would break upon update, only giving the attacker a separate copy of the program.
This suggestion is intentionally unimplemented, since Cyber Patriot files may rely on references to existing folder/media directories that could raise flags if the machine is not restarted for a significant period of time. In order to retain the integrity of the script, it cannot restart in the middle, only at the very end as the last operation, which cannot be guarunteed. Furthermore, partition limiting could restrict the folder/media directory to a point that it is less efficient than storing it on the boot directory, the opposite of most reasons for implementation.

### 1.1.2/5/6/10/11/12: Ensure separate partition exists for folder or media
If one were to implement a folder partition, the following could be added:
* Assign `1777` priveleges to `/tmp`
* Make directory `/tmp.new` with permissions `1777`
* Expose `/tmp` on a different path (`mount --bind / /.root.only`)
* Make a [union mount](https://unix.stackexchange.com/questions/5489/how-to-safely-move-tmp-to-a-different-volume) of `/.root.only/fstab` and `/tmp.new`, mounted on `/tmp`
* [Add an entry](https://askubuntu.com/questions/303497/adding-an-entry-to-fstab) in `/etc/fstab`

Testing:
* `mount | grep [folder/media]]`: `tmpfs on [folder/media] type tmpfs (*)`

### 1.1.3/4/7-9/13-19: Paritioned folder options
These suggestions intentionally unimplemented, since separate folder and media partitions is not implemented.
However, if one were to implement it, the following could be added:
* Edit `/etc/fstab` and add `[option: nodev/nosuid/noexec]` to the fourth column of the folder/media partition
* Remount folder/media: `mount -o remount,[option: nodev/nosuid/noexec] [folder/media]`

Testing:
* `mount | grep /tmp`: `tmpfs on /tmp type tmpfs (*[option: nodev/nosuid]*)`

## 1.1.20: Ensure sticky bit is set on all world-writable directories
### `world_writable_sticky_bit`
Sticky bits are permission bits (`rwxrwxrwx` format) that restrict rename/delete to only owner and root. This prevents deleting or renaming files in world writable directories owned by another user. This assignment can be achieved by running the command:
* `df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t`

Testing:
* `df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null`: N/A

## 1.1.21: Disable Automounting
### `disable_automatic_mounting`
Automounting allows anybody with physical access to attach a USB drive or disc to execute its contents in the system, even if they lacked permission to mount it themselves. To remedy this we execute:
* `systemctl disable autofs`

Testing:
* `systemctl is-enabled autofs`: `disabled`

## 1.2.1: Ensure package manager repositories are configured
### `package_manager_repos_configured`
Having incorrect or corrupted source lists can lead to updates failing and/or applications not being able to download. An attacker might use this to put in his own repository for an update that has corrupt date, viruses, and/or bot nets in it. To fix this we execute:
* `cat presets/<os_identifier>sources.list > $sources_loc`

Testing:
* `apt-cache policy`: shows no malicious links

## 1.2.2: Ensure GPG keys are configured
Most packages managers implement GPG key signing to verify package integrity during installation. It is important to ensure that updates are obtained from a valid source to protect against spoofing that could lead to the inadvertent installation of malware on the system.

Testing:
* `apt-key list`: shows no malicious links/keys

## 1.3.1: Ensure AIDE is installed
### `install_AIDE`
AIDE takes a snapshot of filesystem state including modification times, permissions, and file hashes which can then be used to compare against the current state of the filesystem to detect modifications to the system. By monitoring the filesystem state compromised files can be detected to prevent or limit the exposure of accidental or malicious misconfigurations or modified binaries. To fix this you run:
* `apt-get install aide` then run `aide --init`

Testing:
* `dpkg -s aide`: AIDE is installed

## 1.3.2: Ensure filesystem integrity is regularly checked
### `filesystem_integrity_checked`
Periodic checking of the filesystem integrity is needed to detect changes to the filesystem. Periodic file checking allows the system administrator to determine on a regular basis if critical files have been changed in an unauthorized fashion. To fix this we will edit our crontab:
* `crontab -u root -e` and add the following line `0 5 * * * /usr/bin/aide --check`

Testing:
* `grep -r aide /etc/cron.* /etc/crontab`: any output means you are checking

## 1.4.1: Ensure permissions on bootloader giconfig are configured
### `bootloader_permission_fix`
The grub configuration file contains information on boot settings and passwords for unlocking boot options. The grub configuration is usually `grub.cfg` stored in `/boot/grub`. Setting the permissions to read and write for root only prevents non-root users from seeing the boot parameters or changing them. Non-root users who read the boot parameters may be able to identify weaknesses in security upon boot and be able to exploit them. To fix this we set permissions by running:
* `chown root:root /boot/grub/grub.cfg` and `chmod og-rwx /boot/grub/grub.cfg`

Testing:
* `stat /boot/grub/grub.cfg | grep -i "access: ("`: Access: (0600/-rw-------) Uid: ( 0/ root) Gid: ( 0/ root)

## 1.4.2: Ensure bootloader password is set
### `bottloader_password_set`
Setting the boot loader password will require that anyone rebooting the system must enter a password before being able to set command line boot parameters. Requiring a boot password upon execution of the boot loader will prevent an unauthorized user from entering boot parameters or changing the boot partition. This prevents users from weakening security (e.g. turning off SELinux at boot time). To fix this we:
* `grub-mkpasswd-pbkdf2` to create a hashed password then we edit `/etc/grub.d/00_header` to add the following `\ncat <<EOF\nset superusers="Admin"\npassword_pbkdf2 Admin'$passwordHash'\nEOF`

Testing:
* `grep "^set superusers" /boot/grub/grub.cfg`: Admin
* `grep "^password" /boot/grub/grub.cfg`: Password hash

## 1.4.3: Ensure authentication required for single user mode
### `authentication_req_single_user_mode`
Single user mode is used for recovery when the system detects an issue during boot or by manual selection from the bootloader. Requiring authentication in single user mode prevents an unauthorized user from rebooting the system into single user to gain root privileges without credentials. To fix this we set root password with
* `passwd root`

Testing:
* `grep ^root:[*\!]: /etc/shadow`: No results should be returned

## 1.5.1: Ensure core dumps are restricted
Core dumps– memory from executable programs, often to determine reationale for program abortion– can leak confidential information from a core file. Setting a soft limit secures processes requiring core dumps while allowing users to ovverride the limit variable (hard limits cannot be overridden by users). Setting `fs.suid_dumpable = 0` prevents setuid (privilege escalation flagging user access rights to that of the executable owner) programs from dumping core.
* Append `* hard core 0` to `/etc/security/limits.conf` or `/etc/security/limits.d/*`
*  Set `fs.suid_dumpable = 0` in `/etc/sysctl.conf` or `/etc/sysctl.d/*`
*  Set the active kernel parameter: `sysctl -w fs.suid_dumpable=0`

Testing:
* `grep "hard core" /etc/security/limits.conf /etc/security/limits.d/*`: `* hard core 0`
* `sysctl fs.suid_dumpable`: `fs.suid_dumpable = 0`
* `grep "fs\.suid_dumpable" /etc/sysctl.conf /etc/sysctl.d/*`: `fs.suid_dumpable = 0`

## 2.1: inetd Services
### `disable_inetd_services`
inetd is a super-server daemon that provides internet services and passes connections to configured services. While not commonly used inetd and any unneeded inetd based services should be disabled if possible. To fix this we run:
* `service <service> stop` and `update-rc.d -f <service> remove`

Testing:
* `grep -R "^<services>" /etc/inetd.*`: Should return nothing

## 2.2.1: Time Synchronization
System time should be synchronized between all systems in an environment. This is typically done by establishing an authoritative time server or set of servers and having all systems synchronize their clocks to them. Time synchronization is important to support time sensitive security mechanisms like Kerberos and also ensures log files have consistent time records across the enterprise, which aids in forensic investigations. This is not completed in Bailey as this needs to be done on a per network basis.

## 2.2.2-17 (not including 2.2.15): Special Purpose Services
### `disable_special_purpose_services`
If any of these services, [`X Window System, Avahi, CUPS, DHCP, LDAP, NFS, RPC, DNS, FTP, HTTP, IMAP, POP3, Samba, HTTP Proxy, SNMP, rsync, NIS`], are not required, it is recommended that they be disabled or deleted from the system to reduce the potential attack surface. To do this we:
* `systemctl disable <service/server name>` or in some cases `apt-get remove <service/server name>`

Testing:
* `systemctl is-enabled <service/server name>`: disabled

## 2.2.15: Ensure mail transfer agent is configured for local-only mode
Mail Transfer Agents (MTA), such as `sendmail` and `Postfix`, are used to listen for incoming mail and transfer the messages to the appropriate user or mail server. If the system is not intended to be a mail server, it is recommended that the MTA be configured to only process local mail. The software for all Mail Transfer Agents is complex and most have a long history of security issues. While it is important to ensure that the system can process local mail messages, it is not necessary to have the MTA's daemon listening on a port unless the server is intended to be a mail server that receives and processes mail from other systems. The reason why Bailey dose not fix this problem, is because it is on a system by system basis. But, if you do need to complete this here is how:
* Run `netstat -an | grep LIST | grep ":25[[:space:]]"` and make sure that the MTA is not listening on any non-loopback address (`127.0.0.1` or `::1`). Output should look somthing like this: `tcp 0 0 127.0.0.1:25 0.0.0.0:* LISTEN `.
* If there is a problem, you will need to edit `/etc/postfix/main.cf` and add the line `inet_interfaces = localhost` to the RECEIVING MAIL `section`. If the line already exists, change it so it looks like the line above.
* Then restart postfix: `service postfix restart`

## 4.1.2: Ensure auditd service is enabled
### `enable_auditd`
Turn on the `auditd` daemon to record system events. The capturing of system events provides system administrators with information to allow them to determine if unauthorized access to their system is occurring. To fix this we run:
* `systemctl enable auditd`

Testing:
* `systemctl is-enabled auditd`: enabled
