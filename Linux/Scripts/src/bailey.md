# Bailey
A standard-based, organized hardening script for Ubuntu 14-18 and Debian 7-9.

This document serves as a line-group documentation of the script, as well as, commentary on its ecosystem and uses.

Bailey is the result of work done by countless people. Notable contributions are attributed to:
* [Abhinav Vemulapalli](https://github.com/nandanav), for his work on `telluride.sh` and `avon.sh`
* [pyllyukko](https://github.com/pyllyukko) for his work on `user.js`, which is aliased in this work
* [Tavin Turner](https://github.com/itsTurner) for his work on `telluride.sh`, `estes.sh`, `avon.sh`, and `Bailey`
* [Ian](https://stackoverflow.com/users/11013589/cutwow475) [Boraks](https://github.com/Cutwow) for his work on `Bailey` (and forcing everyone else to do their part)
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

## `ensure_readme`
Ensures that the README has been properly retrieved and exists as a file, with a variable (`readme_location`) referencing it.
* Tests if variable `readme_location` is filled
	* If it is, continues script normally
	* If it is not:
		* CURLs from user input, output into file
		* Assign file direction to variable `readme_location`
		* Confirms content with user
			* If correct, continues script normally
			* If not correct, asks for manual user input of content

## `ncis_readme_parsing`
Integrated in the middle of a CIS section, `ncis` represents that it is not listed in the benchmark. Creates four files from the README:
* `users_over_1000`: a list of non-root users (i.e. UID≥1000)
	* Should be empty with the exception of `root`. For the sake of the functions using it, appends `root` to the end to exempt it from detrimental enforcement
* `authorized_administrators`: a list of all README-specified administrators
* `admin_users`: a list of all users in the `sudo` group
* `0_uid_users`: a list of all users with the UID 0 (root UID)

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

## 3.1.X: Network Parameters (Host Only)
### `disable_ip_forwarding` and `disable_packet_redirect`
Disabling IP forwarding is very important. Disabling this setting ensures that a system with multiple interfaces (for example, a hard proxy), will never be able to forward packets, and therefore, never serve as a router.
Ensuring packets are not redirected is equally as important. An attacker could use a compromised host to send invalid ICMP redirects to other router devices in an attempt to corrupt routing and have users access a system set up by the attacker as opposed to a valid system. To fix these two problems we run:
* `sysctl -w net.ipv4.ip_forward=0` and `sysctl -w net.ipv4.conf.all.send_redirects=0` `sysctl -w net.ipv4.conf.default.send_redirects=0` respectively

Testing:
* `sysctl net.ipv4.conf.all.send_redirects`: 0
* `sysctl net.ipv4.conf.default.send_redirects`: 0
* `sysctl net.ipv4.ip_forward`: 0

## 3.2.1: Ensure source routed packets are not accepted
### `isable_accepting_routed_packets`
In networking, source routing allows a sender to partially or fully specify the route packets take through a network. In contrast, non-source routed packets travel a path determined by routers in the network. In some cases, systems may not be routable or reachable from some locations (e.g. private addresses vs. Internet routable), and so source routed packets would need to be used. Setting `net.ipv4.conf.all.accept_source_route` and `net.ipv4.conf.default.accept_source_route` to `0` disables the system from accepting source routed packets. Assume this system was capable of routing packets to Internet routable addresses on one interface and private addresses on another interface. Assume that the private addresses were not routable to the Internet routable addresses and vice versa. Under normal routing circumstances, an attacker from the Internet routable addresses could not use the system as a way to reach the private address systems. If, however, source routed packets were allowed, they could be used to gain access to the private address systems as the route could be specified, rather than rely on routing protocols that did not allow this routing. To fix this we run:
* `sysctl -w net.ipv4.conf.all.accept_source_route=0`
* `sysctl -w net.ipv4.conf.default.accept_source_route=0`

Testing:
* `sysctl net.ipv4.conf.all.accept_source_route`: 0
* `sysctl net.ipv4.conf.default.accept_source_route`: 0

## 3.2.2: Ensure ICMP redirects are not accepted
### `disable_accepting_of_ICMP_redirects`
ICMP redirect messages are packets that convey routing information and tell your host (acting as a router) to send packets via an alternate path. It is a way of allowing an outside routing device to update your system routing tables. By setting `net.ipv4.conf.all.accept_redirects` to `0`, the system will not accept any ICMP redirect messages, and therefore, won't allow outsiders to update the system's routing tables. Attackers could use bogus ICMP redirect messages to maliciously alter the system routing tables and get them to send packets to incorrect networks and allow your system packets to be captured. To fix this we:
* `sysctl -w net.ipv4.conf.all.accept_redirects=0`
* `sysctl -w net.ipv4.conf.default.accept_redirects=0`

Testing:
* `sysctl net.ipv4.conf.all.accept_redirects`: 0
* `sysctl net.ipv4.conf.default.accept_redirects`: 0

# 3.2.3: Ensure secure ICMP redirects are not accepted
### `disable_accepting_of_ICMP_redirects`
Secure ICMP redirects are the same as ICMP redirects (see 3.2.2), except they come from gateways listed on the default gateway list. It is assumed that these gateways are known to your system, and that they are likely to be secure. To fix we run:
* `sysctl -w net.ipv4.conf.all.secure_redirects=0`
* `sysctl -w net.ipv4.conf.default.secure_redirects=0`

Testing:
* `sysctl net.ipv4.conf.all.secure_redirects`: 0
* `sysctl net.ipv4.conf.default.secure_redirects`: 0

## 3.2.4: Ensure suspicious packets are logged
### `enable_logging_of_packets`
When enabled, this feature logs packets with un-routable source addresses to the kernel log. Enabling this feature and logging these packets allows an administrator to investigate the possibility that an attacker is sending spoofed packets to their system. To turn this on we run:
* `sysctl -w net.ipv4.conf.all.log_martians=1`
* `sysctl -w net.ipv4.conf.default.log_martians=1`

Testing:
* `sysctl net.ipv4.conf.all.log_martians`: 1
* `sysctl net.ipv4.conf.default.log_martians`: 1

## 3.2.5: Ensure broadcast ICMP requests are ignored
### `ignore_ICMP_requests`
Accepting ICMP echo and timestamp requests with broadcast or multicast destinations for your network could be used to trick your host into starting (or participating) in a Smurf attack. A Smurf attack relies on an attacker sending large amounts of ICMP broadcast messages with a spoofed source address. All hosts receiving this message and responding would send echo-reply messages back to the spoofed address, which is probably not routable. If many hosts respond to the packets, the amount of traffic on the network could be significantly multiplied. Setting `net.ipv4.icmp_echo_ignore_broadcasts` to `1` will cause the system to ignore all ICMP echo and timestamp requests to broadcast and multicast addresses. To do this we run:
* `sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1`

Testing:
* `sysctl net.ipv4.icmp_echo_ignore_broadcasts`: 1

## 3.2.6: Ensure bogus ICMP responses are ignored
### `ignore_ICMP_requests`
Some routers (and some attackers) will send responses that violate RFC-1122 and attempt to fill up a log file system with many useless error messages. Setting `icmp_ignore_bogus_error_responses` to `1` prevents the kernel from logging bogus responses (RFC-1122 non-compliant) from broadcast reframes, keeping file systems from filling up with useless log messages. To do this we run:
* `sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1`

Testing:
* `sysctl net.ipv4.icmp_ignore_bogus_error_responses`: 1

## 3.2.7: Ensure Reverse Path Filtering is enabled
### `enable_reverse_path_filtering`
Setting these flags for path filtering is a good way to deter attackers from sending your system bogus packets that cannot be responded to. One instance where this feature breaks down is if asymmetrical routing is employed. This would occur when using dynamic routing protocols (bgp, ospf, etc) on your system. If you are using asymmetrical routing on your system, you will not be able to enable this feature without breaking the routing. Setting `net.ipv4.conf.all.rp_filter` and `net.ipv4.conf.default.rp_filter` to `1` forces the Linux kernel to utilize reverse path filtering on a received packet to determine if the packet was valid. Essentially, with reverse path filtering, if the return packet does not go out the same interface that the corresponding source packet came from, the packet is dropped (and logged if log_martians is set). To do this we run:
* `sysctl -w net.ipv4.conf.all.rp_filter=1`
* `sysctl -w net.ipv4.conf.default.rp_filter=1`

Testing:
* `sysctl net.ipv4.conf.all.rp_filter`: 1
* `sysctl net.ipv4.conf.default.rp_filter`: 1

## 3.2.8: Ensure TCP SYN Cookies is enabled
### `enable_TCP_SYN_cookies`
Attackers use SYN flood attacks to perform a denial of service attacked on a system by sending many SYN packets without completing the three way handshake. This will quickly use up slots in the kernel's half-open connection queue and prevent legitimate connections from succeeding. SYN cookies allow the system to keep accepting valid connections, even if under a denial of service attack. When `tcp_syncookies` is set to `1`, the kernel will handle TCP SYN packets normally until the half-open connection queue is full, at which time, the SYN cookie functionality kicks in. SYN cookies work by not using the SYN queue at all. Instead, the kernel simply replies to the SYN with a SYN|ACK, but will include a specially crafted TCP sequence number that encodes the source and destination IP address and port number and the time the packet was sent. A legitimate connection would send the ACK packet of the three way handshake with the specially crafted sequence number. This allows the system to verify that it has received a valid response to a SYN cookie and allow the connection, even though there is no corresponding SYN in the queue. To do this we run:
* `sysctl -w net.ipv4.tcp_syncookies=1`

Testing:
* `sysctl net.ipv4.tcp_syncookies`: 1

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
This monitors any deletion/renaming of files and file attributions. This will log any instances of deletion or editing and will tag them with the identifier "delete". This is important to make sure that non-priviledged users aren't removing files or various file attributes. Sadly, Bailey is not set up to process this data.

## 4.1.15 Ensure changes to the system administration scope (sudoers) is collected
This monitors any changes to the system administration, because if it is configured properly to make sure that administrations have to log in first and then use sudo, then you can monitor any changes. This is through the file /etc/sudoers which records instances of this with the identifier "scope". Sadly, Bailey is not set up to process this data.

## 4.1.16 Ensure system administrator actions (sudolog) are collected
This monitors the sudo log file  through /var/log/sudo.log. So any time a command is executed, it will add to the file /var/log/sudo.log which is important to make sure that nothing is being tampered with, because any changes to the file will show that an administrator executed a command or it has been messed with. Sadly, Bailey is not set up to process this data.

## 4.1.17 Ensure kernel module loading and unloading is collected
This monitors the loading and unloading of the kernels, so it will use insmod, rmmod, and modprobe to control the loading/unloading of the modules. The system calls init_module and delete_module will cause an audit record with the identifier "modules". This is important to make sure that no unauthorized user is loading or unloading a kernel module, which would potentially endanger the security. Sadly, Bailey is not set up to process this data.

## 4.1.18 Ensure the audit configuration is immutable
### `configure_audit`
This will set the system audit to make sure that the audit rules aren't able to be modified with auditctl. Adding "-e 2" will make it so that the audit is in immutable mode, so any audit changes can only be made on the system reboot. This is important because it will make sure that unauthorized users can't execute any changes to the audit system.
* Add "-e 2" to the end of /etc/audit/audit.rules file

Testing:
*  `grep `^\s*[^#]` /etc/audit/audit.rules | tail -1`: -e 2

## 4.2.1 Configure `rsyslog`
### `configure_rsyslog`
The `rsyslog` software is recommended as a replacement for the `syslogd` daemon and provides improvements over `syslogd`, such as connection-oriented (i.e. TCP) transmission of logs, the option to log to database formats, and the encryption of log data en route to a central logging server. Configuring advanced items is not done by Bailey as it is on a per system basis (4.2.1.2 Ensure logging is configured). You would want to configure logging because a great deal of important security-related information is sent via `rsyslog` (e.g., successful and failed su attempts, failed login attempts, root login attempts, etc.).
We also edit `/etc/rsyslog.conf` so that the `FileCrateMode` is set to `0640` or more restrictive. This is important to ensure that log files have the correct permissions to ensure that sensitive data is archived and protected.
Another important item to complete is setting up a remote log host. The `rsyslog` utility supports the ability to send logs it gathers to a remote log host running `syslogd(8)` or to receive messages from remote hosts, reducing administrative overhead. Storing log data on a remote host protects log integrity from local attacks. If an attacker gains root access on the local system, they could tamper with or remove log data that is stored on the local system. But, Bailey dose not provide this service as we can't automatically identify your remote host name [or if you even have one] (4.2.1.4 Ensure `rsyslog` is configured to send logs to a remote log host).
For the same reasons above Bailey doesn't complete `4.2.1.5`: Ensure remote `rsyslog` messages are only accepted on designated log hosts). But, this is still an important step because completing `4.2.1.5` ensures that remote log hosts are configured to only accept `rsyslog` data from hosts within the specified domain and that those systems that are not designed to be log hosts do not accept any remote `rsyslog` messages. This provides protection from spoofed log data and ensures that system administrators are reviewing reasonably complete syslog data in a central location.

## 4.2.2 Configure syslog-ng
This is only applicable if syslog-ng is installed on the system. After installing the package, you need to activate it, which is important because if it isn't activated on the system, it will default to syslogd. To enable syslog-ng, type `update-rc.d syslog-ng enable`. To ensure loggingin is configured (4.2.2.2) the /etc/syslog-ng/syslog-ng.conf file will show the rules for logging and which files to use to log different circumstances. This is important because various security related information is sent via syslog-ng. To do this, you edit the log lines in /etc/syslog-ng/syslog-ng.conf for your environment. Sadly, Bailey is not set up to process this data. To ensure file permissions are configured (4.2.2.3), syslog-ng will create the logfiles that don't already exist on the system. The setting itself sets what permissions will be applied to the new files. To ensure syslog-ng is configured to send logs to a remove log host (4.2.2.4), you have to review the /etc/syslog-ng/syslog-ng.conf file to see that the logs are sent to a central host. This will send logs to a remote log host, which is important to protect from local attacks, because of an unauthorized attacker has root access to the system, they could remove or change log data. To do this, you need to review the /etc/syslog-ng/syslog-ng.conf to see that the logs are set to a central host, if not, then edit the file and add in the central host name. To ensure remote syslog-ng messages are only accepted on designated log hosts (4.2.2.5) you have to review the file once again and add lines to the file that will ensure that it will listen for log messages.

## 4.2.3 Ensure rsyslog or syslog-ng is installed
### `install_rsyslog_syslog-ng`
Both of these softwares are recommended to replace syslogd daemon, which is important because it has many security enhancements such as the encryption of log data, the trasmission of logs, and other factors.
* To install rsyslog or syslog-ng, type `apt-get install rsyslog` or `apt-get install syslog-ng`

Testing:
* `dpkg -s rsyslog`
* `dpkg -s syslog-ng`

## 4.2.4 Ensure permissions on all logfiles are configured
### `configure_logfiles`
Configuring log files is important to make sure that they have the correct permissions to make sure that the data that needs to be safe is protected.
* To set permissions, type `chmod -R g-wx,o-rwx /var/log/*`

Testing:
* `find /var/log -type f -ls`

## 4.3 Ensure logrotate is configured
### `configure_logrotate`
This makes sure to avoid filling the system up with logs as it will rotate them to make sure that they are manageable. This is important so that administrators can easily archive the files and also look at them more efficiently to save time. To do this, you have to edit the file /etc/logrotate.conf and /etc/logrotate.d/* to make sure that they are rotated to company policy. Sadly, Bailey is not set up to process this data.

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

## 6.2.1 Ensure password fields are not empty
### `fill_password_fields`
Fills empty or insecure password fields with the same password, qualifying safety standards tested by Cyber Patriot and prevent potential massive vulnerabilities, despite every single user having the same password.
Prerequisite: `ensure_readme` (incl. `ncis_readme_parsing`)
* For each user over UID 1000, assigns standard password.
* Logs changed password with username and password it was changed to

Testing:
* Intentionally unimplemented to avoid user error interference. Test by hand
	* `cat /etc/shadow | awk -f '($2 == "") { print $1 " does not have a password " }'`: N/A

## 6.2.2 Ensure no legacy "+" entries exist in /etc/passwd
### `remove_legacy"+"`
You can insert data through the + character from NIS maps, and so these would be an entry for attackers to gain privilege on the system, so it is important to remove these points of entry.
* Simply go through and remove any legacy "+" entries from the /etc/passwd file.

Testing:
* `grep '^+:' /etc/passwd`

## 6.2.3 Ensure no legacy "+" entries exist in /etc/shadow
### `remove_legacy"+"`
You can insert data through the + character from NIS maps, and so these would be an entry for attackers to gain privilege on the system, so it is important to remove these points of entry.
* Simply go through and remove any legacy "+" entries from the /etc/shadow file.

Testing:
* `grep '^+:' /etc/shadow`

## 6.2.4 Ensure no legacy "+" entries exist in /etc/group
### `remove_legacy"+"`
You can insert data through the + character from NIS maps, and so these would be an entry for attackers to gain privilege on the system, so it is important to remove these points of entry.
* Simply go through and remove any legacy "+" entries from the /etc/group file.

Testing:
* `grep '^+:' /etc/group`

## 6.2.5 Ensure root is the only UID 0 account
### `configure_UID_0`
Any UID 0 account has superuser privileges on the system, so access should only be like that for the root account, otherwise an unapproved user can get onto the system and change system settings.
* Remove any users other than the root user with UID 0 or assign them another UID

Testing:
* `cat /etc/passwd | awk -F: '($3 == 0) { print $1 }'`: root

## 6.2.6 Ensure root PATH Integrity
This is important to ensure that the root user isn't fooled into executing programs unintentionally. If a current working directory or any other writables are in the executable path, it makes it really easy for an attacker to force an admin to execute a Trojan horse program. Sadly, Bailey is not set up to process this data.

## 6.2.7 Ensure all users' home directories exist
If a home directory does not exist on a user, then the user will not be able to write any files, so in /etc/passwd, users can be identified as not having a home directory. Sadly, Bailey is not set up to process this data.

## 6.2.8 Ensure users' home directories permissions are 750 or more restrictive
Having the permissions set really high for normal users may permit malicious activity, so to prevent this, you have to change the privileges to make sure that no standard user is able to steal or modify other users' data. Sadly, Bailey is not set up to process this data.

## 6.2.9 Ensure users own their home directories
This makes sure that a users home directory is defined for that particular user. This is important because the user needs to be able to access their own folders. Sadly, Bailey is not set up to process this data.

## 6.2.10 Ensure users' dot files are not group or world writables
With current settings, users can easily override the permissions for user dot files. This makes it so that any group/world-writable files do not exist to ensure safety for the files. Sadly, Bailey is not set up to process this data.

# 6.2.11 Ensure no users have .forward files
The .forward command allows an email address to appear to forward an email to, which poses a security threat with privacy. It can also be used to execute commands that may perform unintended actions. Sadly, Bailey is not set up to process this data.

## 6.2.12 Ensure no users have .netrc files
The .netrc file has data to log into a remote host for file transfers, and it contains passwords in unencrypted form, which makes it a significant security risk. Sadly, Bailey is not set up to process this data.

## 6.2.13 Ensure users' .netrc Files are not group or world accessible
With current settings, users can easily override the permissions for .netrc files, which presents a serious security risk because it contains password information that could be used to attack the system. Sadly, Bailey is not set up to process this data.

## 6.2.14 Ensure no users have .rhosts files
It is really easy for users to create .rhosts files, and these files could possibly contain information that is useful to attack the system. Sadly, Bailey is not set up to process this data.

## 6.2.15 Ensure all groups in /etc/passwd exist in /etc/group
Errors can be made where there is a user that is in /etc/passwd but not in /etc/group, which poses a seucrity risk because all group permissions are not properly managed. Sadly, Bailey is not set up to process this data.

## 6.2.16 Ensure no duplicate UIDs exist
It is really easy for an administrator to edit the /etc/passwd file to make it so that two users have the same UID, which presents a security risk because then people need to make sure they have appropriate access protections. Sadly, Bailey is not set up to process this data.

## 6.2.17 Ensure no duplicate GIDs exist
It is really easy for an administrator to edit the /etc/passwd file to make it so that two users have the same GID, which presents a security risk because then people need to make sure they have appropriate access protections. Sadly, Bailey is not set up to process this data.

## 6.2.18 Ensure no duplicate user names exist
It is really easy for an administrator to edit the /etc/passwd file to make it so that two users share the first UID, which could pose a security issue if the first UID has more permissions than the second user. Sadly, Bailey is not set up to process this data.

## 6.2.19 Ensure no duplicate group names exist
It is really easy for an administrator to edit the /etc/passwd file to make it so that two of the same group name exist, which presents a security risk because then both groups will have the same access as the first GID, which could present a security risk. Sadly, Bailey is not set up to process this data.

## 6.2.20 Ensure shadow group is empty
### `empty_shawdow_group`
Any user within the shadow group has access to read the /etc/shadow file, which presents a security risk because the /etc/shadow file makes it really easy for an attacker to user a password cracking program to get the password for admin, which will hurt the security of the device.
* Remove all the users present in the shadow group, and make sure to change the primary group of any users with shadow as theirs.
Testing:
* `grep ^shadow:[^:]*:[^:]*:[^:]+ /etc/group`: N/A
* `awk -F: '($4 == "<shadow-gid>") { print }' /etc/passwd`: N/A

# Auxiliary File Configurations
## OpenSSH file
### Port number
The default port (22/tcp) is a brute force target; thus, the ssh daemon is configured to run on an alternative port (69420/tcp).
* `Port 69420`

### Compression after authentication
To eliminate a risk of compression exploitation, compression is exploited until after authentication.
* `Compression delayed`

### Idle log out timeout interval
To avoid an unattended ssh session, timeout after 5 minutes idle.
* `ClientAliveInterval 300`
* `ClientAliveCountMax 0`

### Strict mode
Using strict mode you can enforce some checks on important files inside users’ home directory have the proper privileges and ownership, SSH daemon will only allow a remote user to log on if checks pass. It is suggested to enable strict mode editing sshd_config file and enabling StrictModes.
* `StrictModes yes`

### Disable rhosts
`rsh` is historically unsafe, so disabling it is recommended.
* `IgnoreRhosts yes`

### Disable challenge response
By PAM authentication, challenge response authentication should be disabled to evade undefined behavior and unwanted authentication.
* `ChallengeResponseAuthentication no`

### Disable empty passwords
Explicitly disallow remote login from accounts with empty passwords.
* `PermitEmptyPasswords no`

### Disable gateway for forwarded ports
To prevent other remote hosts from connecting to forwarded ports, ssh binds local port forwardings to the loopback address only.
* `GatewayPorts no`

### Disable host-based authentication
It is suggested to disable host-based authentication with the `HostbasedAuthentication` command.
* `HostbasedAuthentication no`

### Disable password authentication
By default SSH can use keys or password to provide authentication, passwords are prone to brute force attacks. It is suggested to use keys only and completely disable password-based logins.
* `PasswordAuthentication no`

### Use SSHv2
SSHv1 suffers man-in-the-middle attacks among other vulnerabilities and should be disabled.
* `Protocol 2`

### Disable root login
It is suggested to disable root login via SSH to avoid publically offering root privileges.
* `PermitRootLogin no`

### 