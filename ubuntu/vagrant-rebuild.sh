#!/bin/bash

vagrant destroy -f
sed -i.bak '/^192\.168\.10\.11.*/d' ~/.ssh/known_hosts
vagrant up
