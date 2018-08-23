#!/usr/bin/env bash

########################################################################
# Script  : Configure Systemd.
# OSs     : - Ubuntu 16.04
# Authors : - Agastyo Satriaji Idam (play.satriajidam@gmail.com)
#           - Nashihun Amien (nashihunamien@gmail.com)
########################################################################

set -o errexit # make script exits when a command fails
set -o pipefail # make script exits when the rightmost command of a pipeline exits with non-zero status
set -o nounset # make script exits when it tries to use undeclared variables
# set -o xtrace # trace what gets executed for debugging purpose

# ensure running as root
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@"
  exit $?
fi

begin_msg "Configuring systemd..."

# configure system.conf
# ref: https://github.com/konstruktoid/hardening/blob/master/systemd.adoc#etcsystemdsystemconf
sed -i.bak \
  -e 's/^#DumpCore=.*/DumpCore=no/' \
  -e 's/^#CrashShell=.*/CrashShell=no/' \
  -e 's/^#DefaultLimitCORE=.*/DefaultLimitCORE=0/' \
  -e 's/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1024/' \
  -e 's/^#DefaultLimitNPROC=.*/DefaultLimitNPROC=1024/' \
  /etc/systemd/system.conf

print_content "/etc/systemd/system.conf"

# configure user.conf
# ref: https://github.com/konstruktoid/hardening/blob/master/systemd.adoc#etcsystemduserconf
sed -i.bak \
  -e 's/^#DefaultLimitCORE=.*/DefaultLimitCORE=0/' \
  -e 's/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1024/' \
  -e 's/^#DefaultLimitNPROC=.*/DefaultLimitNPROC=1024/' \
  /etc/systemd/user.conf

print_content "/etc/systemd/user.conf"

systemctl daemon-reload

success_msg "Systemd configured!"
