#!/usr/bin/env bash

########################################################################
# Script  : Disable unused network protocols.
#           (https://konstruktoid.gitbooks.io/securing-ubuntu/content/sections/kernel/networkmodules.html)
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

begin_msg "Disable unused network protocols..."

# list of network protocols to disable
declare -a protocols=(
  "dccp"
  "sctp"
  "rds"
  "tipc"
)

# create disablenet config
[ -f /etc/modprobe.d/"$DISABLENET_FILE" ] ||
  touch /etc/modprobe.d/"$DISABLENET_FILE"

# add title for the blacklisted network protocols
grep -Fx "# Unused network protocols" /etc/modprobe.d/blacklist.conf > /dev/null 2>&1 && err=$? || err=$?
if [ $err -ne 0 ]; then
  echo "" >> /etc/modprobe.d/blacklist.conf
  echo "# Unused network protocols" >> /etc/modprobe.d/blacklist.conf
fi

for protocol in ${protocols[@]}; do
  # add network protocol to disablenet config
  # prefer using /bin/true vs /bin/false
  # ref: https://github.com/OpenSCAP/scap-security-guide/issues/539
  append_to_file -Fx "install $protocol /bin/true" "/etc/modprobe.d/$DISABLENET_FILE"

  # add network protocol to blacklist.conf
  append_to_file -Fx  "blacklist $protocol" /etc/modprobe.d/blacklist.conf
done

print_content "/etc/modprobe.d/$DISABLENET_FILE"

print_content "/etc/modprobe.d/blacklist.conf"

success_msg "Unused network protocols disabled!"
