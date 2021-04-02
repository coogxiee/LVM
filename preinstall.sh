#!/usr/bin/env bash
#-------------------------------------------------------------------------
#        
#        $$\   $$\    $$\ $$\      $$\ 
#        $$ |  $$ |   $$ |$$$\    $$$ |
#        $$ |  \$$\  $$  |$$\$$\$$ $$ |
#        $$ |   \$$\$$  / $$ \$$$  $$ |
#        $$ |    \$$$  /  $$ |\$  /$$ |
#        $$$$$$$$\\$  /   $$ | \_/ $$ |
#        \________|\_/    \__|     \__|
#
# 
#-------------------------------------------------------------------------
https://github.com/coogxiee/LVM-/blob/main/preinstall.sh
echo "-------------------------------------------------"
echo "                Starting Script                  "               
echo "-------------------------------------------------"

# create partitions
sgdisk -n 1:0:+99G /dev/sda
sgdisk -n 1:0:+99G /dev/sdb
sgdisk -n 1:0:+99G /dev/sdc

#lvm
pvcreate /dev/sda1 
pvcreate /dev/sdb1 
pvcreate /dev/sdc1

vgcreate LVM /dev/sda1 
vgextend LVM /dev/sdb1
vgextend LVM /dev/sdc1

lvcreate -L +200M LVM -n ROOT
lvcreate -l +100%FREE LVM -n BOOT
mkfs.vfat -F 32 -n "BOOT" /dev/LVM/BOOT
mkfs.ext4 -L "ROOT" /dev/LVM/ROOT
lsblk
mount /dev/LVM/ROOT /mnt
