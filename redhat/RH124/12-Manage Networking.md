# Validate Network Configuration


## Gather Network Interface Information


The ip link command lists all available network interfaces on your system. In the following
example, the server has three network interfaces: lo, which is the loopback device that is
connected to the server itself, and two Ethernet interfaces, ens3 and ens4.

```sh
[user@host ~]$ ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
 group default qlen 1000
 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT
 group default qlen 1000
 link/ether 52:54:00:00:00:0a brd ff:ff:ff:ff:ff:ff
3: ens4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT
 group default qlen 1000
 link/ether 52:54:00:00:00:1e brd ff:ff:ff:ff:ff:ff

 [root@rocky2 ~]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 00:0c:29:47:d9:6a brd ff:ff:ff:ff:ff:ff
    altname enp3s0
```

Display IP Addresses

Use the ip command to view device and address information. A single network interface can have
multiple IPv4 or IPv6 addresses.

```sh
[user@host ~]$ ip addr show ens3
#An active interface is UP.
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
#The link/ether string specifies the hardware (MAC) address of the device.
 link/ether 52:54:00:00:00:0b brd ff:ff:ff:ff:ff:ff
 #The inet string shows an IPv4 address, its network prefix length, and scope.
 inet 192.0.2.2/24 brd 192.0.2.255 scope global ens3
 valid_lft forever preferred_lft forever
 #The inet6 string shows an IPv6 address, its network prefix length, and scope. This address is of global scope and is normally used.
 inet6 2001:db8:0:1:5054:ff:fe00:b/64 scope global
 valid_lft forever preferred_lft forever
 #This inet6 string shows that the interface has an IPv6 address of link scope that can be used only for communication on the local Ethernet link.
 inet6 fe80::5054:ff:fe00:b/64 scope link
 valid_lft forever preferred_lft forever
```

Display Performance Statistics

The ip command can also show statistics about network performance. Counters for each network
interface can identify the presence of network issues. The counters record statistics, such as for
the number of received (RX) and transmitted (TX) packets, packet errors, and dropped packets.

```sh
[root@rocky2 ~]# ip -s link show ens160
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 00:0c:29:47:d9:6a brd ff:ff:ff:ff:ff:ff
    RX:  bytes packets errors dropped  missed   mcast
       9423717   10841      0       0       0       0
    TX:  bytes packets errors dropped carrier collsns
       2219746    6639      0       0       0       0
    altname enp3s0
```

## Verify Connectivity Between Hosts

The ping command tests connectivity.

```sh
[user@host ~]$ ping -c3 192.0.2.254
PING 192.0.2.1 (192.0.2.254) 56(84) bytes of data.
64 bytes from 192.0.2.254: icmp_seq=1 ttl=64 time=4.33 ms
64 bytes from 192.0.2.254: icmp_seq=2 ttl=64 time=3.48 ms
64 bytes from 192.0.2.254: icmp_seq=3 ttl=64 time=6.83 ms
--- 192.0.2.254 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 3.485/4.885/6.837/1.424 ms
```

The ping6 command is the IPv6 version of the ping command in Red Hat Enterprise Linux. The
difference between these commands is that the ping6 command communicates over IPv6 and
takes IPv6 addresses.

```sh
[user@host ~]$ ping6 2001:db8:0:1::1
PING 2001:db8:0:1::1(2001:db8:0:1::1) 56 data bytes
64 bytes from 2001:db8:0:1::1: icmp_seq=1 ttl=64 time=18.4 ms
64 bytes from 2001:db8:0:1::1: icmp_seq=2 ttl=64 time=0.178 ms
64 bytes from 2001:db8:0:1::1: icmp_seq=3 ttl=64 time=0.180 ms
^C
--- 2001:db8:0:1::1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.178/6.272/18.458/8.616 ms
```

## Troubleshoot Router Issues

Describe the Routing Table

```sh
[root@rocky2 ~]# ip route
default via 192.168.100.2 dev ens160 proto dhcp src 192.168.100.132 metric 100
192.168.100.0/24 dev ens160 proto kernel scope link src 192.168.100.132 metric 100
```



