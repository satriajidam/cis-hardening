#!/usr/bin/env bash

########################################################################
# Script  : Setup Uncomplicated Firewall.
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

begin_msg 'Enabling Uncomplicated Firewall...'

ufw --force reset
ufw --force enable

success_msg 'Uncomplicated Firewall enabled!'

begin_msg 'Configuring Uncomplicated Firewall...'

configure_firewall

systemctl status ufw --no-pager
ufw status verbose

success_msg 'Uncomplicated Firewall configured!'
