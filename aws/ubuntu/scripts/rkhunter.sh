#!/usr/bin/env bash

########################################################################
# Script  : Setup rkhunter.
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

begin_msg 'Installing chkrootkit & rkhunter...'

apt-get install -y rkhunter

success_msg 'chkrootkit & rkhunter installed!'

begin_msg 'Configuring rkhunter...'

sed -i.bak \
  -e 's/^CRON_DAILY_RUN=.*/CRON_DAILY_RUN="yes"/' \
  -e 's/^CRON_DB_UPDATE=.*/CRON_DB_UPDATE="yes"/' \
  -e 's/^APT_AUTOGEN=.*/APT_AUTOGEN="yes"/' \
  /etc/default/rkhunter

print_content '/etc/default/rkhunter'

# Rkhunter returns non-zero exit code even though
# the execution doesn't really ends up in an error.
# So it's necessary to put 'true' to force the exit
# code to zero so the script execution doesn't stop
# halfway.
rkhunter --update || true
rkhunter --propupd || true

success_msg 'rkhunter configured!'
