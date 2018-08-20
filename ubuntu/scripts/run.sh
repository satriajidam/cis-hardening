#!/usr/bin/env bash

########################################################################
# Script  : Provisoning praparation.
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

#####################################
### DECLARE ENVIRONMENT VARIABLES ###
#####################################

# Message colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export RED='\033[1;31m'
export BLUE='\033[1;34m'
export NOCOLOR='\033[0m'

# Reboot when done provisioning
# yes: 1    no: 0
export REBOOT_ON_DONE=0

# Run rkhunter when done provisioning
# yes: 1    no: 0
export RKHUNTER_ON_DONE=0

# Disable interactive mode
export DEBIAN_FRONTEND='noninteractive'

# The root directory of this script
export ROOT_SOURCE="${BASH_SOURCE[0]}"

# Locale preferred language
export LOCALE_LANG='en_US'

## NTP Config
## ------------------------------------

# Server timezone
export TIMEZONE='Asia/Jakarta'

## Sudoers Config
## ------------------------------------

# Sudoers group name
export SUDOERS_GROUP='devops-sudoers'

# Sudoers file name in /etc/sudoers.d
export SUDOERS_FILE='devops_sudoers'

# Sudoers master username
export SUDOERS_USERNAME='devops'

# Sudoers master password
export SUDOERS_PASSWORD='WVCvpAcJaEYJdnRCaQTXbCGM54BFhc'

## /etc/login.defs Config
## ------------------------------------

# Maximum number of days a password may be used
export PASS_MAX_DAYS=99999

# Minimum number of days allowed between password changes
export PASS_MIN_DAYS=0

# Number of days warning given before a password expires
export PASS_WARN_AGE=7

## SSH Daemon Config
## ------------------------------------

# specify port to use for SSH
export SSH_PORT='22'

# List of allowed groups to perform SSH login (separated by space)
export ALLOWED_SSH_GROUPS="$SUDOERS_GROUP"

# List of allowed users to perform SSH login (separated by space)
export ALLOWED_SSH_USERS=

# List of denied groups to perform SSH login (separated by space)
export DENIED_SSH_GROUPS=

# List of denied users to perform SSH login (separated by space)
export DENIED_SSH_USERS=

## PAM Config
## ------------------------------------

# Minimum acceptable size for the new password (plus one if
# credits are not disabled which is the default). (See pam_cracklib manual.)
# Cannot be set to lower value than 6.
export PASSWORD_MINLEN='14'

# The maximum credit for having digits in the new password. If less than 0
# it is the minimum number of digits in the new password.
export PASSWORD_DCREDIT='-1'

# The maximum credit for having uppercase characters in the new password.
# If less than 0 it is the minimum number of uppercase characters in the new
# password.
export PASSWORD_UCREDIT='-1'

# The maximum credit for having lowercase characters in the new password.
# If less than 0 it is the minimum number of lowercase characters in the new
# password.
export PASSWORD_LCREDIT='-1'

# The maximum credit for having other characters in the new password.
# If less than 0 it is the minimum number of other characters in the new
# password.
export PASSWORD_OCREDIT='-1'

## Audit Daemon Config
## ------------------------------------

# Audit log storage size (in MB)
export AUDIT_LOG_SIZE=20


################################
### DECLARE HELPER FUNCTIONS ###
################################

# Print begin message.
# Globals:
#   $YELLOW   ANSI code for yellow color.
#   $NOCOLOR  ANSI code for no color.
# Arguments:
#   $1  The message
# Returns:
#   None
begin_msg() {
  echo -e "${YELLOW}--> ${1}\n${NOCOLOR}"
}

# Print success message.
# Globals:
#   $GREEN    ANSI code for green color.
#   $NOCOLOR  ANSI code for no color.
# Arguments:
#   $1  The message
# Returns:
#   None
success_msg() {
  echo -e "\n${GREEN}+++ ${1}\n${NOCOLOR}"
}

# Print fail message.
# Globals:
#   $RED      ANSI code for red color.
#   $NOCOLOR  ANSI code for no color.
# Arguments:
#   $1  The message
# Returns:
#   None
fail_msg() {
  >&2 echo -e "\n${RED}--- err: ${1}\n${NOCOLOR}" 
}

# Print info message.
# Globals:
#   $BLUE     ANSI code for blue color.
#   $NOCOLOR  ANSI code for no color.
# Arguments:
#   $1  The message
# Returns:
#   None
info_msg() {
  echo -e "${BLUE}${1}${NOCOLOR}"
}

