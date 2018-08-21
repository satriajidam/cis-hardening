#!/usr/bin/env bash

########################################################################
# Script  : Coredumps configuration.
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

limits_path='/etc/security/limits.conf'

begin_msg 'Disabling coredumps...'

sed -i.bak 's/^# End of file*//' "$limits_path"

append_to_file -Fx '* hard core 0' "$limits_path"
append_to_file -Fx '# End of file' "$limits_path"

print_content "$limits_path"

success_msg 'Coredumps disabled!'
