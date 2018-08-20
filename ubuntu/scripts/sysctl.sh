#!/usr/bin/env bash

########################################################################
# Script  : Configure & tweak sysctl.
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

begin_msg "Configuring sysctl..."

cp -vf /etc/sysctl.conf /etc/sysctl.conf.bak
cp -vf $(get_config_dir)/sysctl.conf /etc/sysctl.conf

chmod 0600 /etc/sysctl.conf

print_content "/etc/sysctl.conf"

# set the active kernel parameters
declare -a parameters
parameters=($(sed -n 's/^[^#].*/&/p' /etc/sysctl.conf | sed 's/ //g'))
for parameter in ${parameters[@]}; do
  sysctl -w "$parameter"
done

# flush ip route
sysctl -w net.ipv4.route.flush=1
sysctl -w net.ipv6.route.flush=1

# reload sysctl
sysctl -p

success_msg "Sysctl configured!"
