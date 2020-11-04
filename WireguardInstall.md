# Install Wireguard Server on Arch

## Install Wireguard
```sh
$ sudo pacman -S wireguard-tools
```
### Generate keys
```sh
$ wg genkey | tee /etc/wireguard/server_private.key | wg pubkey | tee /etc/wireguard/server_public.key
$ wg genkey | tee /etc/wireguard/client1-private.key | wg pubkey > /etc/wireguard/client1-public.key
$ wg genkey | tee /etc/wireguard/client2-private.key | wg pubkey > /etc/wireguard/client2-public.key
```

### Create server configuration file
```sh
$ sudo nvim /etc/wireguard/wg0.conf
```

paste in the following

```sh
[Interface]
# Set the IP range that client devices will receive an IP in
Address = 192.168.10.1/24
Address = fd86:ea04:1115::1/64
 
# The port that will be used to listen to connections. 51820 is the default.
ListenPort = 51820
 
# server's private key.
PrivateKey = VPN_SERVER_PRIVATE_KEY
 
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i %i -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE;
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i %i -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
 
[Peer]
#client 1 - repeat this section for as many clients as you have
PublicKey = CLIENT1_PUBLIC_KEY
# The IP address that will be assigned to this client
# assign a specific IP to the client
AllowedIPs = 192.168.10.2/32, fd86:ea04:1115::2/128  

[Peer]
#client 2 -  repeat this section for as many clients as you have
PublicKey = CLIENT2_PUBLIC_KEY
# The IP address that will be assigned to this client
# assign a specific IP to the client
AllowedIPs = 192.168.10.3/32, fd86:ea04:1115::3/128
```

### enable wireguard
```sh
$ sudo systemctl enable wg-quick@wg0
```
```sh
$ sudo systemctl start wg-quick@wg0
```

## Wireguard status
```sh
$ sudo wg show
```
```sh
interface: wg0
  public key: EMVR6sCpZXwOZaWb1zlhfT25pR9NzfruCxXxqfAMlnc=
  private key: (hidden)
  listening port: 51820
```

## IP Forwarding 
> to allow Wireguard clients to access the rest of your network

Create the following file
```sh
$ sudo nvim /etc/sysctl.d/30-ipforward.conf
```
paste in the following content
```sh
net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
```

Reload the rules
```sh
$ sysctl --system
```
check that forwarding is allowed
```sh
$ sysctl -a | grep forward
```
the rules added to the file above should be marked as 1 (enabled)

# Setup a linux client
Step 1: Install Wireguard for the distro you need

Step 2: Create a config file
```sh
$ sudo nvim /etc/wireguard/client.conf
```
```sh
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY #generated using the wg genkey command above
ListenPort = 51820
Address = 192.168.10.3/32, fd86:ea04:1115::3/128  #Be sure to use the same IP you have in the wg0 conf file created earlier.

[Peer]
PublicKey = EMVR6sCpZXwOZaWb1zlhfT25pR9NzfruCxXxqfAMlnc=  #public key of the server 
Endpoint = wg.dano.tech:51820 #Internet Accessible endpoint
AllowedIPs = 0.0.0.0/0, ::/0 #IP's that the device is allowed to access (this means all IPs)
```
Step 3: run the client connection
```sh
$ wg-quick up client
```

Step 4: Confirm you have an IP on the client connection
```sh
$ ip address show
```

## for an Android client 
#### Create a client configuration file on another client with a text editor.

Install qrencode
```sh
$ sudo pacman -S qrencode
```
> or
```sh
$ sudo xbps-install -S qrencode
```
> or

```sh
$ sudo apt install qrencode
```
then create the conf file (similar content to above)
```sh
$ nvim /etc/wireguard/android.conf
```
```sh
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 10.220.0.2/32, fd86:ea04:1115::2/128
DNS = 8.8.8.8
 
[Peer]
PublicKey = VPN_SERVER_PUBLIC_KEY
Endpoint = publicipaddressofwireguardserver:51820
AllowedIPs = 0.0.0.0/0, ::/0
```
## Generate the QR code
```sh
$ qrencode -t ansiutf8 < /etc/wireguard/android.conf
```

now install the app on your phone, and scan the QR code.




