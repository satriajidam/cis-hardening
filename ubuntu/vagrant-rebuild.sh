#!/bin/bash

vagrant destroy -f
sed -i.bak '/^192\.168\.100\.101.*/d' ~/.ssh/known_hosts
vagrant up