```sh
[user@host ~]$ ip -6 route
unreachable ::/96 dev lo metric 1024 error -101
unreachable ::ffff:0.0.0.0/96 dev lo metric 1024 error -101
#network uses the ens3 interface (which presumably has an address on that network).
2001:db8:0:1::/64 dev ens3 proto kernel metric 256
unreachable 2002:a00::/24 dev lo metric 1024 error -101
unreachable 2002:7f00::/24 dev lo metric 1024 error -101
unreachable 2002:a9fe::/32 dev lo metric 1024 error -101
unreachable 2002:ac10::/28 dev lo metric 1024 error -101
unreachable 2002:c0a8::/32 dev lo metric 1024 error -101
unreachable 2002:e000::/19 dev lo metric 1024 error -101
unreachable 3ffe:ffff::/32 dev lo metric 1024 error -101
#The fe80::/64 network uses the ens3 interface, for the link-local address. On a system with multiple interfaces, a route to the fe80::/64 network exists in each interface for each link-local address.
fe80::/64 dev ens3 proto kernel metric 256
#The default route to all networks on the IPv6 Internet (the ::/0 network) uses the router at the 2001:db8:0:1::ffff network and it is reachable with the ens3 device
default via 2001:db8:0:1::ffff dev ens3 proto static metric 1024


[root@rocky2 ~]# ip -6 route
::1 dev lo proto kernel metric 256 pref medium
fe80::/64 dev ens160 proto kernel metric 1024 pref medium
```


Trace Traffic Routes

```sh
[user@host ~]$ tracepath access.redhat.com
...output omitted...
 4: 71-32-28-145.rcmt.qwest.net 48.853ms asymm 5
 5: dcp-brdr-04.inet.qwest.net 100.732ms asymm 7
 6: 206.111.0.153.ptr.us.xo.net 96.245ms asymm 7
 7: 207.88.14.162.ptr.us.xo.net 85.270ms asymm 8
 8: ae1d0.cir1.atlanta6-ga.us.xo.net 64.160ms asymm 7
 9: 216.156.108.98.ptr.us.xo.net 108.652ms
10: bu-ether13.atlngamq46w-bcr00.tbone.rr.com 107.286ms asymm 12
...output omitted...
```

The tracepath6 and traceroute -6 commands are the equivalent IPv6 commands to the
tracepath and traceroute commands.

```sh
[user@host ~]$ tracepath6 2001:db8:0:2::451
 1?: [LOCALHOST] 0.091ms pmtu 1500
 1: 2001:db8:0:1::ba 0.214ms
 2: 2001:db8:0:1::1 0.512ms
 3: 2001:db8:0:2::451 0.559ms reached
 Resume: pmtu 1500 hops 3 back 3
```


## Troubleshoot Port and Service Issues



The ss command is used to display socket statistics. The ss command replaces the older
netstat tool, from the net-tools package, which might be more familiar to some system
administrators but is not always installed.



```sh
[user@host ~]$ ss -ta
State Recv-Q Send-Q Local Address:Port Peer Address:Port
LISTEN 0 128 *:sunrpc *:*
#*:ssh : The port that is used for SSH is listening on all IPv4 addresses. The asterisk (*) character represents all when referencing IPv4 addresses or ports.
LISTEN 0 128 *:ssh *:*
#127.0.0.1:smtp : The port that is used for SMTP is listening on the 127.0.0.1 IPv4 loopback interface.
LISTEN 0 100 127.0.0.1:smtp :
LISTEN 0 128 *:36889 *:*
#172.25.250.10:ssh : The established SSH connection is on the 172.25.250.10 interface and originates from a system with an address of 172.25.254.254.
ESTAB 0 0 172.25.250.10:ssh 172.25.254.254:59392
LISTEN 0 128 :::sunrpc :::*
#:::ssh : The port that is used for SSH is listening on all IPv6 addresses. The double colon (::) syntax represents all IPv6 interfaces.
LISTEN 0 128 :::ssh :::*
#::1:smtp : The port that is used for SMTP is listening on the ::1 IPv6 loopback interface.
LISTEN 0 100 ::1:smtp :::*
LISTEN 0 128 :::34946 :::*

```

