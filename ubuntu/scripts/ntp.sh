#!/usr/bin/env bash

########################################################################
# Script  : Configure NTP.
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

begin_msg "Configuring NTP..."

# set timezone
timedatectl set-timezone $TIMEZONE
timedatectl status

# install ntp
apt-get install -y ntp

# configure ntp
cp -vf /etc/ntp.conf /etc/ntp.conf.bak
cp -vf $(get_config_dir)/ntp.conf /etc/ntp.conf

print_content "/etc/ntp.conf"

# enable ntp to start on boot
systemctl enable ntp
systemctl restart ntp
systemctl status ntp --no-pager

# clean up
apt-get clean
rm -rf /tmp/* /var/tmp/*

success_msg "NTP configured!"
