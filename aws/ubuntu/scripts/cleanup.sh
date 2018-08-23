#!/usr/bin/env bash

########################################################################
# Script  : Provisioning clean up.
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

# clean up
apt-get clean -q
rm -rf /tmp/* /var/tmp/*

# run rkhunter check
if [ $RKHUNTER_ON_DONE -eq 1 ]; then
  # Rkhunter returns non-zero exit code even though
  # the execution doesn't really ends up in an error.
  # So it's necessary to put 'true' to force the exit
  # code to zero so the script execution doesn't stop
  # halfway.
  rkhunter --check --skip-keypress || true
fi

# reboot the system
if [ $REBOOT_ON_DONE -eq 1 ]; then
  reboot
fi