Options for ss and netstat

| Option | Description |
|--------|-------------|
| -n | Show numbers instead of names for interfaces and ports. |
| -t | Show TCP sockets. |
| -u | Show UDP sockets. |
| -l | Show only listening sockets. |
| -a | Show all (listening and established) sockets. |
| -p | Show the process that uses the sockets. |
| -A | inet Display active connections (but not listening sockets) for the inet address family. That is, ignore local UNIX domain sockets. For the ss command, both IPv4 and IPv6 connections are displayed. For the netstat command, only IPv4 connections are displayed. (The netstat -A inet6 command displays IPv6 connections, and the netstat -46 command displays IPv4 and IPv6 at the same time.) |


# Configure Networking from the Command Line


## Describe the NetworkManager Service

You can interact with the
NetworkManager service via the command line or with graphical tools. Service configuration files
are stored in the /etc/NetworkManager/system-connections/ directory.

View Network Information

```sh
[user@host ~]$ nmcli dev status
DEVICE TYPE STATE CONNECTION
eno1 ethernet connected eno1
ens3 ethernet connected static-ens3
eno2 ethernet disconnected --
lo loopback unmanaged --
```

The nmcli connection show command displays a list of all connections. Use the --active
option to list only active connections

```sh
[user@host ~]$ nmcli con show
NAME UUID TYPE DEVICE
eno2 ff9f7d69-db83-4fed-9f32-939f8b5f81cd 802-3-ethernet --
static-ens3 72ca57a2-f780-40da-b146-99f71c431e2b 802-3-ethernet ens3
eno1 87b53c56-1f5d-4a29-a869-8a7bdaf56dfa 802-3-ethernet eno1
[root@rocky2 ~]# nmcli con show
NAME    UUID                                  TYPE      DEVICE 
ens160  773d68cb-5a3d-3194-84e6-387304829829  ethernet  ens160
lo      dfff59ab-edc7-4808-acd2-57389873499e  loopback  lo
[user@host ~]$ nmcli con show --active
NAME UUID TYPE DEVICE
static-ens3 72ca57a2-f780-40da-b146-99f71c431e2b 802-3-ethernet ens3
eno1 87b53c56-1f5d-4a29-a869-8a7bdaf56dfa 802-3-ethernet eno1
```

Add a Network Connection

```sh
[root@host ~]# nmcli con add con-name eno2 \
type ethernet ifname eno2
Connection 'eno2' (8159b66b-3c36-402f-aa4c-2ea933c7a5ce) successfully added

```

The next example creates the eno3 connection for the eno3 device with a static IPv4 network
setting. This command configures the 192.168.0.5 IP address with a network prefix of /24 and
a network gateway of 192.168.0.254. The nmcli connection add command fails if the
connection name that you try to add exists

```sh
[root@host ~]# nmcli con add con-name eno3 type ethernet ifname eno3 \
ipv4.addresses 192.168.0.5/24 ipv4.gateway 192.168.0.254

[root@rocky2 ~]# nmcli con add con-name eno3 type ethernet ifname eno3 \
ipv4.addresses 192.168.0.5/24 ipv4.gateway 192.168.0.254
Connection 'eno3' (974baa06-11f5-4676-b148-4ed64289ebf1) successfully added.
```


```sh
[root@host ~]# nmcli con add con-name eno4 type ethernet ifname eno4 \
ipv6.addresses 2001:db8:0:1::c000:207/64 ipv6.gateway 2001:db8:0:1::1 \
ipv4.addresses 192.0.2.7/24 ipv4.gateway 192.0.2.1
```


## Manage Network Connections

