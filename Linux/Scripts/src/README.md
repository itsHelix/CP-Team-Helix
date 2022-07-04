**Warning:** As of May 2022, Bailey is abandoned by its maintainers, but remains open to any contributor who may be interested in its vision. For any inquiries, please open a pull request or contact an author.

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
