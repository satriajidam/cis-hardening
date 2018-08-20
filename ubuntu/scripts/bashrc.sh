#!/usr/bin/env bash

########################################################################
# Script  : Configure default bashrc & profile.
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

begin_msg "Configuring default bashrc & profile..."

if [ -f /etc/init.d/rc ]; then
  sed -i.bak 's/umask 022/umask 027/g' /etc/init.d/rc
fi

print_content "/etc/init.d/rc"

cp -vf /etc/profile /etc/profile.bak
cp -vf $(get_config_dir)/profile /etc/profile

print_content "/etc/profile"

for file in $(ls /etc/profile.d/*.sh); do
  grep 'umask' $file > /dev/null 2>&1 && err=$? || err=$?
  if [ $err -eq 0 ]; then
    sed -i.bak 's/^umask.*/umask 027/g' $file
  fi
done

cp -vf /etc/bash.bashrc /etc/bash.bashrc.bak
cp -vf $(get_config_dir)/bash.bashrc /etc/bash.bashrc

print_content "/etc/bash.bashrc"

success_msg "Default bashrc & profile configured!"
