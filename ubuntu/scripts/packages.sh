#!/usr/bin/env bash

########################################################################
# Script  : Install required packages & remove unneeded ones.
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

begin_msg 'Removing unnecessary packages...'

apt-get purge -y \
  avahi* \
  popularity-contest \
  rsh* \
  talk* \
  telnet* \
  tftp* \
  xserver-xorg* \
  yp-tools \
  xinetd \
  openbsd-inetd \
  prelink \
  beep \
  nis

success_msg 'Unnecessary packages removed!'
