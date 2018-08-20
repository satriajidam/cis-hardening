#!/usr/bin/env bash

########################################################################
# Script  : Basic server configuration.
# OS      : Ubuntu 16.04
# Author  : Nashihun Amien
# Contact : nashihunamien@gmail.com
# Website : -
# Score   : Optional to optimize 
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

download-prequisites() {
    apt install inotify-tools chkconfig -y
}

download-maldetect() {
    cd /tmp
    wget https://www.rfxn.com/downloads/maldetect-current.tar.gz
    tar xzvf maldetect-current.tar.gz
}

install-maldetect() {
    cd maldetect-*
    sh install.sh
}

monitoring-user-activity() {
    maldet -m users
    maldet -m /root,/home,/home/devops,/var,/tmp
}

### I need to reconfigure cronjob for daily scan
#
# This line reserved!
#
### 

# Installing Maldet
if [ "$(grep -Ei 'ubuntu' /etc/*release)" ]
    then
        begin_msg "Initialization..."
        begin_msg "Installing prequisites..."
        download-prequisites
        begin_msg "Downloading maldetect..."
        download-maldetect
        begin_msg "Installing maldetect..."
        install-maldetect
        begin_msg "Begin to monitoring user and directories..."
        monitoring-user-activity
        success_msg "Maldetect configured!"
    else
        fail_msg "Setup Failed!"
fi