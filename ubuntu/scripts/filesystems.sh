#!/usr/bin/env bash

########################################################################
# Script  : Filesystems configuration.
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

begin_msg 'Disabling unused file systems...'

# list of filesystems to disable
declare -a filesystems=(
  'cramfs'
  'freevxfs'
  'jffs2'
  'hfs'
  'hfsplus'
  'udf'
)

# create config file
[ -f /etc/modprobe.d/CIS.conf ] || touch /etc/modprobe.d/CIS.conf

# add title for the blacklisted file systems
grep -Fx '# Unused file systems' /etc/modprobe.d/blacklist.conf > /dev/null 2>&1 && err=$? || err=$?
if [ $err -ne 0 ]; then
  echo '' >> /etc/modprobe.d/blacklist.conf
  echo '# Unused file systems' >> /etc/modprobe.d/blacklist.conf
fi

for filesystem in ${filesystems[@]}; do
  # disable the filesystem
  # prefer using /bin/true vs /bin/false
  # ref: https://github.com/OpenSCAP/scap-security-guide/issues/539
  append_to_file -Fx "install $filesystem /bin/true" /etc/modprobe.d/CIS.conf

  # add file system to blacklist.conf
  append_to_file -Fx "blacklist $filesystem" /etc/modprobe.d/blacklist.conf
done

print_content '/etc/modprobe.d/CIS.conf'

print_content '/etc/modprobe.d/blacklist.conf'

success_msg 'Unused file systems disabled!'

begin_msg 'Securing shared memory...'

# mount shared memory on tmpfs
append_to_file -Fxi 'tmpfs /dev/shm tmpfs rw,nosuid,nodev,noexec,relatime,mode=1777 0 0' /etc/fstab
append_to_file -Fxi 'tmpfs /run/shm tmpfs rw,nosuid,nodev,noexec,relatime,mode=1777 0 0' /etc/fstab

print_content '/etc/fstab'

success_msg 'Shared memory secured!'

begin_msg 'Securing temporary directory...'

# mount temporary directory on tmpfs
append_to_file -Fxi 'tmpfs /tmp tmpfs rw,nosuid,nodev,noexec,relatime,mode=1777 0 0' /etc/fstab
append_to_file -Fxi 'tmpfs /var/tmp tmpfs rw,nosuid,nodev,noexec,relatime,mode=1777 0 0' /etc/fstab

print_content '/etc/fstab'

success_msg 'Temporary directory secured!'
