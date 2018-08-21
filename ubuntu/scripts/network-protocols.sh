#!/usr/bin/env bash

########################################################################
# Script  : Network protocols configuration.
# OSs     : - Ubuntu 16.04
# Authors : - Agastyo Satriaji Idam (play.satriajidam@gmail.com)
########################################################################

set -o errexit # make script exits when a command fails
set -o pipefail # make script exits when the rightmost command of a pipeline exits with non-zero status
set -o nounset # make script exits when it tries to use undeclared variables
# set -o xtrace # trace what gets executed for debugging purpose

# ensure running as root
if [ "$(id -u)" != '0' ]; then
  exec sudo "$0" "$@"
  exit $?
fi

begin_msg 'Disabling uncommon network protocols...'

# list of protocols to disable
declare -a protocols=(
  'dccp'
  'sctp'
  'rds'
  'tipc'
)

# create config file
[ -f /etc/modprobe.d/CIS-netprotocols.conf ] || touch /etc/modprobe.d/CIS-netprotocols.conf

# add title for the blacklisted network protocols
grep -Fx '# Uncommon network protocols' /etc/modprobe.d/blacklist.conf > /dev/null 2>&1 && err=$? || err=$?
if [ $err -ne 0 ]; then
  echo '' >> /etc/modprobe.d/blacklist.conf
  echo '# Uncommon network protocols' >> /etc/modprobe.d/blacklist.conf
fi

for protocol in ${protocols[@]}; do
  # disable the protocol
  # prefer using /bin/true vs /bin/false
  # ref: https://github.com/OpenSCAP/scap-security-guide/issues/539
  append_to_file -Fx "install $protocol /bin/true" /etc/modprobe.d/CIS-netprotocols.conf

  # add file system to blacklist.conf
  append_to_file -Fx "blacklist $protocol" /etc/modprobe.d/blacklist.conf
done

print_content '/etc/modprobe.d/CIS-netprotocols.conf'

print_content '/etc/modprobe.d/blacklist.conf'

success_msg 'Uncommon network protocols disabled!'
