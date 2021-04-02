#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

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
sgdisk -a 2048 -o /dev/sda # new gpt disk 2048 alignment
sgdisk -a 2048 -o /dev/sdb # new gpt disk 2048 alignment
sgdisk -a 2048 -o /dev/sdc # new gpt disk 2048 alignment

pvcreate /dev/sda1 /dev/sdb /dev/sdc

