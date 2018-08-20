#!/usr/bin/env bash

########################################################################
# Script  : Sudoers configuration.
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

begin_msg "Creating sudoers group..."
# check if group string find any match
grep $SUDOERS_GROUP /etc/group > /dev/null 2>&1 && err=$? || err=$? # use $err to capture the exit code
if [ $err -ne 0 ]; then
  # add sudoers group
  groupadd $SUDOERS_GROUP
  echo "%$SUDOERS_GROUP ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/"$SUDOERS_FILE"
  chmod 440 /etc/sudoers.d/"$SUDOERS_FILE"
  success_msg "Sudoers group created!"
else
  fail_msg "Sudoers group already exist!"
fi

begin_msg "Creating sudoers user..."
# check for existing user id
id -u $SUDOERS_USERNAME > /dev/null 2>&1 && err=$? || err=$? # use $err to capture the exit code
if [ $err -ne 0 ]; then
  # add sudoers user
  mkdir -p /home/"$SUDOERS_USERNAME"
  useradd $SUDOERS_USERNAME \
    -G $SUDOERS_GROUP \
    -d /home/"$SUDOERS_USERNAME" \
    -s /bin/bash > /dev/null 2>&1
  echo "$SUDOERS_USERNAME:$SUDOERS_PASSWORD" | chpasswd
  success_msg "Sudoers user created!"
else
  fail_msg "Sudoers user already exist!"
fi
