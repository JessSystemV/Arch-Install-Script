#!/bin/bash
echo "Installing Arch, Jess' Preferred Defaults (i3)"

echo Enter a username.
read username

echo Enter a user password.
read userpassword

echo Enter a root password.
read rootpassword

(
  echo g;
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
  echo t;
  echo 1;
  echo 1;
  echo w;
) | fdisk /dev/sda

mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt

pacstrap /mnt base linux-zen linux-firmware nano xorg dunst maim xclip i3 lightdm feh lxqt-policykit slock lightdm-gtk-greeter pulseaudio picom j4-dmenu-desktop qutebrowser pcmanfm pavucontrol networkmanager grub sudo alacritty nano i3status i3lock xss-lock dmenu

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt <<EOF
cp /etc/locale.gen /etc/locale.bak
echo -e "en_GB.UTF-8\nen_US.UTF-8" > /etc/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
HOSTNAME=$(echo "Arch-\$(head -c 10 /dev/urandom | md5sum | awk '{print \$1}')")
echo \$HOSTNAME > /etc/hostname
echo -e "127.0.0.1 localhost\n::1 localhost" > /etc/hosts
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m $username
echo -e "$userpassword\n$userpassword" | passwd $username
echo -e "$rootpassword\n$rootpassword" | passwd root
usermod -aG wheel,audio,video,storage $username
dd if=/dev/zero of=/swapfile bs=1M count=14k status=progress
chmod 0600 /swapfile
mkswap -U clear /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
sed -i '/%wheel ALL(ALL:ALL) ALL[^[:alnum:]_]/s/^/#/g' /etc/sudoers
systemctl enable lightdm
systemctl enable NetworkManager
su - jess
systemctl --user enable pulseaudio
cd ~/
wget https://raw.githubusercontent.com/JessSystemV/Arch-Install-Script/main/wallpaper.jpg
mkdir -p .config/i3
cd .config/i3
wget https://raw.githubusercontent.com/JessSystemV/Arch-Install-Script/main/config
EOF
reboot now
