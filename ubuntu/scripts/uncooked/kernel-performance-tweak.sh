#!/usr/bin/env bash

########################################################################
# Script  : Basic server configuration.
# OS      : Ubuntu 16.04
# Author  : Nashihun Amien
# Contact : nashihunamien@gmail.com
# Website : -
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

## Increase size of file handles and inode cache
echo "fs.file-max = 2097152" >> /etc/sysctl.conf

## Do less swapping
echo "vm.swappiness = 10" >> /etc/sysctl.conf
echo "vm.dirty_ratio = 60" >> /etc/sysctl.conf
echo "vm.dirty_background_ratio = 2" >> /etc/sysctl.conf

## load sysctl to activate above tweak
sysctl -p