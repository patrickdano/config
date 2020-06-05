# Recover from an Arch kernel install failure

Refer to this after a failed Kernel update.  I am not sure if this works for non-arch based systems, but this has happened to me in Arch a few times.

### Pre-requisites:
* download an Arch installer
* flash to USB and boot into the installer

### Steps
1. Boot into Arch
2. Make a directory to mount your arch installation
    ```sh
    mkdir /mnt/arch
    ```
3. Mount your root folder to /mnt/arch.
   * to find your mount point
      ```sh
      fdisk -l
      ```
      This command returns your device list, pick the ext4 partition you have your arch system installed to (e.g. /dev/sda1, /dev/nvme0n1p2)
    ```sh
    mount /dev/nvme0n1p2 /mnt/arch
    ```
4. Chroot into your Arch install
    ```sh
    arch-chroot /mnt/arch
    ```
5. Update the Linux Kernel
   ```sh
   pacman -Syyu linux
   ```
6. Leave and Reboot
   ```sh
   exit
   reboot
   ```
