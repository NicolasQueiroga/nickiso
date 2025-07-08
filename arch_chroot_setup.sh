#!/bin/bash
set -e

HOSTNAME="nicks-arch"
USERNAME="nick"
PASSWORD="xxx"
LOCALE="en_US.UTF-8"
TIMEZONE="America/Sao_Paulo"
DISK="/dev/nvme0n1"

echo "==> Configurando fuso horário e relógio"
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

echo "==> Configurando locale"
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

echo "==> Definindo hostname"
echo "$HOSTNAME" > /etc/hostname

cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

echo "==> Ativando NetworkManager"
systemctl enable NetworkManager

echo "==> Criando usuário $USERNAME"
echo "root:$PASSWORD" | chpasswd
useradd -m -G wheel,docker -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "==> Instalando ambiente gráfico, GRUB e utilitários"
pacman -Sy --noconfirm \
  dosfstools os-prober mtools grub efibootmgr \
  lightdm lightdm-gtk-greeter \
  i3-wm i3status i3blocks i3lock dmenu lxappearance \
  firefox kitty vim nano git \
  materia-gtk-theme papirus-icon-theme \
  ttf-font-awesome ttf-ubuntu-font-family \
  pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-equalizer pulseaudio-jack alsa-utils \
  playerctl pacman-contrib wpa_supplicant wireless_tools dialog \
  docker docker-compose nvidia-container-toolkit snapd \
  code \
  p7zip arandr bash-completion cmake htop man-db neofetch reflector thunar unzip flameshot


echo "==> Ativando serviços"
systemctl enable lightdm
systemctl enable docker
systemctl enable snapd.socket

echo "==> Linkando /snap para compatibilidade"
ln -s /var/lib/snapd/snap /snap

echo "==> Instalando Discord e Spotify via Snap (pode demorar)"
snap install discord
snap install spotify

echo "==> Instalando e configurando GRUB"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "✅ Sistema pronto! Docker, Snap, Discord e Spotify instalados."
