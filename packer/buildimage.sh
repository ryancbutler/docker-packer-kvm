#!/bin/bash

cd /mnt
rm -rf vm-linux
rm -rf vm-win
PACKER_LOG=1 packer build build-linux.json
PACKER_LOG=1 packer build build-win.json


qemu-img convert -f qcow2 -O vmdk -o subformat=streamOptimized ./vm-linux/cent8.qcow2 cent8-ide.vmdk
#Needed for VMware
printf '\x03' | dd conv=notrunc of=cent8-ide.vmdk bs=1 seek=$((0x4))
qemu-img convert -f qcow2 -O vmdk -o subformat=streamOptimized ./vm-win/windows.qcow2 windows-ide.vmdk
#Needed for VMware
printf '\x03' | dd conv=notrunc of=windows-ide.vmdk bs=1 seek=$((0x4))


