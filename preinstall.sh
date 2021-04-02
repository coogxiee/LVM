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
echo "Starting Script                                  "
echo "-------------------------------------------------"



echo "-------------------------------------------------"
echo "-------select your disk to format----------------"
echo "-------------------------------------------------"
# disk prep
sgdisk -Z /dev/sda # zap all on disk
sgdisk -Z /dev/sdb # zap all on disk
sgdisk -Z /dev/sdc # zap all on disk

# create partitions
sgdisk -n 1:0:+100G /dev/sda
sgdisk -n 2:0:+100G /dev/sdb
sgdisk -n 3:0:+100G /dev/sdc

# set partition types
sgdisk -t 1:8300 /dev/sda #Linux Filesystem
sgdisk -t 2:8300 /dev/sdb #Linux Filesystem
sgdisk -t 3:8300 /dev/sdc #Linux Filesystem

