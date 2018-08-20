#!/usr/bin/env bash

########################################################################
# Script  : Configure user & group limits.
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

begin_msg "Configure /etc/security/limits.conf..."

sed -i.bak 's/^# End of file*//' /etc/security/limits.conf

append_to_file -Fx '* hard maxlogins 10' /etc/security/limits.conf
append_to_file -Fx '* hard core 0' /etc/security/limits.conf
append_to_file -Fx '* soft nproc 512' /etc/security/limits.conf
append_to_file -Fx '* hard nproc 1024' /etc/security/limits.conf
append_to_file -Fx '# End of file' /etc/security/limits.conf

print_content "/etc/security/limits.conf"

success_msg "/etc/security/limits.conf configured!"
