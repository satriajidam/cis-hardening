#!/usr/bin/env bash

########################################################################
# Script  : Bootloader configuration.
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

begin_msg 'Securing bootloader config...'

chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg

success_msg 'Bootloader config secured!'
