# Bailey
A standard-based, organized hardening script for Ubuntu 14-18 and Debian 7-9.

This document serves as a line-group documentation of the script, as well as, commentary on its ecosystem and uses.

Bailey is the result of work done by countless people. Notable contributions are attributed to:
* [Abhinav Vemulapalli](https://github.com/nandanav), for his work on `telluride.sh` and `avon.sh`
* [pyllyukko](https://github.com/pyllyukko) for his work on `user.js`, which is aliased in this work
* [Tavin Turner](https://github.com/itsTurner) for his work on `tellurise.sh`, `estes.sh`, `avon.sh`, and Bailey

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

# CIS Implementations in Bailey
## 1.1.1: Disable unused filesystems
### `filesystem_mounting_disabled`
* Appends `install [filesystem] /bin/true` to the end of `/etc/modprobe.d/[filesystem].conf` to disable use of the filesystem
* Run `rmmod [filesystem]` to apply changes to the filesystem

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
