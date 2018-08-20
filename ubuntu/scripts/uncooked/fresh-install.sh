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

# Enable sysstat to collect accounting
echo "Install sysstat..."
apt install sysstat -y
echo "Done!"

# install rkhunter, chkrootkit
echo "Install malware hunter..."
apt install rkhunter chkrootkit -y
echo "Done!"

## install sysdig
echo "Install Sysdig system..."
curl -s https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public | apt-key add -
curl -s -o /etc/apt/sources.list.d/draios.list http://download.draios.com/stable/deb/draios.list
apt update
apt install sysdig -y
echo "Done!"

# clean up
echo "Clean up installation system..."
apt-get clean
rm -rf /tmp/* /var/tmp/*
echo "Done!"