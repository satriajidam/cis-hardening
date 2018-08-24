#!/usr/bin/env bash

########################################################################
# Script  : Configure system files.
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

begin_msg 'Securing /etc/passwd...'

chown -v root:root /etc/passwd
chmod -v 644 /etc/passwd

success_msg '/etc/passwd secured!'

begin_msg 'Securing /etc/shadow...'

chown -v root:shadow /etc/shadow
chmod -v o-rwx,g-wx /etc/shadow

success_msg '/etc/shadow secured!'

begin_msg 'Securing /etc/group...'

chown -v root:root /etc/group
chmod -v 644 /etc/group

success_msg '/etc/group secured!'

begin_msg 'Securing /etc/gshadow...'

chown -v root:shadow /etc/gshadow
chmod -v o-rwx,g-rw /etc/gshadow

success_msg '/etc/gshadow secured!'

begin_msg 'Securing /etc/passwd-...'

chown -v root:root /etc/passwd-
chmod -v u-x,go-wx /etc/passwd-

success_msg '/etc/passwd- secured!'

begin_msg 'Securing /etc/shadow-...'

chown -v root:root /etc/shadow-
chmod -v o-rwx,g-rw /etc/shadow-

success_msg '/etc/shadow- secured!'

begin_msg 'Securing /etc/group-...'

chown -v root:root /etc/group-
chmod -v u-x,go-wx /etc/group-

success_msg '/etc/group- secured!'

begin_msg 'Securing /etc/gshadow-...'

chown -v root:root /etc/gshadow-
chmod -v o-rwx,g-rw /etc/gshadow-

success_msg '/etc/gshadow- secured!'
