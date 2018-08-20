#!/usr/bin/env bash

########################################################################
# Script  : Configure PAM.
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

# ref: https://www.cyberciti.biz/tips/linux-check-passwords-against-a-dictionary-attack.html

begin_msg "Installing PAM modules..."

apt-get install -y libpam-pwquality

success_msg "PAM modules installed!"

begin_msg "Configuring PAM..."

cp -vf /etc/pam.d/common-password /etc/pam.d/common-password.bak

sed -i \
  -e 's/^password[\t].*.pam_pwquality.*/password\trequisite\t\t\tpam_pwquality.so retry=3/' \
  -e 's/^password[\t].*.pam_unix.*/password\t\[success=1 default=ignore\]\tpam_unix.so obscure use_authtok try_first_pass sha512 remember=5/' \
  -e '/^password[\t].*.pam_unix.*/a password\trequired\t\t\tpam_pwhistory.so remember=5' \
  /etc/pam.d/common-password

sed -i.bak \
  -e "s/^# minlen =.*/minlen = ${PASSWORD_MINLEN}/" \
  -e "s/^# dcredit =.*/dcredit = ${PASSWORD_DCREDIT}/" \
  -e "s/^# ucredit =.*/ucredit = ${PASSWORD_UCREDIT}/" \
  -e "s/^# lcredit =.*/lcredit = ${PASSWORD_LCREDIT}/" \
  -e "s/^# ocredit =.*/ocredit = ${PASSWORD_OCREDIT}/" \
  /etc/security/pwquality.conf

print_content "/etc/pam.d/common-password"

sed -i.bak \
  -e 's/nullok_secure//' \
  -e '/^auth[\t].*.pam_unix.*/a auth\trequired\t\t\tpam_tally2.so onerr=fail audit silent deny=5 unlock_time=900' \
  /etc/pam.d/common-auth

print_content "/etc/pam.d/common-auth"

sed -i.bak \
  -e 's/^# auth.*.required.*.pam_wheel\.so$/auth\trequired\tpam_wheel.so/' \
  /etc/pam.d/su

success_msg "PAM configured!"
