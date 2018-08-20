#!/usr/bin/env bash

########################################################################
# Script  : Configure fstab.
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

begin_msg "Configuring fstab..."

# securing shared memory
append_to_file -Fxi 'tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0' /etc/fstab
append_to_file -Fxi 'tmpfs /dev/shm tmpfs defaults,noexec,nosuid 0 0' /etc/fstab

# adding hidepid to /proc mount point
append_to_file -Fxi 'proc /proc proc rw,nosuid,nodev,noexec,relatime,hidepid=2 0 0' /etc/fstab

# mount /tmp on tmpfs
append_to_file -Fxi 'tmpfs /tmp tmpfs rw,nosuid,nodev,noexec,strictatime,mode=1777 0 0' /etc/fstab

# create vartmpfile.bin
# ref: https://www.cyberciti.biz/faq/howto-mount-tmp-as-separate-filesystem-with-noexec-nosuid-nodev
if [ ! -f /root/images/vartmpfile.bin ]; then
  mkdir -p /root/images
  dd if=/dev/zero of=/root/images/vartmpfile.bin bs=1 count=0 seek="$VARTMP_FILE_SIZE"
  mkfs.ext4 -F /root/images/vartmpfile.bin
  mount -o loop,rw,nosuid,nodev,noexec,strictatime /root/images/vartmpfile.bin /var/tmp
  chmod 1777 /var/tmp
fi

# mount /var/tmp on vartmpfile.bin
# ref: https://www.cyberciti.biz/faq/howto-mount-tmp-as-separate-filesystem-with-noexec-nosuid-nodev
append_to_file -Fxi '/root/images/vartmpfile.bin /var/tmp ext4 loop,rw,nosuid,nodev,noexec,strictatime 0 0' /etc/fstab

# remove floppy drivers
sed -i '/floppy/d' /etc/fstab

# remount all partitions
mount -a

print_content "/etc/fstab"

success_msg "fstab configured!"
