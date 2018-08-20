#!/usr/bin/env bash

########################################################################
# Script  : Configure logrotate & journalctl.
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

begin_msg "Configure logrotate..."

# configure logrotate.conf
cp -vf /etc/logrotate.conf /etc/logrotate.conf.bak
cp -vf $(get_config_dir)/logrotate.conf /etc/logrotate.conf

print_content "/etc/logrotate.conf"

success_msg "Logrotate configured!"

# ref: https://github.com/konstruktoid/hardening/blob/master/systemd.adoc#etcsystemdjournaldconf

begin_msg "Configure journalctl..."

# configure journald.conf
sed -i.bak \
  -e 's/^#Storage=.*/Storage=persistent/' \
  -e 's/^#ForwardToSyslog=.*/ForwardToSyslog=yes/' \
  -e 's/^#Compress=.*/Compress=yes/' \
  /etc/systemd/journald.conf

print_content "/etc/systemd/journald.conf"

systemctl restart systemd-journald
systemctl status systemd-journald --no-pager

success_msg "Journalctl configured!"