The nmcli connection up command activates a network connection on the device that it is
bound to. Activating a network connection requires the connection name, not the device name.


```sh
[user@host ~]$ nmcli con show
NAME UUID TYPE DEVICE
static-ens3 72ca57a2-f780-40da-b146-99f71c431e2b 802-3-ethernet --
static-ens5 87b53c56-1f5d-4a29-a869-8a7bdaf56dfa 802-3-ethernet --
[root@host ~]# nmcli con up static-ens3
Connection successfully activated (D-Bus active path: /org/freedesktop/
NetworkManager/ActiveConnection/2)
```

The nmcli device disconnect command disconnects the network device and brings down
the connection.


```sh
[root@host ~]# nmcli dev disconnect ens3
```


## Update Network Connection Settings

To list the current settings for a connection, use the nmcli connection show command.
Settings in lowercase are static properties that the administrator can change. Settings in
uppercase are active settings in temporary use for this connection instance.



```sh
[root@host ~]# nmcli con show static-ens3
connection.id: static-ens3
connection.uuid: 87b53c56-1f5d-4a29-a869-8a7bdaf56dfa
connection.interface-name: --
connection.type: 802-3-ethernet
connection.autoconnect: yes
connection.timestamp: 1401803453
connection.read-only: no
connection.permissions:
connection.zone: --
connection.master: --
connection.slave-type: --
connection.secondaries:
connection.gateway-ping-timeout: 0
802-3-ethernet.port: --
802-3-ethernet.speed: 0
802-3-ethernet.duplex: --
802-3-ethernet.auto-negotiate: yes
802-3-ethernet.mac-address: CA:9D:E9:2A:CE:F0
802-3-ethernet.cloned-mac-address: --
802-3-ethernet.mac-address-blacklist:
802-3-ethernet.mtu: auto
802-3-ethernet.s390-subchannels:
802-3-ethernet.s390-nettype: --
802-3-ethernet.s390-options:
ipv4.method: manual
ipv4.dns: 192.168.0.254
ipv4.dns-search: example.com
ipv4.addresses: { ip = 192.168.0.2/24,
 gw = 192.168.0.254 }
ipv4.routes:
ipv4.ignore-auto-routes: no
ipv4.ignore-auto-dns: no
ipv4.dhcp-client-id: --
ipv4.dhcp-send-hostname: yes
ipv4.dhcp-hostname: --
ipv4.never-default: no
ipv4.may-fail: yes
ipv6.method: manual
ipv6.dns: 2001:4860:4860::8888
ipv6.dns-search: example.com
ipv6.addresses: { ip = 2001:db8:0:1::7/64,
 gw = 2001:db8:0:1::1 }
ipv6.routes:
ipv6.ignore-auto-routes: no
ipv6.ignore-auto-dns: no
ipv6.never-default: no
ipv6.may-fail: yes
ipv6.ip6-privacy: -1 (unknown)
ipv6.dhcp-hostname: --
...output omitted...
```

Use the following command to update the static-ens3 connection to set the 192.0.2.2/24
IPv4 address and the 192.0.2.254 default gateway. Use the nmcli command
connection.autoconnect parameter to automatically enable or disable the connection at
system boot

```sh
[root@host ~]# nmcli con mod static-ens3 ipv4.addresses 192.0.2.2/24 \
ipv4.gateway 192.0.2.254 connection.autoconnect yes
```

Use the following command to update the static-ens3 connection to set the
2001:db8:0:1::a00:1/64 IPv6 address and the 2001:db8:0:1::1 default gateway.

```sh
[root@host ~]# nmcli con mod static-ens3 ipv6.addresses 2001:db8:0:1::a00:1/64 \
ipv6.gateway 2001:db8:0:1::1
```

The following example adds the 2.2.2.2 DNS server to the static-ens3 connection

```sh
[root@host ~]# nmcli con mod static-ens3 +ipv4.dns 2.2.2.2
```

you can create complex configurations in steps, and then load the final configuration when ready.
The following example loads all connection profiles

