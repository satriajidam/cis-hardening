#!/usr/bin/env bash

########################################################################
# Script  : AppArmor configuration.
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

begin_msg 'Enabling AppArmor...'

systemctl enable apparmor
systemctl restart apparmor
systemctl status apparmor --no-pager

success_msg 'AppArmor enabled!'

begin_msg 'Installing AppArmor utilities...'

apt-get install -y apparmor-utils

success_msg 'AppArmor utilities installed!'

begin_msg 'Forcing AppArmor profiles...'

find /etc/apparmor.d/ -maxdepth 1 -type f -exec aa-enforce {} \;
aa-complain /etc/apparmor.d/usr.sbin.rsyslogd
aa-status

success_msg 'AppArmor profiles forced!'
