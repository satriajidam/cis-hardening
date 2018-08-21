#!/usr/bin/env bash

########################################################################
# Script  : Configure SSH daemon.
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

# ref: https://michael.mckinnon.id.au/2017/03/26/hardening-ssh-on-your-ubuntu-server/

begin_msg 'Configure SSH moduli...'

cp -vf /etc/ssh/moduli /etc/ssh/moduli.bak
awk '$5 >= 2047' /etc/ssh/moduli > /etc/ssh/moduli.tmp
mv /etc/ssh/moduli.tmp /etc/ssh/moduli

print_content '/etc/ssh/moduli'

success_msg 'SSH moduli configured!'

begin_msg 'Adding SSH login banner...'

cp -vf /etc/issue.net /etc/issue.net.bak
cp -vf $(get_config_dir)/issue.net /etc/issue.net

chown root:root /etc/issue.net
chmod 644 /etc/issue.net

print_content '/etc/issue.net'

success_msg 'SSH login banner added!'

begin_msg 'Configuring SSH daemon...'

cp -vf /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cp -vf $(get_config_dir)/sshd_config /etc/ssh/sshd_config

append_to_file -Fx '# Allow/Deny specific users/groups to login' /etc/ssh/sshd_config

# specify allowed groups to ssh
if [ -n "$ALLOWED_SSH_GROUPS" ]; then
  append_to_file -Fx "AllowGroups $ALLOWED_SSH_GROUPS" /etc/ssh/sshd_config
fi

# specify allowed users to ssh
if [ -n "$ALLOWED_SSH_USERS" ]; then
  append_to_file -Fx "AllowUsers $ALLOWED_SSH_USERS" /etc/ssh/sshd_config
fi

# specify denied groups to ssh
if [ -n "$DENIED_SSH_GROUPS" ]; then
  append_to_file -Fx "DenyGroups $DENIED_SSH_GROUPS" /etc/ssh/sshd_config
fi

# specify denied users to ssh
if [ -n "$DENIED_SSH_USERS" ]; then
  append_to_file -Fx "DenyUsers $DENIED_SSH_USERS" /etc/ssh/sshd_config
fi

chown -v root:root /etc/ssh/sshd_config
chmod -v og-rwx /etc/ssh/sshd_config

print_content '/etc/ssh/sshd_config'

# enable ssh to start on boot
systemctl enable ssh
systemctl reload ssh
systemctl restart ssh
systemctl status ssh --no-pager

success_msg 'SSH daemon configured!'
