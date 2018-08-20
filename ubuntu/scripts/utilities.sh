#!/usr/bin/env bash

########################################################################
# Script  : Install utiltity tools.
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

echo "Installing utilities..."

# install build-essentials
apt-get install -y build-essential

# install ca-certificates
apt-get install -y ca-certificates

# install debsums
apt-get install -y debsums

# install git
apt-get install -y git

# install python
apt-get install -y python

# clean up
apt-get clean
rm -rf /tmp/* /var/tmp/*

echo "Done!"
