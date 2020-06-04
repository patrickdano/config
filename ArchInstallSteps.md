# Arch Install Steps
Taken from multiple sources, mostly https://itsfoss.com/install-arch-linux/
This guide assumes you have arch downloaded, flashed to USB, and have booted to USB

# Check for UEFI
```sh
$ ls /sys/firmware/efi/efivars
```
If this directory exists, you have a UEFI system

# Check for IP
```sh
ip link
ping archlinux.org
```


# Set the time
```sh
timedatectl set-ntp true
timedatectl status
timedatectl set-timezone America/Toronto
```
# Disk partitioning for BIOS Systems
```sh
fdisk -l
fdisk /dev/sda - use diskname from previous command
(be sure to delete partitions using 'd' if not going to keep the existing data)
 -> n
 -> p
 -> 1
 -> (enter)
 -> (enter)
 -> w #to write to disk and leave fdisk
```
# Disk partitioning for UEFI Systems
> (be sure to delete partitions using the 'd' command in fdisk if not going to keep the existing data)
```sh
fdisk -l
fdisk /dev/nvme0n1  - use diskname using the output of the previous command
```
### Create EFI partition
```sh
 -> n (new partition)
 -> 1 (partition number - 1 in this case)
 -> +512M (512 MB size)
 -> t (to change partition type)
 -> 1 (to select EFI system)
```
  ### Create Root partition 
```sh
 -> n (new partition)
 -> p (default)
 -> 1 (default)
 -> <enter> (full size)
 -> w #to write to disk and leave fdisk
```

# Create FS (BIOS Based system)
```sh
lsblk or fdisk -l #returns partitions ex. dev/sda1
mkfs.ext4 /dev/sda1 (or your partition name)
```
# Create FS (UEFI Based system)
```sh
lsblk or fdisk -l #returns partitions ex. dev/sda1
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2 (or your partition name)
```
# Install Arch
### Select the proper mirror
```sh
pacman -Syy
pacman -S reflector
```
### Backup the mirror list
```sh
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
```

### Use reflector to get a local mirror
```sh
reflector -c "CA" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
```

### Install Arch to the same partition created above
> Be sure to use the ext4 partition depending on the type of system you have (BIOS vs UEFI)
```sh
mount /dev/sda1 /mnt
```
or
```sh
mount /dev/nvme0n1p2 /mnt
```
### Use pacstrap to install arch (add apps to the end of this line e.g. neovim)
```sh
pacstrap /mnt base linux linux-firmware neovim 
```
# Configure the system
```sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```
# Set the locale
```sh
locale-gen
echo LANG=en_CA.UTF-8 > /etc/locale.conf
export LANG=en_CA.UTF-8
```

# Hostname setup
```sh
echo <computername> > /etc/hostname
touch /etc/hosts
vim /etc/hosts
```
##### Add the following lines
```sh
127.0.0.1	localhost
::1		localhost
127.0.1.1	<computername>
```

# Set root password
```sh
passwd
<type in your password>
```

# Install Grub (BIOS)
```sh
pacman -S grub efibootmgr
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
```

# Install Grub (UEFI)
> Make sure that you are still using arch-chroot. Install required packages:
```sh
pacman -S grub efibootmgr
# Create the directory where EFI partition will be mounted:
mkdir /boot/efi
# Now, mount the ESP partition you had created
mount /dev/sda1 /boot/efi # or /dev/nvme0n1p1
```
### Install grub like this:
```sh
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
```
# Install DE
> Choose whatever DE you want
If you have an AMD card
```sh
sudo pacman -S xf86-video-amdgpu mesa
```
### Install X
```sh
pacman -S xorg xorg-server
```
### Install DE environment (Cinnamon)
```sh
pacman -S cinnamon
```

# Install sudo
```sh
pacman -S sudo
```
### Allow wheel to use sudo
```sh
nvim visudo #uncomment the %wheel line
```

# Create a user
```sh
useradd -m -g users -G storage,power,wheel -s /bin/bash <username>
passwd <username>
<type in your password>
```

# Install some base development tools
```sh
sudo pacman -S --needed base-devel git wget yajl
```

# Enable your network manager
> Make sure systemd-networkd and systemd-resolved are enabled and running automatically or install another network manager
NetworkManager is used in this example
e.g. systemctl status/enable/disable/start/stop the above
```sh
systemctl enable NetworkManager.service
```

# Exit chroot and reboot
exit
shutdown now
