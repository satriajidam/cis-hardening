#!/usr/bin/env bash

########################################################################
# Script  : Setup Rsyslog.
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

begin_msg 'Configuring rsyslog...'

cp -vf /etc/rsyslog.conf /etc/rsyslog.conf.bak
cp -vf $(get_config_dir)/rsyslog.conf /etc/rsyslog.conf

print_content '/etc/rsyslog.conf'

for rsyslog_file in $(ls $(get_config_dir)/rsyslog.d); do
  if [ -f /etc/rsyslog.d/"$rsyslog_file" ]; then
    cp -vf /etc/rsyslog.d/"$rsyslog_file" /etc/rsyslog.d/"$rsyslog_file".bak
  fi
  cp -vf $(get_config_dir)/rsyslog.d/"$rsyslog_file" /etc/rsyslog.d/"$rsyslog_file"

  print_content "/etc/rsyslog.d/$rsyslog_file"
done

# reload rsyslogd
pkill -HUP rsyslogd

success_msg 'Rsyslog configured!'

begin_msg 'Enabling rsyslog...'

systemctl enable rsyslog
systemctl restart rsyslog
systemctl status rsyslog --no-pager

success_msg 'Rsyslog enabled!'
