#!/usr/bin/env bash

########################################################################
# Script  : Limits root access to localhost.
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

begin_msg "Configuring root access..."

sed -i.bak 's/^#+ : root : 127.0.0.1/+ : root : 127.0.0.1/' /etc/security/access.conf

print_content "/etc/security/access.conf"

success_msg "Root access configured!"
