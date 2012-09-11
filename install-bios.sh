##
## This is BIOS-mode arch automate installer script
##
#!/bin/bash

## target installed device
HDD=/dev/sda

## configuration files server path
## config file url http://192.168.1.4/arch/arch_automate
## pkg file url http://192.168.1.4/arch/pkg/$arch
SERVER=http://192.168.1.4/arch
CONFIG_ROOT=$SERVER"/arch_automate"

## mount points
MNT_BOOT=$HDD"1"
MNT_SWAP=$HDD"2"
MNT_ROOT=$HDD"3"

## partition size
SZ_BOOT=200M
SZ_SWAP=2G

echo "This script is for helping in installing arch linux after boot from installation disk"
echo
echo ":::WARNING:::"
echo "NEVER run this on non-empty machine"
echo "This scriipt will wipe all data on $HDD"
echo "BUT, If anyting gone wrong this could wipe all data in ALL DISK"
echo
echo "Installation mode is BIOS i.e. grub-bios and no EFI partition"

# ## WARNING: this is not bash read -p, Arch use difference read 
# read -r "Sure? Enter "yes" to continue, anything else to exit "
# if "$REPLY" != "yes"; then 
#     echo "What ever you said"
# fi
# swapoff $MNT_SWAP
# umount $MNT_BOOT
# umount $MNT_ROOT 

echo "You just take the risk, you may cancle any time when prompt by pressing Ctrl-C"

echo "Partioning $HDD with MBR scheme"
parted -s $HDD mklabel msdos

parted -s $HDD mkpart primary ext2 2048s $SZ_BOOT 
parted -s $HDD set 1 boot on 
parted -s $HDD mkpart primary linux-swap $SZ_BOOT $SZ_SWAP 
parted -s $HDD mkpart primary ext2 $SZ_SWAP -- -1 
  
echo "Formating $HDD"
echo " SWAP $MNT_SWAP"
mkswap $MNT_SWAP 
swapon $MNT_SWAP
echo " BOOT $MNT_BOOT"
mkfs.ext4 $MNT_BOOT
echo " ROOT $MNT_ROOT"
mkfs.ext4 $MNT_ROOT
fdisk -l $HDD
  
echo "Mounting $HDD"
mount $MNT_ROOT /mnt
mkdir /mnt/boot
mount $MNT_BOOT /mnt/boot
lsblk $HDD
  
echo "add local mirror to pacman"
wget "$CONFIG_ROOT/pacman.conf" -O /etc/pacman.conf
   
echo "add mirror to pacman"
wget "$CONFIG_ROOT/mirrorlist" -O /etc/pacman.d/mirrorlist
 
pacstrap /mnt base base-devel 
  
echo "gen fstab"
genfstab -p -U /mnt > /mnt/etc/fstab
cat /mnt/etc/fstab
 
echo "Getting config files"
echo "  /mnt/etc/hostname"
wget "$CONFIG_ROOT/hostname" -O /mnt/etc/hostname 

echo "  /mnt/etc/hosts"
wget "$CONFIG_ROOT/hosts" -O /mnt/etc/hosts 
 
echo "  /mnt/etc/pacman.conf"
wget "$CONFIG_ROOT/pacman.conf" -O /mnt/etc/pacman.conf 

echo "  /mnt/etc/locale.gen"
wget "$CONFIG_ROOT/locale.gen" -O /mnt/etc/locale.gen 
# 
echo "  /mnt/etc/timezone"
wget "$CONFIG_ROOT/timezone" -O /mnt/etc/timezone
 
echo "  /usr/bin/arch-chroot"
wget "$CONFIG_ROOT/arch-chroot" -O /usr/bin/arch-chroot

echo "  /mnt/chroot.sh"
wget "$CONFIG_ROOT/chroot.sh" -O /mnt/chroot.sh

HDD=$HDD SERVER=$SERVER arch-chroot /mnt