```sh
[root@host ~]# nmcli con reload
```

Delete a Network Connection

```sh
[root@host ~]# nmcli con del static-ens3
```

Permissions to Modify NetworkManager Settings

Use the nmcli general permissions command to view your current permissions. The
following example lists the root user's NetworkManager permissions

```sh
[root@host ~]# nmcli gen permissions
PERMISSION VALUE
org.freedesktop.NetworkManager.checkpoint-rollback yes
org.freedesktop.NetworkManager.enable-disable-connectivity-check yes
org.freedesktop.NetworkManager.enable-disable-network yes
org.freedesktop.NetworkManager.enable-disable-statistics yes
org.freedesktop.NetworkManager.enable-disable-wifi yes
org.freedesktop.NetworkManager.enable-disable-wimax yes
org.freedesktop.NetworkManager.enable-disable-wwan yes
org.freedesktop.NetworkManager.network-control yes
org.freedesktop.NetworkManager.reload yes
org.freedesktop.NetworkManager.settings.modify.global-dns yes
org.freedesktop.NetworkManager.settings.modify.hostname yes
org.freedesktop.NetworkManager.settings.modify.own yes
org.freedesktop.NetworkManager.settings.modify.system yes
org.freedesktop.NetworkManager.sleep-wake yes
org.freedesktop.NetworkManager.wifi.scan yes
org.freedesktop.NetworkManager.wifi.share.open yes
org.freedesktop.NetworkManager.wifi.share.protected yes
```

Useful NetworkManager Commands

| Command | Purpose |
|---------|---------|
| nmcli dev status | Show the NetworkManager status of all network interfaces.
| nmcli con show | List all connections.
| nmcli con show name | List the current settings for the connection name.
| nmcli con add con-name name | Add and name a new connection profile.
| nmcli con mod | name Modify the connection name.
| nmcli con reload | Reload the configuration files, after manual file editing.
| nmcli con up name | Activate the connection name.
| nmcli dev dis dev | Disconnect the interface, which also deactivates the current connection.
| nmcli con del name | Delete the specified connection and its configuration file.





# Edit Network Configuration Files


## Connection Configuration Files

Starting with Red Hat Enterprise Linux 8, network configurations are stored in the /etc/
NetworkManager/system-connections/ directory. This new configuration location uses
the key file format instead of the ifcfg format. However, the previously stored configurations
at /etc/sysconfig/network-scripts/ continue to work. The /etc/NetworkManager/
system-connections/ directory stores any changes with the nmcli con mod name
command.

Redhat 8'den itibaren bu config dosyası değişmiştir.

```sh
[root@rocky2 ~]# cat /etc/sysconfig/network-scripts/readme-ifcfg-rh.txt 
NetworkManager stores new network profiles in keyfile format in the
/etc/NetworkManager/system-connections/ directory.

Previously, NetworkManager stored network profiles in ifcfg format
in this directory (/etc/sysconfig/network-scripts/). However, the ifcfg
format is deprecated. By default, NetworkManager no longer creates
new profiles in this format.

Connection profiles in keyfile format have many benefits. For example,
this format is INI file-based and can easily be parsed and generated.

Each section in NetworkManager keyfiles corresponds to a NetworkManager
setting name as described in the nm-settings(5) and nm-settings-keyfile(5)
man pages. Each key-value-pair in a section is one of the properties
listed in the settings specification of the man page.

If you still use network profiles in ifcfg format, consider migrating
them to keyfile format. To migrate all profiles at once, enter:

# nmcli connection migrate

This command migrates all profiles from ifcfg format to keyfile
format and stores them in /etc/NetworkManager/system-connections/.

Alternatively, to migrate only a specific profile, enter:

# nmcli connection migrate <profile_name|UUID|D-Bus_path>

For further details, see:
* nm-settings-keyfile(5)
* nmcli(1)
```

# Configure Hostnames and Name Resolution

## Update the System Hostname

```sh
[root@host ~]# hostname
host.example.com
```

