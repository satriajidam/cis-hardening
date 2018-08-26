#!/bin/bash

# fix annoying "stdin: is not a tty" problem on provisioning
sed -i "/mesg n/d" /root/.profile

# add vagrant user to vagrant group
usermod -aG vagrant vagrant

cd /home/vagrant && \
  git clone https://github.com/satriajidam/cis-hardening.git && \
  cis-hardening/aws/ubuntu/scripts/run.sh
