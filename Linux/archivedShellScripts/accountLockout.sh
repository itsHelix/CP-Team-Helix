#!/bin/bash

ltc() {
  echo \(0_0\) $1
  log $1
}

ask() {
  echo \(o.o\) $1
  read resp
  local res=resp
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

ltc "Make sure you are running this as a last resort. If it gives you points, good. Otherwise run again and disable."

if [ ask "Enable/Disable Account Lockout Policies (e/d)" = e ]; then
  echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800" >> /etc/pam.d/common-auth
else
  sed '/auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800/d' /etc/pam.d/common-auth
fi
