#!/usr/bin/env bash

########################################################################
# Script  : Setup audit daemon (auditd).
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

# ref: https://linux-audit.com/configuring-and-auditing-linux-systems-with-audit-daemon
#      https://linux.die.net/man/8/auditd.conf

begin_msg "Installing audit daemon..."

apt-get install -y auditd

success_msg "Audit daemon installed!"

begin_msg "Configuring audit daemon..."

sed -i.bak \
  -e "s/^max_log_file =.*/max_log_file = ${AUDIT_LOG_SIZE}/" \
  -e 's/^space_left_action =.*/space_left_action = email/' \
  -e 's/^action_mail_acct =.*/action_mail_acct = root/' \
  -e 's/^admin_space_left_action = .*/admin_space_left_action = halt/' \
  -e 's/^max_log_file_action =.*/max_log_file_action = keep_logs/' \
  /etc/audit/auditd.conf

print_content "/etc/audit/auditd.conf"

cp -vf $(get_config_dir)/audit.rules /etc/audit/audit.rules

sed -i "s/arch=b64/arch=$(uname -m)/g" /etc/audit/audit.rules

print_content "/etc/audit/audit.rules"

cp -vf /etc/audit/audit.rules /etc/audit/rules.d/hardening.rules

systemctl enable auditd
systemctl reload auditd
systemctl restart auditd
systemctl status auditd --no-pager

sed -i.bak \
  -e 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="audit=1"/' \
  /etc/default/grub

update-grub

print_content "/etc/default/grub"

success_msg "Audit daemon configured!"