If this file does not exist, then the hostname is set by a reverse DNS query when an IP address is assigned to the interface

```sh
[root@host ~]# hostnamectl set-hostname host.example.com
[root@host ~]# hostnamectl status
 Static hostname: host.example.com
 Icon name: computer-vm
 Chassis: vm #
 Machine ID: 663e281edea34ffea297bd479a8f12b5
 Boot ID: 74bf3a0a48d540998a74055a0fe38821
 Virtualization: kvm
Operating System: Red Hat Enterprise Linux 9.0 (Plow)
 CPE OS Name: cpe:/o:redhat:enterprise_linux:9::baseos
 Kernel: Linux 5.14.0-70.el9.x86_64
 Architecture: x86-64
 Hardware Vendor: Red Hat
 Hardware Model: OpenStack Compute
[root@host ~]# cat /etc/hostname
host.example.com
```

## Configure Name Resolution


The stub resolver converts hostnames to IP addresses or the reverse. It determines where to look
based on the configuration of the /etc/nsswitch.conf file. By default, it attempts to resolve
the query by first using the /etc/hosts file

```sh
[root@host ~]# cat /etc/hosts
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
172.25.254.254 classroom.example.com
172.25.254.254 content.example.com
```

• search : A list of domain names to try with a short hostname. Either search or domain should be set in the same file; if they are both set, then only the last entry takes effect. See resolv.conf(5) for details.

• nameserver : the IP address of a name server to query. Up to three name server directives can be given to provide backups if one name server is down.

```sh
[root@host ~]# cat /etc/resolv.conf
# Generated by NetworkManager
domain example.com
search example.com
nameserver 172.25.254.254
```

NetworkManager uses DNS settings in the connection configuration files to update the /etc/
resolv.conf file. Use the nmcli command to modify the connections

```sh
[root@host ~]# nmcli con mod ID ipv4.dns IP
[root@host ~]# nmcli con down ID
[root@host ~]# nmcli con up ID
[root@host ~]# cat /etc/sysconfig/network-scripts/ifcfg-ID
...output omitted...
DNS1=8.8.8.8
...output omitted...
```

The default behavior of the nmcli con mod ID ipv4.dns IP command is to replace any
previous DNS settings with the new IP list that is provided. A plus (+) or minus (-) character in
front of the nmcli command ipv4.dns option adds or removes an individual entry, respectively.

```sh
[root@host ~]# nmcli con mod ID +ipv4.dns IP
```

To add the DNS server with an IPv6 IP address of 2001:4860:4860::8888 to the list of name
servers on the static-ens3 connection:

```sh
[root@host ~]# nmcli con mod static-ens3 +ipv6.dns 2001:4860:4860::8888
```

Test DNS Name Resolution


```sh
[root@host ~]# host classroom.example.com
classroom.example.com has address 172.25.254.254
[root@host ~]# host 172.25.254.254
254.254.25.172.in-addr.arpa domain name pointer classroom.example.com.
```

DHCP automatically rewrites the /etc/resolv.conf file when interfaces are
started, unless you specify PEERDNS=no in the relevant interface configuration files.
Set this entry by using the nmcli command

```sh
[root@host ~]# nmcli con mod "static-ens3" ipv4.ignore-auto-dns yes
```

Use the dig HOSTNAME command to test DNS server connectivity

```sh
[root@host ~]# dig classroom.example.com
; <<>> DiG 9.16.23-RH <<>> classroom.example.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3451
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 13, ADDITIONAL: 27
;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 947ea2a936353423c3bc0d5f627cc1ae7147460e10d2777c (good)
;; QUESTION SECTION:
;classroom.example.com. IN A
;; ANSWER SECTION:
classroom.example.com. 85326 IN A 172.25.254.254
...output omitted...
```

Both the host and dig commands do not view the configuration in the /etc/hosts file. To test
the /etc/hosts file, use the getent hosts HOSTNAME command


```sh
[root@host ~]# getent hosts classroom.example.com
172.25.254.254 classroom.example.com
```

