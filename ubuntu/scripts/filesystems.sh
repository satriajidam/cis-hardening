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

cis_path='/etc/modprobe.d/CIS.conf'
blacklist_path='/etc/modprobe.d/blacklist.conf'
fstab_path='/etc/fstab'

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
[ -f "$cis_path" ] || touch "$cis_path"

# add title for the blacklisted file systems
grep -Fx '# Unused file systems' "$blacklist_path" > /dev/null 2>&1 && err=$? || err=$?
if [ $err -ne 0 ]; then
  echo '' >> "$blacklist_path"
  echo '# Unused file systems' >> "$blacklist_path"
fi

for filesystem in ${filesystems[@]}; do
  # disable the filesystem
  # prefer using /bin/true vs /bin/false
  # ref: https://github.com/OpenSCAP/scap-security-guide/issues/539
  append_to_file -Fx "install $filesystem /bin/true" "$cis_path"

  # add file system to blacklist.conf
  append_to_file -Fx "blacklist $filesystem" "$blacklist_path"
done

print_content "$cis_path"

print_content "$blacklist_path"

success_msg 'Unused file systems disabled!'

begin_msg 'Securing shared memory...'

# mount shared memory on tmpfs
append_to_file -Fxi 'tmpfs /dev/shm tmpfs rw,nosuid,nodev,noexec,relatime,mode=1777 0 0' "$fstab_path"
append_to_file -Fxi 'tmpfs /run/shm tmpfs rw,nosuid,nodev,noexec,relatime,mode=1777 0 0' "$fstab_path"

print_content "$fstab_path"

success_msg 'Shared memory secured!'

begin_msg 'Securing temporary directory...'

# mount temporary directory on tmpfs
append_to_file -Fxi 'tmpfs /tmp tmpfs rw,nosuid,nodev,noexec,relatime,mode=1777 0 0' "$fstab_path"
append_to_file -Fxi 'tmpfs /var/tmp tmpfs rw,nosuid,nodev,noexec,relatime,mode=1777 0 0' "$fstab_path"

print_content "$fstab_path"

success_msg 'Temporary directory secured!'
