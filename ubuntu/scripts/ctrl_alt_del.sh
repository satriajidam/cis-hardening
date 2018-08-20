#!/usr/bin/env bash

########################################################################
# Script  : Disable Ctrl+Alt+Del.
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

# ref: https://help.ubuntu.com/lts/serverguide/console-security.html.en

begin_msg "Disabling Ctrl+Alt+Del..."

systemctl mask ctrl-alt-del.target

sed -i 's/^#CtrlAltDelBurstAction=.*/CtrlAltDelBurstAction=none/' /etc/systemd/system.conf

# masked systemd service will return exit code 3 on status check
# so it's necessary to force it to return exit code 0 using 'true'
systemctl status ctrl-alt-del.target --no-pager || true

success_msg "Ctrl+Alt+Del disabled!"
