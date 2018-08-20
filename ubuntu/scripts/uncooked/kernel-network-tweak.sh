#!/usr/bin/env bash

########################################################################
# Script  : Basic server configuration.
# OS      : Ubuntu 16.04
# Author  : Nashihun Amien
# Contact : nashihunamien@gmail.com
# Website : -
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

### TUNING NETWORK PERFORMANCE ###
#
## Default Socket Receive Buffer
echo "net.core.rmem_default = 31457280" >> /etc/sysctl.conf
echo "net.core.rmem_default = 31457280" >> /etc/sysctl.conf

## Maximum Socket Receive Buffer
echo "net.core.rmem_max = 12582912" >> /etc/sysctl.conf

## Default Socket Send Buffer
echo "net.core.wmem_default = 31457280" >> /etc/sysctl.conf

## Maximum Socket Send Buffer
echo "net.core.wmem_max = 12582912" >> /etc/sysctl.conf

## Increase number of incoming connections
echo "net.core.somaxconn = 4096" >> /etc/sysctl.conf

## Increase number of incoming connections backlog
echo "net.core.netdev_max_backlog = 65536" >> /etc/sysctl.conf

## Increase the maximum amount of option memory buffers
echo "net.core.optmem_max = 25165824" >> /etc/sysctl.conf

## Increase the maximum total buffer-space allocatable
## This is measured in units of pages (4096 bytes)
echo "net.ipv4.tcp_mem = 65536 131072 262144" >> /etc/sysctl.conf
echo "net.ipv4.udp_mem = 65536 131072 262144" >> /etc/sysctl.conf

## Increase the read-buffer space allocatable
echo "net.ipv4.tcp_rmem = 8192 87380 16777216" >> /etc/sysctl.conf
echo "net.ipv4.udp_rmem_min = 16384" >> /etc/sysctl.conf

## Increase the write-buffer-space allocatable
echo "net.ipv4.tcp_wmem = 8192 65536 16777216" >> /etc/sysctl.conf
echo "net.ipv4.udp_wmem_min = 16384" >> /etc/sysctl.conf

## Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
echo "net.ipv4.tcp_max_tw_buckets = 1440000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf


## load sysctl to activate above tweak
sysctl -p