# Print content of a file (excluding comments).
# Arguments:
#   $1  The file with its absolute path, ex: /etc/resolv.conf.
# Returns:
#   None
print_content() {
  echo "Content of $1:"
  sed -n 's/^[^#].*/  &/p' < $1
  echo ""
}

# Append a string to a file if it isn't already exist.
# Arguments:
#   Call with 2 arguments:
#     $1  The string to append.
#     $2  The file with its absolute path, ex: /etc/resolv.conf.
#   Call with 3 arguments:
#     $1  Options for grep command.
#     $2  The string to append.
#     $3  The file with its absolute path, ex: /etc/resolv.conf.
# Returns:
#   None
append_to_file() {
  local options string file

  if [ $# -eq 2 ]; then
    options=''
    string=$1
    file=$2
  elif [ $# -eq 3 ]; then
    options=$1
    string=$2
    file=$3
  else
    fail_msg "${FUNCNAME[0]}(): invalid number of arguments!" 
    exit 1
  fi

  grep "$options" "$string" "$file" > /dev/null 2>&1 && err=$? || err=$?
  if [ $err -ne 0 ]; then
    echo "$string" >> "$file"
  fi
}

# Configure Ubuntu Firewall.
# Globals:
#   $SSH_PORT  Port to use for SSH.
# Arguments:
#   None
# Returns:
#   None
configure_firewall() {
  ufw status | grep -Fx "Status: inactive" > /dev/null 2>&1 && err=$? || err=$?
  if [ $err -eq 0 ]; then
    fail_msg "${FUNCNAME[0]}(): ufw is inactive!"
    exit 1
  fi

  ## ------------------------------
  ## Customize your ufw rules here:
  ## ------------------------------

  # http/https rules
  ufw allow 80/tcp
  ufw allow 443/tcp

  # ntp rules
  ufw allow 123/udp

  # ssh rules
  ufw allow "$SSH_PORT/tcp"
}

# Get current running script's directory.
# Globals:
#   $ROOT_SOURCE  The root directory of current running script.
# Arguments:
#   None
# Returns:
#   Absolute path of current running script's directory.
get_script_dir() {
  local src dir

  src="$ROOT_SOURCE"

  # While $src is a symlink, resolve it
  while [ -h "$src" ]; do
    dir="$( cd -P "$( dirname "$src" )" && pwd )"
    src="$( readlink "$src" )"
    # If $src was a relative symlink (so no "/" as prefix,
    # need to resolve it relative to the symlink base directory
    [ "$src" != /* ] && src="$dir/$src"
  done
  
  dir="$( cd -P "$( dirname "$src" )" && pwd )"
  echo "$dir"
}

# Get config's directory.
# Arguments:
#   None
# Returns:
#   Absolute path of config's directory.
get_config_dir() {
  local dir

  dir="$( cd $(get_script_dir) && cd -P ../config && pwd )"
  echo "$dir"
}

# Run script using its absolute path.
# Arguments:
#   $1  /path/to/script
# Returns:
#   None
run() {
  $(get_script_dir)/"$1"
}

export -f begin_msg
export -f success_msg
export -f fail_msg
export -f info_msg
export -f print_content
export -f append_to_file
export -f configure_firewall
export -f get_script_dir
export -f get_config_dir
export -f run

################################
### CONFIGURE SHELL LANGUAGE ###
################################

begin_msg 'Configuring locale...'

# configure language in /etc/default/locale
sed -i.bak -e '/^LANG=/d' -e '/^LANGUAGE=/d' -e '/^LC_ALL/d' /etc/default/locale

echo "LANG=\"$LOCALE_LANG.UTF-8\"" >> /etc/default/locale
echo "LANGUAGE=\"$LOCALE_LANG.UTF-8\"" >> /etc/default/locale
echo "LC_ALL=\"$LOCALE_LANG.UTF-8\"" >> /etc/default/locale

# configure language in /etc/environment
append_to_file -Fx "export LANG=\"$LOCALE_LANG.UTF-8\"" /etc/environment
append_to_file -Fx "export LANGUAGE=\"$LOCALE_LANG.UTF-8\"" /etc/environment
append_to_file -Fx "export LC_ALL=\"$LOCALE_LANG.UTF-8\"" /etc/environment

# apply /etc/environment
source /etc/environment

locale

success_msg 'Locale configured!'


#######################
### EXECUTE SCRIPTS ###
#######################

# Initial setup
run 1-1_filesystem-configuration.sh
