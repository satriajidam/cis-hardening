#!/usr/bin/env bash

########################################################################
# Script  : Configure hosts.allow & hosts.deny.
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

# ref: http://www.smartdomotik.com/2015/02/09/using-etchosts-allow-and-etchosts-deny-to-secure-unix/

begin_msg "Configuring /etc/hosts.allow..."

cp -vf /etc/hosts.allow /etc/hosts.allow.bak
cp -vf $(get_config_dir)/hosts.allow /etc/hosts.allow

chmod 644 /etc/hosts.allow

print_content "/etc/hosts.allow"

success_msg "/etc/hosts.allow configured!"

begin_msg "Configuring /etc/hosts.deny..."

cp -vf /etc/hosts.deny /etc/hosts.deny.bak
cp -vf $(get_config_dir)/hosts.deny /etc/hosts.deny

chmod 644 /etc/hosts.deny

print_content "/etc/hosts.deny"

success_msg "/etc/hosts.deny configured!"
