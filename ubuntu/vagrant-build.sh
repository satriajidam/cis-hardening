#!/bin/bash

set -e

# check if vagrant is installed or is in the $PATH
if [ ! "$(which vagrant)" ]; then
  >&2 echo 'error:\tvagrant is not installed!'
  echo '\tplease install vagrant (https://www.vagrantup.com) first.'
  exit 1
fi

# get ip address from Vagrantfile
ipaddress="$(cat Vagrantfile | grep -o -E -m1 '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b')"
escaddress="$(echo "$ipaddress" | sed 's/[&/\]/\\&/g')"

vagrant destroy -f
sed -i.bak "/^$escaddress.*/d" ~/.ssh/known_hosts
vagrant up
