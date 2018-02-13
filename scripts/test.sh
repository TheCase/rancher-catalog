#!/bin/sh

if [ -z $1 ]; then
  echo "Usage: $0 <proxmox_host>"
  exit 1
fi

TYPE="cattle"

if [ ! -z $2 ]; then
  TYPE=$2
fi 

echo "type ${TYPE}"
