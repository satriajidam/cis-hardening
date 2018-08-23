#!/usr/bin/env bash

########################################################################
# Script  : Prevent IP spoofing.
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

begin_msg "Disabling IP spoofing..."

sed -i.bak -e '/order hosts,bind/d' -e '/multi on/d' /etc/host.conf

append_to_file -Fx 'order bind,hosts' /etc/host.conf
append_to_file -Fx 'nospoof on' /etc/host.conf

print_content "/etc/host.conf"

success_msg "IP spoofing disabled!"
