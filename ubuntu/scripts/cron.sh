#!/usr/bin/env bash

########################################################################
# Script  : Configure at/cron.
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

begin_msg "Configuring at/cron..."

rm -f /etc/cron.deny
rm -f /etc/at.deny

echo 'root' > /etc/cron.allow
echo 'root' > /etc/at.allow

chown -v root:root /etc/cron*
chmod -v og-rwx /etc/cron*

chown -v root:root /etc/at*
chmod -v og-rwx /etc/at*

sed -i.bak 's/^#cron./cron./' /etc/rsyslog.d/50-default.conf

print_content "/etc/rsyslog.d/50-default.conf"

systemctl daemon-reload

systemctl enable cron
systemctl restart cron
systemctl status cron --no-pager

systemctl enable atd
systemctl restart atd
systemctl status atd --no-pager

success_msg "at/cron configured!"
