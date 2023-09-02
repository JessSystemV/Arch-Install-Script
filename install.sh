#!/bin/bash
echo "Installing Arch, Jess' Preferred Defaults (i3)"

(
  echo o;
  echo n;
  echo ;
  echo ;
  echo ;
  echo +25M;
  echo a;
  echo n;
  echo ;
  echo ;
  echo ;
  echo ;
  echo w;
) | fdisk /dev/sda

mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt

pacstrap /mnt base linux linux-firmware nano xorg i3 lightdm lightdm-gtk-greeter pulseaudio j4-dmenu-desktop qutebrowser pcmanfm pavucontrol network-manager grub

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt <<EOF
cp /etc/locale.gen /etc/locale.bak
echo -e "en_GB.UTF-8\nen_US.UTF-8" > /etc/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
HOSTNAME=$(echo "Arch-\$(head -c 20 /dev/urandom | md5sum | awk '{print \$1}')")
echo \$HOSTNAME > /etc/hostname
echo -e "127.0.0.1 localhost\n::1 localhost" > /etc/hosts
echo -e "password\npassword" | passwd root
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m jess
echo -e "password\npassword" | passwd jess
usermod -aG wheel,audio,video,storage jess
sed -i '/%wheel ALL(ALL:ALL) ALL[^[:alnum:]_]/s/^/#/g' /etc/sudoers
systemctl enable lightdm
systemctl enable NetworkManager
su - jess
systemctl --user enable pulseaudio
reboot now
EOF
