#!/usr/bin/env bash

########################################################################
# Script  : Setup Advanced Intrusion Detection Environment (AIDE).
# OSs     : - Ubuntu 16.04
# Authors : - Agastyo Satriaji Idam (play.satriajidam@gmail.com)
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

# ref: https://www.cyberciti.biz/faq/debian-ubuntu-linux-software-integrity-checking-with-aide
#      https://www.stephenrlang.com/2016/03/using-aide-for-file-integrity-monitoring-fim-on-ubuntu

begin_msg 'Installing AIDE...'

echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections
echo "postfix postfix/mailname string $(hostname -f)" | debconf-set-selections

apt-get install -y aide aide-common

success_msg 'AIDE installed!'

begin_msg 'Configuring AIDE...'

grep -R -E '^!/var/lib/lxcfs/cgroup$' /etc/aide/* > /dev/null 2>&1 && err=$? || err=$?
if [ $err -ne 0 ]; then
  echo '!/var/lib/lxcfs/cgroup' > /etc/aide/aide.conf.d/70_aide_lxcfs
fi

grep -R -E '^!/var/lib/docker$' /etc/aide/* > /dev/null 2>&1 && err=$? || err=$?
if [ $err -ne 0 ]; then
  echo '!/var/lib/docker' > /etc/aide/aide.conf.d/70_aide_docker
fi

aideinit --yes --force

success_msg 'AIDE configured!'

begin_msg 'Enabling daily AIDE check...'

cp -vf $(get_config_dir)/aidecheck.service /etc/systemd/system/aidecheck.service
cp -vf $(get_config_dir)/aidecheck.timer /etc/systemd/system/aidecheck.timer

chmod 0644 /etc/systemd/system/aidecheck.*

systemctl enable aidecheck.timer
systemctl restart aidecheck.timer
systemctl daemon-reload
systemctl status aidecheck.timer --no-pager

success_msg 'Daily AIDE check enabled!'
