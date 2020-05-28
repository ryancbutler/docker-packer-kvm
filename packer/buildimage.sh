#!/bin/bash

cd /mnt
rm -rf vm
PACKER_LOG=1 packer build -var serial=$(tty) build-linux.json
cd vm
qemu-img convert -f qcow2 -O vmdk -o subformat=streamOptimized cent8.qcow2 disk-ide.vmdk
#Needed for VMware
printf '\x03' | dd conv=notrunc of=disk-ide.vmdk bs=1 seek=$((0x4))

