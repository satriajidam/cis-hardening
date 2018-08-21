#!/usr/bin/env bash

########################################################################
# Script  : Configure logrotate.
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

begin_msg 'Configuring logrotate...'

# configure logrotate.conf
cp -vf /etc/logrotate.conf /etc/logrotate.conf.bak
cp -vf $(get_config_dir)/logrotate.conf /etc/logrotate.conf

print_content '/etc/logrotate.conf'

success_msg 'Logrotate configured!'
