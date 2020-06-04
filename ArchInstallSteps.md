# Arch Install Steps
Taken from multiple sources, mostly https://itsfoss.com/install-arch-linux/
This guide assumes you have arch downloaded, flashed to USB, and have booted to USB

# Check for UEFI
ls /sys/firmware/efi/efivars
If this directory exists, you have a UEFI system

# Check for IP
ip link
ping archlinux.org

# set the time
timedatectl set-ntp true
timedatectl status
timedatectl set-timezone America/Toronto

# Disk partitioning for BIOS Systems
fdisk -l
fdisk /dev/sda - use diskname from previous command
(be sure to delete partitions using 'd' if not going to keep the existing data)
 -> n
 -> p
 -> 1
 -> (enter)
 -> (enter)
 -> w #to write to disk and leave fdisk

# Disk partitioning for UEFI Systems
fdisk -l
fdisk /dev/nvme0n1  - use diskname from previous command
(be sure to delete partitions using 'd' if not going to keep the existing data)
### Create EFI partition
 -> n (new partition)
 -> 1 (partition number - 1 in this case)
 -> +512M (512 MB size)
 -> t (to change partition type)
 -> 1 (to select EFI system)
  ### Create Root partition 
 -> n (new partition)
 -> p (default)
 -> 1 (default)
 -> <enter> (full size)
 -> w #to write to disk and leave fdisk


# Create FS (BIOS Based system)
lsblk or fdisk -l #returns partitions ex. dev/sda1
mkfs.ext4 /dev/sda1 (or your partition name)

# Create FS (UEFI Based system)
lsblk or fdisk -l #returns partitions ex. dev/sda1
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2 (or your partition name)

# Install Arch
### Select the proper mirror
pacman -Syy
pacman -S reflector
### Backup the mirror list
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

### Use reflector to get a local mirror
reflector -c "CA" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

### Install Arch to the same partition created above
e.g. mount /dev/sda1 /mnt
### Use pacstrap to install arch (add apps to the end of this line e.g. neovim)
pacstrap /mnt base linux linux-firmware neovim 

# Configure the system
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# Set the locale
locale-gen
echo LANG=en_CA.UTF-8 > /etc/locale.conf
export LANG=en_CA.UTF-8

# Hostname setup
echo <computername> > /etc/hostname
touch /etc/hosts
vim /etc/hosts
##### Add the following lines
127.0.0.1	localhost
::1		localhost
127.0.1.1	<computername>

# Set root password
passwd
<type in your password>

#Install grub (BIOS)
pacman -S grub efibootmgr
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

# Install DE
Whatever DE you want
sudo pacman -S xf86-video-amdgpu mesa
pacman -S xorg xorg-server
# Install DE environment
pacman -S cinnamon

# Install sudo
pacman -S sudo
### Allow wheel to use sudo
vim visudo #uncomment the %wheel line

# Create a user
useradd -m -g users -G storage,power,wheel -s /bin/bash <username>
passwd <username>
<type in your password>

# Install some base develeopment tools
sudo pacman -S --needed base-devel git wget yajl

# Make sure systemd-networkd and systemd-resolved are enabled and running automatically
# or install another network manager
systemctl status/enable/disable/start/stop the above

# Exit chroot and reboot
exit
shutdown now
