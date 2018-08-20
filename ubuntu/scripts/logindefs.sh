#!/usr/bin/env bash

########################################################################
# Script  : Configure user account rules via login.defs.
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

# ref: https://www.thegeekdiary.com/understanding-etclogin-defs-file/

begin_msg "Configuring /etc/login.defs..."

sed -i.bak \
  -e 's/^.*LOG_OK_LOGINS.*/LOG_OK_LOGINS\t\tyes/' \
  -e 's/^UMASK.*/UMASK\t\t077/' \
  -e "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS\t\t$PASS_MAX_DAYS/" \
  -e "s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS\t\t$PASS_MIN_DAYS/" \
  -e "s/^PASS_WARN_AGE.*/PASS_WARN_AGE\t\t$PASS_WARN_AGE/" \
  -e 's/DEFAULT_HOME.*/DEFAULT_HOME no/' \
  -e 's/ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' \
  -e 's/USERGROUPS_ENAB.*/USERGROUPS_ENAB no/' \
  -e 's/^# SHA_CRYPT_MAX_ROUNDS.*/SHA_CRYPT_MAX_ROUNDS\t\t10000/' \
  /etc/login.defs

print_content "/etc/login.defs"

success_msg "/etc/login.defs configured!"
