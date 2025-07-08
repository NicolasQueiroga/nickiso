#!/bin/bash
set -e

# === CONFIGURAÇÃO ===
DISK="/dev/nvme0n1"
LOCALE="en_US.UTF-8"
TIMEZONE="America/Sao_Paulo"

echo "==> Ajustando teclado para layout US"
loadkeys us

echo "==> Sincronizando o relógio"
timedatectl set-ntp true

echo "==> Particionando disco: $DISK"
parted --script "$DISK" \
  mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 esp on \
  mkpart primary ext4 513MiB 100%

echo "==> Formatando partições"
mkfs.fat -F32 "${DISK}p1"
mkfs.ext4 "${DISK}p2"

echo "==> Montando partições"
mount "${DISK}p2" /mnt
mkdir /mnt/boot
mount "${DISK}p1" /mnt/boot

echo "==> Instalando sistema base"
pacstrap /mnt base base-devel linux linux-firmware \
  nvidia nvidia-utils nvidia-settings \
  xorg-server xorg-xinit \
  networkmanager sudo vim nano git

echo "==> Gerando fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "==> Copiando script de configuração para o chroot"
curl -Lo /mnt/root/arch_chroot_setup.sh https://your-url.com/arch_chroot_setup.sh
chmod +x /mnt/root/arch_chroot_setup.sh

echo "==> Entrando no sistema para configuração final"
arch-chroot /mnt /root/arch_chroot_setup.sh

echo "✅ Instalação concluída! Pode reiniciar."
