#!/usr/bin/env bash

########################################################################
# Script  : Configure motd.
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

begin_msg 'Disabling default motd...'

chown -v root:root /etc/update-motd.d/*
chmod -v 644 /etc/update-motd.d/*

success_msg 'Default motd disabled!'

begin_msg 'Adding custom motd header...'

cp -vf $(get_config_dir)/00-custom-header /etc/update-motd.d/00-custom-header
chown -v root:root /etc/update-motd.d/00-custom-header
chmod -v u+x /etc/update-motd.d/00-custom-header

success_msg 'Custom motd header added!'
