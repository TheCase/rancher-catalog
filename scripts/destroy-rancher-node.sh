#!/bin/sh

if [ -z $2 ]; then
  echo "Usage: $0 <proxmox_node> <vmid>"
  exit 1
fi

ssh $1 qm stop $2
ssh $1 qm destroy $2

