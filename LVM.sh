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
echo "-------select your disk to format----------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk: (example /dev/sda)"
echo "Please enter disk: (example /dev/sda)"
read DISK1
read DISK2
echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

# create partitions
sgdisk -n 1:0:+99G ${DISK1}
sgdisk -n 1:0:+99G ${DISK2}

#lvm
pvcreate /dev/sda1 /dev/sdb1

vgcreate LVM /dev/sda1 /dev/sdb1

lvcreate -L +200M LVM -n BOOT
lvcreate -l +100%FREE LVM -n ROOT
mkfs.vfat -F 32 -n "BOOT" /dev/LVM/BOOT
mkfs.ext4 -L "ROOT" /dev/LVM/ROOT
lsblk
mount /dev/LVM/ROOT /mnt

echo "--------------------------------------"
echo "-- Arch Install on selected Drive   --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr nano git sudo --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab

cat << EOT | arch-chroot /mnt
pacman -S neofetch --noconfirm
echo "--------------------------------------"
echo "-- Setting up localtime             --"
echo "--------------------------------------"
ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
hwclock --systohc
#sed -i "s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
#sed -i "s/#de_AT.UTF-8/de_AT.UTF-8/g" /etc/locale.gen
#locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=de-latin1-nodeadkeys" >> /etc/vconsole.conf
#echo "ReRe" >> /etc/hostname
# Setting hosts file
echo "
127.0.0.1	    localhost
::1		        localhost
127.0.1.1	    ReRe.localdomain	ReRe" >> /etc/hosts
mkinitcpio -P
echo "--------------------------------------"
echo "-- Grub Installation  --"
echo "--------------------------------------"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck
grub-mkconfig -o /boot/grub/grub.cfg
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "Default root password is root"
passwd
root
root
echo "Add User"
echo "Eddit sudoers with (EDITOR=nano visudo)"
echo "Add User to groups (wheel,video,audio,optical,storage,tty)
echo "--------------------------------------"
echo "--          Script ends here!       --"
echo "--------------------------------------"
EOT
umount -R /mnt
