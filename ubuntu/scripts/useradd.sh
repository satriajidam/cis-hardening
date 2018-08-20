#!/usr/bin/env bash

########################################################################
# Script  : Configure useradd & adduser defaults.
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

begin_msg "Configuring useradd & adduser defaults..."

sed -i 's/DSHELL=.*/DSHELL=\/bin\/false/' /etc/adduser.conf
sed -i 's/SHELL=.*/SHELL=\/bin\/false/' /etc/default/useradd

print_content "/etc/adduser.conf"
print_content "/etc/default/useradd"

success_msg "useradd & adduser configured!"
