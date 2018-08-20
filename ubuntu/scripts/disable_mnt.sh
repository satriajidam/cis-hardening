#!/usr/bin/env bash

########################################################################
# Script  : Disable unused file systems.
#           (https://konstruktoid.gitbooks.io/securing-ubuntu/content/sections/kernel/filesystemmodules.html)
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

begin_msg "Disable unused file systems..."

# list of file systems to disable
declare -a filesystems=(
  "cramfs"
  "freevxfs"
  "jffs2"
  "hfs"
  "hfsplus"
  "squashfs"
  "udf"
  "vfat"
)

# create disablemnt config
[ -f /etc/modprobe.d/"$DISABLEMNT_FILE" ] ||
  touch /etc/modprobe.d/"$DISABLEMNT_FILE"

# add title for the blacklisted file systems
grep -Fx "# Unused file systems" /etc/modprobe.d/blacklist.conf > /dev/null 2>&1 && err=$? || err=$?
if [ $err -ne 0 ]; then
  echo "" >> /etc/modprobe.d/blacklist.conf
  echo "# Unused file systems" >> /etc/modprobe.d/blacklist.conf
fi

for filesystem in ${filesystems[@]}; do
  # add file system to disablemnt config
  # prefer using /bin/true vs /bin/false
  # ref: https://github.com/OpenSCAP/scap-security-guide/issues/539
  append_to_file -Fx "install $filesystem /bin/true" "/etc/modprobe.d/$DISABLEMNT_FILE"

  # add file system to blacklist.conf
  append_to_file -Fx "blacklist $filesystem" /etc/modprobe.d/blacklist.conf
done

print_content "/etc/modprobe.d/$DISABLEMNT_FILE"

print_content "/etc/modprobe.d/blacklist.conf"

success_msg "Unused file systems disabled!"
