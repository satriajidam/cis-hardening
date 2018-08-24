#!/usr/bin/env bash

########################################################################
# Script  : Configure default shell profile.
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

begin_msg 'Configuring default shell profile...'

if [ -f /etc/init.d/rc ]; then
  sed -i 's/umask 022/umask 027/g' /etc/init.d/rc
fi

print_content '/etc/init.d/rc'

# set default umask & shell timeout
append_to_file -Fx 'umask 027' /etc/profile
append_to_file -Fx 'TMOUT=600' /etc/profile

print_content '/etc/profile'

# set default umask & shell timeout
append_to_file -Fx 'umask 027' /etc/bash.bashrc
append_to_file -Fx 'TMOUT=600' /etc/bash.bashrc

print_content '/etc/bash.bashrc'

# set umask for other profiles
for file in $(ls /etc/profile.d/*.sh); do
  grep 'umask' $file > /dev/null 2>&1 && err=$? || err=$?
  if [ $err -eq 0 ]; then
    sed -i 's/^umask.*/umask 027/g' $file
  fi
done

success_msg 'Default shell profile configured!'
