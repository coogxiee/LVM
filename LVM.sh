#!/bin/bash

echo "-------------------------------------------------"
echo "Starting Script                                  "
echo "-------------------------------------------------"
timedatectl set-ntp true
pacman -Sy --noconfirm
pacman -S --noconfirm pacman-contrib

echo -e "\nInstalling prereqs...\n$HR"
pacman -S --noconfirm gptfdisk btrfs-progs

echo "-------------------------------------------------"
echo "-------select your disk to format----------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk: (example /dev/sda)"
read DISK
echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1:0:+200M ${DISK} # partition 1 (UEFI SYS), default start block, 512MB
sgdisk -n 2:0:+40G ${DISK} # partition 2 (Root), default start, remaining
sgdisk -n 3:0:-8G ${DISK}   # partition 3 (swap), default start, remaining (-8G for 8GB Swap)
sgdisk -n 4:0:0 ${DISK}     # partition 4 (home), default start, remaining

# set partition types
sgdisk -t 1:ef00 ${DISK} #EFI
sgdisk -t 2:8300 ${DISK} #Linux Filesystem
sgdisk -t 3:8200 ${DISK} #Linux Swap
sgdisk -t 4:8300 ${DISK} #Linux Filesystem

# label partitions
sgdisk -c 1:"EFI"  ${DISK}
sgdisk -c 2:"ROOT" ${DISK}
sgdisk -c 3:"SWAP" ${DISK}
sgdisk -c 4:"HOME" ${DISK}

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"

mkfs.vfat -F32 -n "EFI" "${DISK}1"  # Formats EFI Partition
mkfs.btrfs -L "ROOT" "${DISK}2"     # Formats ROOT Partition
mkfs.btrfs -L "HOME" "${DISK}4"     # Formats HOME Partition
mkswap "${DISK}3"                   # Create SWAP
swapon "${DISK}3"                   #Set SWAP

# mount target
mkdir /mnt
mount "${DISK}2" /mnt
btrfs su cr /mnt/@          # Setup Subvolume for btrfs and timeshift
umount -l /mnt
mount "${DISK}4" /mnt
btrfs su cr /mnt/@home      # Setup Subvolume for btrfs and timeshift
umount -l /mnt
mount -o subvol=@ "${DISK}2" /mnt        # Mount Subolume from root
mkdir /mnt/boot
mount "${DISK}1" /mnt/boot               # Mounts UEFI Partition

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
#echo "annefrank" >> /etc/hostname
# Setting hosts file
echo "
127.0.0.1           localhost
::1                     localhost
127.0.1.1           annefrank.localdomain       ReRe" >> /etc/hosts
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
umount -R /mn
