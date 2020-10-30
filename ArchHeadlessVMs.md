# Install Virtualisation on a headless Arch Server

This shows steps to install QEMU, KVM, LXD/LXC, and docker on a headless arch server, along with some web UIs to manage them.

## Packages used
| Package | Needed for |
| ------ | ------ |
| qemu-headless | headless qemu|
| libvirt | Software to Manage VMs |
| virt-install | CLI tool to create VMs |
| vde2 | [plugins/googledrive/README.md][PlGd] |
| iptables | [plugins/onedrive/README.md][PlOd] |
| ebtables and dnsmasq | default NAT/DHCP networking |
| lxc | linux containers |
| lxd | linux containers |
| arch-install-scripts | scripts to help install arch and run priviledged containers |
| docker| it's docker |
| cdrkit | for iso tools|

## Front ends
| Package | Repo | Needed for |
| ------ | ------ |------ |
| cockpit | pacman | Web front end for all sorts of server management things |
| lxdui | aur | Web front end for LXD |
| portainer-bin | aur | Web front end for docker |

## Install all of this 
```sh
$ sudo pacman -S qemu-headless libvirt vde2 bridge-utils openbsd-netcat ebtables iptables dnsmasq lxc arch-install-scripts lxd docker virt-install cdrkit
```
Enable the services
```sh
$ sudo systemctl enable libvirtd
$ sudo systemctl start libvirtd
$ sudo systemctl enable lxd.service
$ sudo systemctl start lxd.service
```

---
## Cockpit
```sh
$ sudo pacman -S cockpit cockpit-machines
$ sudo systemctl enable --now cockpit.socket
```
Cockpit runs on port 9090
    
    
---
## LXDUI
### Using yay to install LXDUI
```sh
$ yay -S lxdui
```
> Follow the prompts to install lxdui
> then enable and start the service
```sh
$ sudo systemctl enable lxdui
$ sudo systemctl start lxdui
```
> add a new user (or modify the admin user)

### Add a user
```sh
$ lxdui user add -u <user> -p <password>
$ delete admin user
$ lxdui user delete -u admin
```

### OR change admin password
```sh
$ lxdui user update -u admin -p <password>
```

Navigate to IP:15151 for the web UI (The AUR package has lxdui starting on port 15151)

---

