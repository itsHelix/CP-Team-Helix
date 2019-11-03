# Bailey
A standard-based, organized hardening script for Ubuntu 14-18 and Debian 7-9.

This document serves as a line-group documentation of the script, as well as, commentary on its ecosystem and uses.

Bailey is the result of work done by countless people. Notable contributions are attributed to:
* [Abhinav Vemulapalli](https://github.com/nandanav), for his work on `telluride.sh` and `avon.sh`
* [pyllyukko](https://github.com/pyllyukko) for his work on `user.js`, which is aliased in this work
* [Tavin Turner](https://github.com/itsTurner) for his work on `telluride.sh`, `estes.sh`, `avon.sh`, and `Bailey`
* [Ian](https://stackoverflow.com/users/11013589/cutwow475) [Boraks](https://github.com/Cutwow) for his work on `Bailey`
* [Brinda Malik](https://github.com/BrindaMal) for her work on `Bailey`

# Ecosystem
Like other hardening tools made by Helix in the past, Bailey's primary shell script is written in Bash. Unlike other hardening tools made by Helix in the past, Bailey takes advantage of two tools to liken development in shell to that in compile languages in order to promote devops and simplify production use. Notably, it uses [shc](https://github.com/neurobin/shc) to compile shell scripts into an executable and [bats](https://github.com/sstephenson/bats) for unit tests.

While some of Bailey is developed with references to previous scripts, the goal of the script is to promote reference to standardized hardening guides, notably CIS [Ubuntu Linux 16.04](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Ubuntu_16.pdf), [Ubuntu Linux 18.04](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Ubuntu_18.pdf), [Debian Linux 8](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Debian_8.pdf), [Apache HTTP Server 2.4](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Apache_2.4.pdf), and [Mozilla Firefox 38](https://github.com/Cutwow/CPXII-Team-Helix/blob/master/CIS%20Benchmarks/Firefox_38.pdf).

Also, while developing this ecosystem we used some music to help:
* [JoJos Bizarre Adventure Full OP 1-9](https://www.youtube.com/watch?v=rA4eesTbNKE)
* [Kahoot Christmas Lobby Music 2017](https://www.youtube.com/watch?v=fRzddwmE_to&t=322s)
* [lofi hip hop radio - beats to relax/study to](https://www.youtube.com/watch?v=hHW1oY26kxQ)

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
| Ensure core dumps are restricted | 1.5.1 | Yes |
| Ensure XD/NX support is enabled | 1.5.2 | `No` |
| Ensure address space layout randomization (ASLR) is enabled | 1.5.3 | Yes |
| Ensure prelink is disabled | 1.5.4 | Yes |
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
* `grep "fs\.suid_dumpable" /etc/sysctl.conf /etc/sysctl.d/*`: `fs.suid_dumpable=0`

## 1.5.2: Ensure XD/NX support is enabled
In an effort to help counteract buffer overflow exploitation, No Execute (AMD, aka NX) or Execute Disabled (Intel, aka XD)– preventing code execution on per memory page basis on x86 processors– should be enabled.
This suggestion is intentionally unimplemented, as Cyber Patriot images do not operate on x86 architecture, and cannot survey BIOS configuration. If one were to use XD/NX, the following would have to be done:
* Enable XD/NX in your BIOS and configure bootloader to load a new kernel.

Testing:
* `dmesg | grep NX`: `NX (Execute Disable) protection: active`

## 1.5.3: Ensure address space layout randomization (ASLR) is enabled
Address space layout randomization, an exploit mitigation technique which randomly arranged address space of key data areas of processes, should be enabled to make it more difficult to write memory page exploits and buffer overflow vulnerabilities, since memory placement will be consistenly shifting.
* Set `kernel.randomize_va_space = 2` in `/etc/sysctl.conf` or `/etc/sysctl.d/*`
* Set the active kernel parameter: `sysctl -w kernel.randomize_va_space=2`

Testing:
* `sysctl kernel.randomize_va_space`: `kernel.randomize_va_space = 2`
* `grep "kernel\.randomize_va_space" /etc/sysctl.conf /etc/sysctl.d/*`: `kernel.randomize_va_space = 2`

## 1.5.4: Ensure prelink is disabled
`prelink`, a program that optimizes startup relocations by modifying ELF shared libraries and ELF dynamically linked binaries specially, can interfere with the operation of AIDE, since it changes binaries and can increase the vulnerability of a system if a malivious user is able to compromise a common library.
* Restore binaries to normal (`prelink -ua`)
* Uninstall `prelink`

Testing:
* `dpkg -s prelink`: N/A

## 1.6.1: Configure SELinux
SELinux provides Mandatory Access Control that greatly augments the default Disccresionary Access Control model. Every process and every object on the ysstem is assigned a security context (a label that includes detailed type information about the object). The kernela llowws processes to access objects only if that access is explicitly allowed by the poly in effect. The poly defines transitions, so that a user can be allowed to run software, which can run under a different context than the user's default. This automatically limits the damage that the sotwarre can do to files accessible by the calling user. The user does not need to take any action to gain this benefit. For ana ction to occur, both the traditional DAC permissions must be satisfied as well as the SELinux MAC rules.

### 1.6.1.1: Ensure SELinux is not disabled in bootloader configuration
To get the effects of SELinux, it must be enabled at boot time and verify that it has not been overwritten by the grub boot parameters.
* Remove all instances of `selinux=0` and `envorcing=0` from `/etc/default/grub`
* Update the `grub2` configuration

Testing:
* `grep "^\s*linux" /boot/grub/grub.cfg`: N/A

### 1.6.1.2: Ensure the SELinux state is enforcing
Set SELinux to enable when the system is booted.
* Edit `/etc/selinux/config` to set the parameter `SELINUX=enforcing`

Testing:
* `grep SELINUX=enforcing /etc/selinux/config`: `SELINUX=enforcing`

### 1.6.1.3: Ensure SELinux poly is configured
Confgure SELinux to meet or exceed the default targeted polycy, which constrains daemons and system software only.
* Edit `etc/selinux/config` to set the parameter `SELINUXTYPE=ubuntu`

Testing:
* `grep SELINUXTYPE= /etc/selinux/config`: `SELINUXTYPE=ubuntu`
* `sestatus`: `policy from config file: ubuntu`

### 1.6.1.4: Ensure no unconfined daemons exist
Daemons that are not defined in SELinux policy will inherit the security context of their parent process. Since daemons are launched and descend form the `init` process, they will inherit the security context labvel `initrc_t`. This could cause the unintended consequence of giving the process more persmission than it requires.
This suggestion is intentionally unimplemented because it could allow for confusion on the nature of certain daemons, potentitally destroying vital processes.
* Investigate any unconfined daemons found during the audit action. They may need to have an existing security context assigned to htem or a policy built for them.

Testing:
* `ps -eZ | egrep "initrc" | egrep -vw "tr|ps|egrep|bash|awk" | tr ':' ' ' | awk '{ print $NF }'`: N/A

## 1.6.2: Configure AppArmor
AppArmor provides a Mandatory Access Control (MAC) system that greatly augments the default Discretionary Access Control (DAC) model. Under AppArmor MAC rules are applied by file paths instead of by security contexts as in other MAC systems. As such it does not require support in the filesystem and can be applied to network mounted filesystems for example. AppArmor security policies define what system resources applications can access and what privileges they can do so with. This automatically limits the damage that the software can do to files accessible by the calling user. The user does not need to take any action to gain this benefit. For an action to occur, both the traditional DAC permissions must be satisfied as well as the AppArmor MAC rules. The action will not be allowed if either one of these models does not permit the action. In this way, AppArmor rules can only make a system's permissions more restrictive and secure.

### 1.6.2.1: Ensure AppArmor is not disabled in bootloader configuration
Configure AppArmor to be enabled at boot time and verity that it has not been overwritten by the bootloader boot parameters. AppArmor must be enabled at boot time in your bootloader configuration to ensure that the controls it provides are not overridden.
* Edit /etc/default/grub and remove all instances of `apparmor=0`: `GRUB_CMDLINE_LINUX_DEFAULT="quiet" [\n] GRUB_CMDLINE_LINUX=""`
* Update the grub2 configuration.

Testing:
* `grep "^\s*linux" /boot/grub/grub.cfg`: N/A

### 1.6.2.2: Ensure all AppArmor profiles are enforcing
AppArmore profiles define what resources aspplications are able to access. Security configuration requirements vary frm site to site. Some sites may mandate a policy that is stricter than the default policy, which is perfectly acceptable. This item is intended to ensure that any policies that exist on the system are activated.
* Set all profiles to enforce mode

Testing:
* `apparmor_status`: `*apparmor module is loaded*`

## 1.6.3: Ensure SELinux or AppArmor are installed
SELinux and AppArmor provide Mandatory Access Controls; without the system installed, only default DAC will be available.
* `apt-get install selinux apparmor`

Testing:
* `dpkg -s selinux apparmor`

## 1.7: Warning Banners
Presenting a warning message prior to the normal user login may assist in the prosecution fo trespassers on the computer system. Changing some of these login banners also has the side effect of hiding OS version information and other detailed system information from attackers attempting to target specific exploits at a system.

## 1.7.1: Command line warning banners
### 1.7.1.1: Ensure message of the day is configured properly
The contents of `/etc/motd` are displayed to users after login and fucntion as a message of the day for authenticated users. Warning messages inform users who are attemptint to login to the system of their legal status regarding the system and must include the name of the organization that owns the system and any monitoring policies that are in place.
* Edit `/etc/motd` according to the site policy, removing any instances of `\m`, `\r`, `\s`, `\v`

Testing:
* `egrep '(\\v|\\r|\\m|\\s)' /etc/motd`: N/A

### 1.7.1.2-1.7.1.6
Specifies 1.7.1.1-like configuration for `/etc/issue`, et cetera. These are not implemented because it is not relevant to the Cyber Patriot competition.

## 1.7.2: Ensure GDM login banner is configured
GDM is the GNOME Display Manager which handles graphical login for GNOME based systems. Warning messages inform users who are attemptint to login to the system of their legal status regarding the ysstem and must include the name of the organization that owns the system and any monitoring policies that are in place.
* Create the `/etc/dconf/profile/gdm` with the followign contents:
```
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
```
* Create or edit the `banner-message-enable` and `banner-message-text` options in `/etc/dconf/db/gdm.d/01-banner-message`:
```
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='Authorized uses only. ALl activity may be monitored and reported'
```
* Update the system databases: `dconf update`

Testing:
* Verify that `/etc/dconf/profile/gdm` exists and contains the following:
```
user-db:user
system-dm:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
```
* Verify that the `banner-message-enable` and `banner-message-text` options are configured in one of the files in the `/etc/dconf/db/gdm.d/` (`/etc/dconf/db/gdm.d/01-banner-message`) directory:
```
[org/gnome/login-screen]
banner-message-enable=true
banner-message-test='<banner message>'
```

## 1.8: Ensure update, patches, and additional security software are installed
Periodically patches are released for included software either due to security flaws or to include additional functionality. Newer patches may contain security enhancements that would not be available through the latest full update. As a result, it is recommended that the latest software patches be used to take advantage of the latest functionaliy. As with any software installation, organizations need to determine if a given update meets their requirements and verify the compatibility and supportability of any additional software against the update revision that is selected.
* `apt-get update && apt-get upgrade`

Testing:
* `apt-get -s upgrade`

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

## 4.1.1: Configure Data Retention
When auditing, it is important to carefully configure the storage requirements for audit logs. By default, auditd will max out the log files at 5MB and retain only 4 copies of them. Older versions will be deleted. It is possible on a system that the 20 MBs of audit logs may fill up the system causing loss of audit data. While the recommendations here provide guidance, check your site policy for audit storage requirements. This is not done in Bailey as it will have to be done on a machine/network basis.

## 4.1.2: Ensure auditd service is enabled
### `enable_auditd`
Turn on the `auditd` daemon to record system events. The capturing of system events provides system administrators with information to allow them to determine if unauthorized access to their system is occurring. To fix this we run:
* `systemctl enable auditd`

Testing:
* `systemctl is-enabled auditd`: enabled

## 4.1.3 Ensure auditing for processes that start prior to auditd is enabled
### `enable_auditd`
Configuring grub is recommended to make sure that all the processes that can be audited are capable of being audited even if they are started up before the auditd startup. This is important because the audit events need to be on processes that start up prior to the auditd start up so that all malicious activity can be detected.
* Edit /etc/default/grub and add audit=1 to make it `GRUB_CMDLINE_LINUX="audit=1"`
* Update the grub2 configuration using `update-grub`

Testing:
* `grep "^\s*linux" /boot/grub/grub.cfg`: audit=1

## 4.1.4 Ensure events that modify date and time information are collected
To do this, capture every time the date/time is being modified, which determines if the kernel clock, time of date, seconds, or clock set time have been executed, which will auto write to /var/log/audit.log with the identifier "time-change". Sadly, Bailey is not set up to process this data.

## 4.1.5 Ensure events that modify user/group information are collected
This will record the events that affect the group, password, shadow, and gshadow. The parameters set will see if any files have been opened to write or have had permission changes to them with the identifier "identity". Sadly, Bailey is not set up to process this data!

## 4.1.6 Ensure events that modify the system's network environment are collected
This records the changes to the network environment files, so files that affect the sethostname or setdomainname so it will write an audit event on the system files. This is important to monitor unauthorized changes to the host and domain name of the system which could break security parameters. Sadly, Bailey is not set up to process this data.

## 4.1.7 Ensure events that modify the system's Mandatory Access Controls are collected
This monitors the SELinux/APPArmor access controls, which will see if there is any changes made to /etc/selinux or /etc/apparmor and the /etc/apparmor.d directories, which is important to see if there are any authorized changes made to modify the controls. Sadly, Bailey is not set up to process this data.

## 4.1.8 Ensure login and logout events are collected
This monitors any login and logout events which will be tracked in the /var/log/faillog file. This will maintain the records whenever a user successfully logs in and will record failures through pam_tally2. Sadly, Bailey is not set up to process this data.
## 4.1.9 Ensure session initation information is collected
This monitors the initiation events, so any changes to the files through the file /var/run/utmp which will track all the logged in users, and the /var/log/wtmp file which tracks the login, logouts, shutdowns, and if the system rebooted. /var/log/btmp keeps track of all the failed login attempts with the identifier "session." Sadly, Bailey is not set up to process this data.

## 4.1.10 Ensure discretionary access control permission modification events are collected
This monitors changes to the file permissions or other attributes of the file, which is found through chmod, fchmod, and fchmodat which all can change the permissions of a file. This is important because it will alert an admin of any potentially unauthorized activity on files. Sadly, Bailey is not set up to process this data.

## 4.1.11 Ensure unsuccessful unauthorized file access attempts are collected
This monitors any unsuccessful attempts to access various files. This is important to make sure that only authorized users are getting into the files, and if there are failed instances of this, that could mean that someone who is unauthorized is trying to gain access to the system. Sadly, Bailey is not set up to process this data.

## 4.1.12 Ensure use of privileged commands is collected
This monitors the programs that required admin use to see if unauthorized users are truing to run these commands. This is important to make sure that unauthorized users aren't changing settings or getting access to the systems. Sadly, Bailey is not set up to process this data.

## 4.1.13 Ensure successful file system mounts are collected
This monitors the use of the mount system call which controls the mounting and unmounting of file systems. This is to make sure that unauthorized users aren't mounting file systems because it will give the administrator access to see if any standard users are doing this. Sadly, Bailey is not set up to process this data.
## 4.1.14 Ensure file deletion events by users are collected
This monitors any deletion/renaming of files and file attributions. This will log any instances of deletion or editing and will tag them with the identifier "delete." This is important to make sure that non-priviledged users aren't removing files or various file attributes. Sadly, Bailey is not set up to process this data.

## 4.1.15 Ensure changes to the system administration scope (sudoers) is collected
This monitors any changes to the system administration, because if it is configured properly to make sure that administrations have to log in first and then use sudo, then you can monitor any changes. This is through the file /etc/sudoers which records instances of this with the identifier "scope." Sadly, Bailey is not set up to process this data.

## 4.1.16 Ensure system administrator actions (sudolog) are collected
This monitors the sudo log file  through /var/log/sudo.log. So any time a command is executed, it will add to the file /var/log/sudo.log which is important to make sure that nothing is being tampered with, because any changes to the file will show that an administrator executed a command or it has been messed with. Sadly, Bailey is not set up to process this data.

## 4.2.1 Configure `rsyslog`
### `configure_rsyslog`
The `rsyslog` software is recommended as a replacement for the `syslogd` daemon and provides improvements over `syslogd`, such as connection-oriented (i.e. TCP) transmission of logs, the option to log to database formats, and the encryption of log data en route to a central logging server. Configuring advanced items is not done by Bailey as it is on a per system basis (4.2.1.2 Ensure logging is configured). You would want to configure logging because a great deal of important security-related information is sent via `rsyslog` (e.g., successful and failed su attempts, failed login attempts, root login attempts, etc.).
We also edit `/etc/rsyslog.conf` so that the `FileCrateMode` is set to `0640` or more restrictive. This is important to ensure that log files have the correct permissions to ensure that sensitive data is archived and protected.
Another important item to complete is setting up a remote log host. The `rsyslog` utility supports the ability to send logs it gathers to a remote log host running `syslogd(8)` or to receive messages from remote hosts, reducing administrative overhead. Storing log data on a remote host protects log integrity from local attacks. If an attacker gains root access on the local system, they could tamper with or remove log data that is stored on the local system. But, Bailey dose not provide this service as we can't automatically identify your remote host name [or if you even have one] (4.2.1.4 Ensure `rsyslog` is configured to send logs to a remote log host).
For the same reasons above Bailey doesn't complete `4.2.1.5`: Ensure remote `rsyslog` messages are only accepted on designated log hosts). But, this is still an important step because completing `4.2.1.5` ensures that remote log hosts are configured to only accept `rsyslog` data from hosts within the specified domain and that those systems that are not designed to be log hosts do not accept any remote `rsyslog` messages. This provides protection from spoofed log data and ensures that system administrators are reviewing reasonably complete syslog data in a central location.

## 5.1.1-7: Ensure permissions on /etc/cron.* are configured
### `configure_cron`
We first have to ensure that the `cron` service is running, we do this by running: `systemctl enable crond`
This set of files (crontab,cron.hourly,cron.daily,cron.weekly,cron.monthly,cron.d) contains information on what system jobs are run by cron. Write access to these files could provide unprivileged users with the ability to elevate their privileges. Read access to these files could provide users with the ability to gain insight on system jobs that run on the system and could provide them a way to gain unauthorized privileged access. This is implemented by running these commands:
* `chown root:root etc/cron.*`
* `chmod og-rwx etc/cron.*`

Testing:
* `systemctl is-enabled crond`: enabled
* `stat /etc/cron.*`: Access: (0600/-rw-------) Uid: ( 0/ root) Gid: ( 0/ root)

## 5.1.8: Ensure at/cron is restricted to authorized users
In this section we configure `/etc/cron.allow` and `/etc/at.allow` to allow specific users to use these services. If `/etc/cron.allow` or `/etc/at.allow` do not exist, then `/etc/at.deny` and `/etc/cron.deny` are checked. Any user not specifically defined in those files is allowed to use at and cron. By removing the files, only users in `/etc/cron.allow` and `/etc/at.allow` are allowed to use at and cron. Note that even though a given user is not listed in `cron.allow`, cron jobs can still be run as that user. The `cron.allow` file only controls administrative access to the crontab command for scheduling and modifying cron jobs. On many systems, only the system administrator is authorized to schedule cron jobs. Using the `cron.allow` file to control who can run cron jobs enforces this policy. It is easier to manage an allow list than a deny list. In a deny list, you could potentially add a user ID to the system and forget to add it to the deny files. This task is not completed in Bailey as it is specific for what admins a system network has.

## 5.2.1-15 (excluding 5.2.14): Ensure SSH settings are setup in a secure manner
SSH supports two different and incompatible protocols: SSH1 and SSH2. SSH1 was the original protocol and was subject to security issues. SSH2 is more advanced and secure.

## 5.2.14 Ensure SSH access is limited
There are several options available to limit which users and group can access the system via SSH. It is recommended that at least one of the following options be leveraged:
#### AllowUsers
The `AllowUsers` variable gives the system administrator the option of allowing specific users to ssh into the system. The list consists of comma separated user names. Numeric user IDs are not recognized with this variable. If a system administrator wants to restrict user access further by only allowing the allowed users to log in from a particular host, the entry can be specified in the form of user@host.
#### AllowGroups
The `AllowGroups` variable gives the system administrator the option of allowing specific groups of users to ssh into the system. The list consists of comma separated group names. Numeric group IDs are not recognized with this variable.
#### DenyUsers
The `DenyUsers` variable gives the system administrator the option of denying specific users to ssh into the system. The list consists of comma separated user names. Numeric user IDs are not recognized with this variable. If a system administrator wants to restrict user access further by specifically denying a user's access from a particular host, the entry can be specified in the form of user@host.
#### DenyGroups
The `DenyGroups` variable gives the system administrator the option of denying specific groups of users to ssh into the system. The list consists of comma separated group names. Numeric group IDs are not recognized with this variable.

Restricting which users can remotely access the system via SSH will help ensure that only authorized users access the system. This is very important but, is not done in Bailey.

## 6.1.1: Audit system file permissions
The Debian package manager has a number of useful options. One of these, the �verify option, can be used to verify that system packages are correctly installed. The �verify option can be used to verify a particular package or to verify all system packages. If no output is returned, the package is installed correctly. Sadly, Bailey is not set up to process this data. You will need to go in and run: `dpkg --verify`. Then you, the user, will need to go in and fix any problems that are happening with the packages.

## 6.1.2-9: Ensure file permissions on `/etc/*` are configured
### `configuring_file_permissions`
The `/etc/*` files contain user information that is used by many system utilities and security applications and therefore must be readable for these utilities to operate. For each separate file that is listed, there is a different set of recommended settings. This can be completed by running:
* `chown root:* /etc/*`
* `chmod * /etc/*`

Testing:
* `stat /etc/*`: `Access: (*) Uid: ( 0/ root) Gid: ( 0/ *)`

## 6.1.10: Ensure no world writable files exist
Unix-based systems support variable settings to control access to files. World writable files are the least secure. See the `chmod(2)` man page for more information. Data in world-writable files can be modified and compromised by any user on the system. World writable files may also indicate an incorrectly written script or program that could potentially be the cause of a larger compromise to the system's integrity. But, Bailey dose not provide this service as we can't automatically identify the settings that the user needs.

<<<<<<< HEAD
## 6.1.11
Sometimes when administrators delete users from the password file they neglect to remove all files owned by those users from the system. A new user who is assigned the deleted user's user ID or group ID may then end up �owning� these files, and thus have more access on the system than was intended. But, Bailey dose not provide this service as we can't automatically identify the settings that the user needs.
=======
## 6.1.11: Ensure no unowned files or directories exist
Sometimes when administrators delete users from the password file they neglect to remove all files owned by those users from the system. A new user who is assigned the deleted user's user ID or group ID may then end up �owning� these files, and thus have more access on the system than was intended. But, Bailey dose not provide this service as we can't automatically identify the settings that the user needs.

## 6.1.12: Ensure no ungrouped files or directories exist
Sometimes when administrators delete users or groups from the system they neglect to remove all files owned by those users or groups. A new user who is assigned the deleted user's user ID or group ID may then end up �owning� these files, and thus have more access on the system than was intended. But, Bailey dose not provide this service as we can't automatically identify the settings that the user needs.

## 6.1.13: Audit SUID executables
The owner of a file can set the file's permissions to run with the owner's or group's permissions, even if the user running the program is not the owner or a member of the group. The most common reason for a SUID program is to enable users to perform functions (such as changing their password) that require root privileges. There are valid reasons for SUID programs, but it is important to identify and review such programs to ensure they are legitimate. But, Bailey dose not provide this service as we can't automatically identify the settings that the user needs.

## 6.1.14: Audit SGID executables
The owner of a file can set the file's permissions to run with the owner's or group's permissions, even if the user running the program is not the owner or a member of the group. The most common reason for a SGID program is to enable users to perform functions (such as changing their password) that require root privileges. There are valid reasons for SGID programs, but it is important to identify and review such programs to ensure they are legitimate. Review the files returned by the action in the audit section and check to see if system binaries have a different md5 checksum than what from the package. This is an indication that the binary may have been replaced. But, Bailey dose not provide this service as we can't automatically identify the settings that the user needs.
>>>>>>> 9ad898fea7f630332f5048e6d6d0cddb5480e72e
