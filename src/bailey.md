# Bailey
A standard-based, organized hardening script for Ubuntu 14-18 and Debian 7-9.

This document serves as a line-group documentation of the script, as well as, commentary on its ecosystem and uses.

Bailey is the result of work done by countless people. Notable contributions are attributed to:
* [Abhinav Vemulapalli](https://github.com/nandanav), for his work on `telluride.sh` and `avon.sh`
* [pyllyukko](https://github.com/pyllyukko) for his work on `user.js`, which is aliased in this work
* [Tavin Turner](https://github.com/itsTurner) for his work on `telluride.sh`, `estes.sh`, `avon.sh`, and Bailey

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

# CIS Ubuntu 16
## Implemented Standards
| Section | Suggestion (X.X...) | Implemented (# of functions) |
| ------- | ------------------- | ---------------------------- |
| Filesystem configuration | 1.1.1 | Yes (6) |
| Filesystem configuration | 1.1.2-1.1.19 | No |
| Filesystem configuration | 1.1.20 | Yes |
| Filesystem configuration | 1.1.21 | Yes |
| Configure software updates | 1.2.1 | Yes |

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
* df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t

Testing:
* `df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null`: N/A

## 1.1.21: Disable Automounting
### `disable_automatic_mounting`
Automounting allows anybody with physical access to attach a USB drive or disc to execute its contents in the system, even if they lacked permission to mount it themselves. To remedy this we execute:
* `systemctl disable autofs`

Testing:
* `systemctl is-enabled autofs`: `disabled`

## 1.2.1: Ensure package manager repositories are configured
