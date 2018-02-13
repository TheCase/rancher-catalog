#!/bin/sh

if [ -z $1 ]; then
  echo "Usage: $0 <proxmox_host>"
  exit 1
fi

TYPE="rancher-server"
MACPRE="00:00:00:00:10"

NODE=$1
VMID=`ssh ${NODE} pvesh get /cluster/nextid 2>/dev/null | sed s/\"//g`
echo "Creating ID ${VMID}..."
MSUF=`echo ${VMID} | cut -c 2-3` 

echo "Creating Filesystem..."
cmd="pvesh create /nodes/${NODE}/storage/local-lvm/content -filename vm-${VMID}-disk-0 -format raw -size 40G -vmid ${VMID}"
echo $cmd
ssh ${NODE} ${cmd} 2> /dev/null

echo "Create VM..."
cmd="pvesh create /nodes/${NODE}/qemu -name=${TYPE}${VMID} -vmid ${VMID} -memory 4096 -sockets 1 -cores 2 -net0 e1000,bridge=vmbr0,macaddr=${MACPRE}:${MSUF} -ide0=local-lvm:vm-${VMID}-disk-0"
echo $cmd
ssh ${NODE} ${cmd} 2> /dev/null

echo "Start VM"
ssh ${NODE} pvesh create /nodes/${NODE}/qemu/${VMID}/status/start
echo "finished"
