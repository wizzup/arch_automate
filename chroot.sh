echo "Device: $HDD"

locale-gen

hwclock --systohc --utc

mkinitcpio -p linux
 
pacman --noconfirm -S os-prober

pacman --noconfirm -S grub-bios
grub-install --recheck $HDD
grub-mkconfig -o /boot/grub/grub.cfg

# pacman --noconfirm -S syslinux
# cat /boot/syslinux/syslinux.cfg
# syslinux-install_update -iam

passwd
