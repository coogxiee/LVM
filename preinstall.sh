#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------
https://github.com/coogxiee/LVM-/blob/main/preinstall.sh
echo "-------------------------------------------------"
echo "                Starting Script                  "               
echo "-------------------------------------------------"

# create partitions
sgdisk -n 1:0:+99G /dev/sda
sgdisk -n 2:0:+99G /dev/sdb
sgdisk -n 3:0:+99G /dev/sdc

#lvm
pvcreate /dev/sda1 /dev/sdb1 /dev/sdc1
vgcreate LVM /dev/sda1 /dev/sdb1 /dev/sdc1
lvs create -L +200M -n BOOT
lvs create -l +100%FREE -n ROOT
mkfs.vfat -F 32 -n "BOOT" /dev/LVM/BOOT
mkfs.ext4 -L "ROOT" /dev/LVM/ROOT
lsblk
mount /dev/LVM/ROOT /mnt
