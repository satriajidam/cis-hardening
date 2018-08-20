#!/usr/bin/env bash

########################################################################
# Script  : Disable unused kernal modules.
#           (https://linux-audit.com/kernel-hardening-disable-and-blacklist-linux-modules)
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

begin_msg "Disable unused kernel modules..."

# list of modules to disable
declare -a modules=(
  "bluetooth"
  "bnep"
  "btusb"
  "firewire-core"
  "n_hdlc"
  "net-pf-31"
  "pcspkr"
  "soundcore"
  "thunderbolt"
  "usb-midi"
  "usb-storage"
)

# create disablemod config
[ -f /etc/modprobe.d/"$DISABLEMOD_FILE" ] ||
  touch /etc/modprobe.d/"$DISABLEMOD_FILE"

# add title for the blacklisted modules
grep -Fx "# Unused kernel modules" /etc/modprobe.d/blacklist.conf > /dev/null 2>&1 && err=$? || err=$?
if [ $err -ne 0 ]; then
  echo "" >> /etc/modprobe.d/blacklist.conf
  echo "# Unused kernel modules" >> /etc/modprobe.d/blacklist.conf
fi

for module in ${modules[@]}; do
  # add module to disablemod config
  # prefer using /bin/true vs /bin/false
  # ref: https://github.com/OpenSCAP/scap-security-guide/issues/539
  append_to_file -Fx "install $module /bin/true" "/etc/modprobe.d/$DISABLEMOD_FILE"

  # add module to blacklist.conf
  append_to_file -Fx "blacklist $module" /etc/modprobe.d/blacklist.conf
done

print_content "/etc/modprobe.d/$DISABLEMOD_FILE"

print_content "/etc/modprobe.d/blacklist.conf"

success_msg "Unused kernel modules disabled!"
