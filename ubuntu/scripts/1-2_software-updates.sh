#!/usr/bin/env bash

########################################################################
# Script  : Software updates configuration
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


ubuntu_version="$(lsb_release -r | awk '{print $2}')"
major_version="$(echo $ubuntu_version | awk -F. '{print $1}')"

# update repository
begin_msg 'Updating repositories...'
apt-get update -y
success_msg 'Repositories updated!'

# upgrade installed packages
begin_msg 'Upgrading installed packages...'
apt-get upgrade -y
success_msg 'Installed packages upgraded!'

# remove & clean unused packages
begin_msg 'Removing unused packages...'
apt-get autoremove -y
apt-get autoclean -y
success_msg 'Unused packages removed!'

begin_msg 'Disabling release & automatic upgrades...'

# disable release-upgrades
sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades
print_content '/etc/update-manager/release-upgrades'

# disable systemd apt timers/services
if [ "$major_version" -ge "16" ]; then
  systemctl stop apt-daily.timer
  systemctl stop apt-daily-upgrade.timer
  systemctl disable apt-daily.timer
  systemctl disable apt-daily-upgrade.timer
  systemctl mask apt-daily.service
  systemctl mask apt-daily-upgrade.service
  systemctl daemon-reload
fi

# disable periodic activities of apt to be safe
cp -vf /etc/apt/apt.conf.d/10periodic /etc/apt/apt.conf.d/10periodic.bak
cat <<EOF > /etc/apt/apt.conf.d/10periodic
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

print_content '/etc/apt/apt.conf.d/10periodic'

# prevent unauthenticated apt-get
echo 'APT::Get::AllowUnauthenticated "false";' > /etc/apt/apt.conf.d/9999-disallow-unathenticated
print_content '/etc/apt/apt.conf.d/9999-disallow-unathenticated'

# remove unattended-upgrades if exist
rm -vrf /var/log/unattended-upgrades
apt-get purge -y unattended-upgrades

success_msg 'Release & automatic upgrades disabled!'

# clean up
apt-get clean -q
rm -rf /tmp/* /var/tmp/*
