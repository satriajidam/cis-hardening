#!/usr/bin/env bash

########################################################################
# Script  : Configure cron.
# OSs     : - Ubuntu 16.04
# Authors : - Agastyo Satriaji Idam (play.satriajidam@gmail.com)
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

begin_msg 'Configuring cron...'

rm -f /etc/cron.deny
rm -f /etc/at.deny

echo 'root' > /etc/cron.allow
echo 'root' > /etc/at.allow

chown -v root:root /etc/cron*
chmod -v og-rwx /etc/cron*

chown -v root:root /etc/at*
chmod -v og-rwx /etc/at*

success_msg 'Cron configured!'

begin_msg 'Enabling cron...'

systemctl daemon-reload

systemctl enable cron
systemctl restart cron
systemctl status cron --no-pager

systemctl enable atd
systemctl restart atd
systemctl status atd --no-pager

success_msg 'Cron enabled!'
