# Register Systems for Red Hat Support

## Red Hat Subscription Management

• Register a system to associate it with the Red Hat account with an active subscription. With the
Subscription Manager, the system can register uniquely in the subscription service inventory.
You can unregister the system when not in use.

• Subscribe a system to entitle it to updates for the selected Red Hat products. Subscriptions
have specific levels of support, expiration dates, and default repositories. The tools help to
either auto-attach or select a specific entitlement.

• Enable repositories to provide software packages. By default, each subscription enables multiple
repositories; other repositories such as updates or source code are enabled or disabled.

• Review and track available or consumed entitlements. In the Red Hat Customer Portal, you might
view the subscription information locally on a specific system or for a Red Hat account.


## Subscribe a System with the Command Line

Register a system by using the credentials of the Red Hat Customer Portal as the root user

```sh
[root@host ~]# subscription-manager register --username <yourusername>
Registering to: subscription.rhsm.redhat.com:443/subscription
Password: yourpassword
The system has been registered with ID: 1457f7e9-f37e-4e93-960a-c94fe08e1b4f
The registered system name is: host.example.com
```

View available subscriptions for your Red Hat account


```sh
[root@host ~]# subscription-manager list --available
-------------------------------------------
 Available Subscriptions
-------------------------------------------
...output omitted...
[root@host ~]# subscription-manager attach --auto
...output omitted...
```

Alternatively, attach a subscription from a specific pool from the list of available subscriptions

```sh
[root@host ~]# subscription-manager attach --pool=poolID
...output omitted...
```

View consumed subscriptions

```sh
[root@host ~]# subscription-manager list --consumed
...output omitted...
```

Unregister a system

```sh
[root@host ~]# subscription-manager unregister
Unregistering from: subscription.rhsm.redhat.com:443/subscription
System has been unregistered.
```

## Entitlement Certificates

• /etc/pki/product certificates indicates installed Red Hat products.

• /etc/pki/consumer certificates identifies the Red Hat account for registration.

• /etc/pki/entitlement certificates indicate which subscriptions are attached.

The rct command inspects the certificates and the subscription-manager command
examines the attached subscriptions on the system


# Explain and Investigate RPM Software Packages


## Software Packages and RPM


RPM package file names consist of four elements (plus the .rpm suffix): name-version release.architecture

Coreutils-8.32-31.el9.x86_64.rpm

Coreutils --> Name

8.32 --> Version

31.el9 --> Release

x86_64 --> Arch


• NAME is one or more words describing the contents (coreutils).

• VERSION is the version number of the original software (8.32).

• RELEASE is the release number of the package based on that version, and is set by the
packager, who might not be the original software developer (31.el9).

• ARCH is the processor architecture the package is compiled to run on. The x86_64 value
indicates that this package is built for the 64-bit version of the x86 instruction set (as opposed
to aarch64 for 64-bit ARM, and so on).


rpm -qa : List all installed packages(kurulu olan tüm rpm'ler)

```sh
[root@rocky2 ~]# rpm -qa
filesystem-3.16-2.el9.x86_64
python3-setuptools-wheel-53.0.0-12.el9.noarch
publicsuffix-list-dafsa-20210518-3.el9.noarch
ncurses-base-6.2-10.20210508.el9.noarch
ncurses-libs-6.2-10.20210508.el9.x86_64
.
.
less-590-3.el9_3.x86_64
numactl-libs-2.0.16-3.el9.x86_64
iwl7260-firmware-25.30.13.0-143.el9.noarch
iwl6050-firmware-41.28.5.1-143.el9.noarch
iwl6000g2a-firmware-18.168.6.1-143.el9.noarch
iwl5150-firmware-8.24.2.2-143.el9.noarch
iwl5000-firmware-8.83.5.1_1-143.el9.noarch
iwl3160-firmware-25.30.13.0-143.el9.noarch
iwl2030-firmware-18.168.6.1-143.el9.noarch
iwl2000-firmware-18.168.6.1-143.el9.noarch
iwl135-firmware-18.168.6.1-143.el9.noarch
iwl105-firmware-18.168.6.1-143.el9.noarch
iwl1000-firmware-39.31.5.1-143.el9.noarch
iwl100-firmware-39.31.5.1-143.el9.noarch
hwdata-0.348-9.13.el9.noarch
tar-1.34-6.el9_1.x86_64
```


• rpm -qf FILENAME : Determine what package provides FILENAME

```sh
[user@host ~]$ rpm -qf /etc/yum.repos.d
redhat-release-9.1-1.0.el9.x86_64

[root@rocky2 ~]# rpm -qf /etc/ssh
openssh-8.7p1-38.el9.x86_64
```

• rpm -q : Lists the currently installed package version

```sh
[user@host ~]$ rpm -q dnf
dnf-4.10.0-4.el9.noarch

[root@rocky2 ~]# rpm -q tar
tar-1.34-6.el9_1.x86_64
```


• rpm -qi : Get detailed package information

```sh
[root@rocky2 ~]# rpm -qi sudo
Name        : sudo
Version     : 1.9.5p2
Release     : 10.el9_3
Architecture: x86_64
Install Date: Wed 29 May 2024 06:29:12 PM +03
Group       : Unspecified
Size        : 4158030
License     : ISC
Signature   : RSA/SHA256, Wed 14 Feb 2024 10:30:27 PM +03, Key ID 702d426d350d275d
Source RPM  : sudo-1.9.5p2-10.el9_3.src.rpm
Build Date  : Wed 14 Feb 2024 10:21:44 PM +03
Build Host  : pb-9e429f59-5a4f-4a20-a90a-dbc3d1c6a5c0-b-x86-64
Packager    : Rocky Linux Build System (Peridot) <releng@rockylinux.org>
Vendor      : Rocky Enterprise Software Foundation
URL         : https://www.sudo.ws
Summary     : Allows restricted root access for specified users
Description :
Sudo (superuser do) allows a system administrator to give certain
users (or groups of users) the ability to run some (or all) commands
as root while logging all commands and arguments. Sudo operates on a
per-command basis.  It is not a replacement for the shell.  Features
include: the ability to restrict what commands a user may run on a
per-host basis, copious logging of each command (providing a clear
audit trail of who did what), a configurable timeout of the sudo
command, and the ability to use the same configuration file (sudoers)
on many different machines.
```

• rpm -ql : List the files that the package installs

paketin hangi dizinlerde dosyası bulunuyor


```sh
[user@host ~]$ rpm -ql dnf
/usr/bin/dnf
/usr/lib/systemd/system/dnf-makecache.service
/usr/lib/systemd/system/dnf-makecache.timer
/usr/share/bash-completion
/usr/share/bash-completion/completions
/usr/share/bash-completion/completions/dnf
...output omitted...

[root@rocky2 ~]# rpm -ql openssh
/etc/ssh
/etc/ssh/moduli
/usr/bin/ssh-keygen
/usr/lib/.build-id
/usr/lib/.build-id/35
/usr/lib/.build-id/35/cb00dc004ba59c7863720b8e39d2b07e8f7758
/usr/lib/.build-id/c3
/usr/lib/.build-id/c3/485e9b27a35b6c4e3e8810b697b3c6a6a42dd4
/usr/lib/sysusers.d/openssh.conf
/usr/libexec/openssh
/usr/libexec/openssh/ssh-keysign
/usr/share/doc/openssh
/usr/share/doc/openssh/CREDITS
/usr/share/doc/openssh/ChangeLog
/usr/share/doc/openssh/OVERVIEW
/usr/share/doc/openssh/PROTOCOL
/usr/share/doc/openssh/PROTOCOL.agent
/usr/share/doc/openssh/PROTOCOL.certkeys
/usr/share/doc/openssh/PROTOCOL.chacha20poly1305
/usr/share/doc/openssh/PROTOCOL.cve-2023-48795
/usr/share/doc/openssh/PROTOCOL.key
/usr/share/doc/openssh/PROTOCOL.krl
/usr/share/doc/openssh/PROTOCOL.mux
/usr/share/doc/openssh/PROTOCOL.sshsig
/usr/share/doc/openssh/PROTOCOL.u2f
/usr/share/doc/openssh/README
/usr/share/doc/openssh/README.dns
/usr/share/doc/openssh/README.platform
/usr/share/doc/openssh/README.privsep
/usr/share/doc/openssh/README.tun
/usr/share/doc/openssh/TODO
/usr/share/licenses/openssh
/usr/share/licenses/openssh/LICENCE
/usr/share/man/man1/ssh-keygen.1.gz
/usr/share/man/man8/ssh-keysign.8.gz
```


• rpm -qc : List only the configuration files that the package installs

config dosyalarını gösterir

```sh
[root@rocky2 ~]# rpm -qc openssh-clients
/etc/ssh/ssh_config
/etc/ssh/ssh_config.d/50-redhat.conf
```

• rpm -qd : List only the documentation files that the package installs

```sh
[user@host ~]$ rpm -qd openssh-clients
/usr/share/man/man1/scp.1.gz
/usr/share/man/man1/sftp.1.gz
/usr/share/man/man1/ssh-add.1.gz
/usr/share/man/man1/ssh-agent.1.gz
...output omitted...
```


• rpm -q --scripts : List the shell scripts that run before or after you install or remove the
package

scriptleri görüntüler

```sh
[root@rocky2 ~]# rpm -q --scripts openssh-server
preinstall scriptlet (using /bin/sh):

# generated from openssh-server-systemd-sysusers.conf
getent group 'sshd' >/dev/null || groupadd -f -g '74' -r 'sshd' || :
if ! getent passwd 'sshd' >/dev/null; then
    if ! getent passwd '74' >/dev/null; then
        useradd -r -u '74' -g 'sshd' -d '/usr/share/empty.sshd' -s '/usr/sbin/nologin' -c 'Privilege-separated SSH' 'sshd' || :
    else
        useradd -r -g 'sshd' -d '/usr/share/empty.sshd' -s '/usr/sbin/nologin' -c 'Privilege-separated SSH' 'sshd' || :
    fi
fi
postinstall scriptlet (using /bin/sh):


if [ $1 -eq 1 ] && [ -x "/usr/lib/systemd/systemd-update-helper" ]; then
    # Initial installation
    /usr/lib/systemd/systemd-update-helper install-system-units sshd.service sshd.socket || :
fi

# Migration scriptlet for Fedora 31 and 32 installations to sshd_config
# drop-in directory (in F32+).
# Do this only if the file generated by anaconda exists, contains our config
# directive and sshd_config contains include directive as shipped in our package
test -f /etc/sysconfig/sshd-permitrootlogin && \
  test ! -f /etc/ssh/sshd_config.d/01-permitrootlogin.conf && \
  grep -q '^PERMITROOTLOGIN="-oPermitRootLogin=yes"' /etc/sysconfig/sshd-permitrootlogin && \
  grep -q '^Include /etc/ssh/sshd_config.d/\*.conf' /etc/ssh/sshd_config && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.d/25-permitrootlogin.conf && \
  rm /etc/sysconfig/sshd-permitrootlogin || :
preuninstall scriptlet (using /bin/sh):


if [ $1 -eq 0 ] && [ -x "/usr/lib/systemd/systemd-update-helper" ]; then
    # Package removal, not upgrade
    /usr/lib/systemd/systemd-update-helper remove-system-units sshd.service sshd.socket || :
fi
postuninstall scriptlet (using /bin/sh):


if [ $1 -ge 1 ] && [ -x "/usr/lib/systemd/systemd-update-helper" ]; then
    # Package upgrade, not uninstall
    /usr/lib/systemd/systemd-update-helper mark-restart-system-units sshd.service || :
fi
```


• rpm -q --changelog : List the change log information for the package

```sh
[user@host ~]$ rpm -q --changelog audit
* Tue Feb 22 2022 Sergio Correia <scorreia@redhat.com> - 3.0.7-101
- Adjust sample-rules dir permissions
 Resolves: rhbz#2054432 - /usr/share/audit/sample-rules is no longer readable by
 non-root users
* Tue Jan 25 2022 Sergio Correia <scorreia@redhat.com> - 3.0.7-100
- New upstream release, 3.0.7
 Resolves: rhbz#2019929 - capability=unknown-capability(39) in audit messages
...output omitted...
```


• rpm -qlp : List the files that the local package installs

```sh
[user@host ~]$ ls -l podman-4.0.0-6.el9.x86_64.rpm
-rw-r--r--. 1 student student 13755101 Mar 22 11:35
 podman-4.0.0-6.el9.x86_64.rpm2637-15.el9.x86_64.rpm


 [user@host ~]$ rpm -qlp podman-4.0.0-6.el9.x86_64.rpm
/etc/cni/net.d
/etc/cni/net.d/87-podman-bridge.conflist
/usr/bin/podman
...output omitted...

```



## Install RPM Packages





```sh
[root@host ~]# rpm -ivh podman-4.0.0-6.el9.x86_64.rpm
Verifying... ################################# [100%]
Preparing... ################################# [100%]
Updating / installing...
 podman-2:4.0.0-6 ################################# [100%]

```

Ayrıntılı loglama için iki v (-ivvh) veya üç v (-ivvvh) kullanılabilir


```sh
[root@rocky2 ~]# rpm -ivvvh gzip-1.12-1.el9.aarch64.rpm 
ufdio:       1 reads,    17654 total bytes in 0.000007 secs
D: ============== gzip-1.12-1.el9.aarch64.rpm
D: loading keyring from pubkeys in /var/lib/rpm/pubkeys/*.key
D: couldn't find any keys in /var/lib/rpm/pubkeys/*.key
D: loading keyring from rpmdb
D: PRAGMA secure_delete = OFF: 0
D: PRAGMA case_sensitive_like = ON: 0
D:  read h#     342
Header SHA256 digest: OK
Header SHA1 digest: OK
D: added key gpg-pubkey-350d275d-6279464b to keyring
D: Using legacy gpg-pubkey(s) from rpmdb
warning: gzip-1.12-1.el9.aarch64.rpm: Header V3 RSA/SHA256 Signature, key ID 8483c65d: NOKEY
D: gzip-1.12-1.el9.aarch64.rpm: Header SHA256 digest: OK
D: gzip-1.12-1.el9.aarch64.rpm: Header SHA1 digest: OK
ufdio:       6 reads,    19661 total bytes in 0.000057 secs
D: Plugin: calling hook init in systemd_inhibit plugin
D:      added binary package [0]
D: found 0 source and 1 binary packages
D: ========== +++ gzip-1.12-1.el9 aarch64/linux 0x2
D:  read h#     353 
Header V4 RSA/SHA256 Signature, key ID 350d275d: OK
Header SHA256 digest: OK
Header SHA1 digest: OK
D:  Requires: /usr/bin/sh                                   YES (db files)
D:  read h#     412
Header V4 RSA/SHA256 Signature, key ID 350d275d: OK
Header SHA256 digest: OK
Header SHA1 digest: OK
D:  Requires: coreutils                                     YES (db provides)
D:  Requires: ld-linux-aarch64.so.1()(64bit)                NO  
D:  Requires: ld-linux-aarch64.so.1(GLIBC_2.17)(64bit)      NO
D:  read h#     357
Header V4 RSA/SHA256 Signature, key ID 350d275d: OK
Header SHA256 digest: OK
Header SHA1 digest: OK
D:  Requires: libc.so.6()(64bit)                            YES (db provides)
D:  Requires: libc.so.6(GLIBC_2.17)(64bit)                  YES (db provides)
D:  Requires: libc.so.6(GLIBC_2.33)(64bit)                  YES (db provides)
D:  Requires: libc.so.6(GLIBC_2.34)(64bit)                  YES (db provides)
D:  Requires: rpmlib(CompressedFileNames) <= 3.0.4-1        YES (rpmlib provides)
D:  Requires: rpmlib(FileDigests) <= 4.6.0-1                YES (rpmlib provides)
D:  Requires: rpmlib(PayloadFilesHavePrefix) <= 4.0-1       YES (rpmlib provides)
D:  Requires: rpmlib(PayloadIsZstd) <= 5.4.18-1             YES (rpmlib provides)
D:  Requires: rtld(GNU_HASH)                                YES (db provides)
D:  read h#      10 
Header V4 RSA/SHA256 Signature, key ID 350d275d: OK
Header SHA256 digest: OK
Header SHA1 digest: OK
D: Conflicts: filesystem < 3                                NO
error: Failed dependencies:
        ld-linux-aarch64.so.1()(64bit) is needed by gzip-1.12-1.el9.aarch64
        ld-linux-aarch64.so.1(GLIBC_2.17)(64bit) is needed by gzip-1.12-1.el9.aarch64
D: Exit status: 1
```


The example cpio command creates subdirectories as needed, in the current working directory

```sh
[user@host tmp-extract]$ rpm2cpio wonderwidgets-1.0-4.x86_64.rpm | cpio -id
```


Extract individual files by specifying the path of the file

```sh
[user@host ~]$ rpm2cpio wonderwidgets-1.0-4.x86_64.rpm | cpio -id "*txt"
11 blocks
[user@host ~]$ ls -l usr/share/doc/wonderwidgets-1.0/
total 4
-rw-r--r--. 1 user user 76 Feb 13 19:27 README.txt

```



# Install and Update Software Packages with DNF



## Manage Software Packages with DNF


YUM commands still exist as symbolic links to DNF

```sh
[user@host ~]$ ls -l /bin/ | grep yum | awk '{print $9 " " $10 " " $11}'
yum -> dnf-3
yum-builddep -> /usr/libexec/dnf-utils
yum-config-manager -> /usr/libexec/dnf-utils
yum-debug-dump -> /usr/libexec/dnf-utils
yum-debug-restore -> /usr/libexec/dnf-utils
yumdownloader -> /usr/libexec/dnf-utils
yum-groups-manager -> /usr/libexec/dnf-utils
```

Find Software with DNF


```sh
[user@host ~]$ dnf list 'http*'
Available Packages
http-parser.i686 2.9.4-6.el9 rhel-9.0-for-x86_64-appstream-rpms
http-parser.x86_64 2.9.4-6.el9 rhel-9.0-for-x86_64-appstream-rpms
httpcomponents-client.noarch 4.5.13-2.el9 rhel-9.0-for-x86_64-appstream-rpms
httpcomponents-core.noarch 4.4.13-6.el9 rhel-9.0-for-x86_64-appstream-rpms
httpd.x86_64 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms
httpd-devel.x86_64 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms
httpd-filesystem.noarch 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms
httpd-manual.noarch 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms
httpd-tools.x86_64 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms
```

The dnf search KEYWORD command lists packages by keywords found in the name and
summary fields only. To search for packages with "web server" in their name, summary, and
description fields, use search all

```sh
[user@host ~]$ dnf search all 'web server'
================== Summary & Description Matched: web server ===================
nginx.x86_64 : A high performance web server and reverse proxy server
pcp-pmda-weblog.x86_64 : Performance Co-Pilot (PCP) metrics from web server logs
========================= Summary Matched: web server ==========================
libcurl.x86_64 : A library for getting files from web servers
libcurl.i686 : A library for getting files from web servers
======================= Description Matched: web server ========================
freeradius.x86_64 : High-performance and highly configurable free RADIUS server
git-instaweb.noarch : Repository browser in gitweb
http-parser.i686 : HTTP request/response parser for C
http-parser.x86_64 : HTTP request/response parser for C
httpd.x86_64 : Apache HTTP Server
mod_auth_openidc.x86_64 : OpenID Connect auth module for Apache HTTP Server
mod_jk.x86_64 : Tomcat mod_jk connector for Apache
mod_security.x86_64 : Security module for the Apache HTTP Server
varnish.i686 : High-performance HTTP accelerator
varnish.x86_64 : High-performance HTTP accelerator
...output omitted...
```


The dnf info PACKAGENAME command returns detailed information about a package, including
the needed disk space for installation. For example, the following command retrieves information
about the httpd package

```sh
[root@rocky2 ~]# dnf info httpd
Last metadata expiration check: 2:56:16 ago on Mon 12 Aug 2024 06:25:56 PM +03.
Available Packages
Name         : httpd
Version      : 2.4.57
Release      : 11.el9_4.1
Architecture : x86_64
Size         : 44 k
Source       : httpd-2.4.57-11.el9_4.1.src.rpm
Repository   : appstream
Summary      : Apache HTTP Server
URL          : https://httpd.apache.org/
License      : ASL 2.0
Description  : The Apache HTTP Server is a powerful, efficient, and extensible
             : web server.
```


The dnf provides PATHNAME command displays packages that match the specified path name
(the path names often include wildcard characters). For example, the following command finds
packages that provide the /var/www/html directory

```sh
[root@rocky2 ~]# dnf provides /var/www/html
Last metadata expiration check: 2:56:58 ago on Mon 12 Aug 2024 06:25:56 PM +03.

httpd-filesystem-2.4.57-11.el9_4.1.noarch : The basic directory layout for the Apache HTTP Server
Repo        : appstream
Matched from:
Filename    : /var/www/html
```

Install and Remove Software with DNF

The dnf install PACKAGENAME command obtains and installs a software package, including
any dependencies

```sh
[root@host ~]# dnf install httpd
Dependencies resolved.
================================================================================
 Package Arch Version Repository Size
================================================================================
Installing:
 httpd x86_64 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms 1.5 M
Installing dependencies:
 apr x86_64 1.7.0-11.el9 rhel-9.0-for-x86_64-appstream-rpms 127 k
 apr-util x86_64 1.6.1-20.el9 rhel-9.0-for-x86_64-appstream-rpms 98 k
 apr-util-bdb x86_64 1.6.1-20.el9 rhel-9.0-for-x86_64-appstream-rpms 15 k
 httpd-filesystem noarch 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms 17 k
 httpd-tools x86_64 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms 88 k
 redhat-logos-httpd
 noarch 90.4-1.el9 rhel-9.0-for-x86_64-appstream-rpms 18 k
Installing weak dependencies:
 apr-util-openssl x86_64 1.6.1-20.el9 rhel-9.0-for-x86_64-appstream-rpms 17 k
 mod_http2 x86_64 1.15.19-2.el9 rhel-9.0-for-x86_64-appstream-rpms 153 k
 mod_lua x86_64 2.4.51-5.el9 rhel-9.0-for-x86_64-appstream-rpms 63 k
Transaction Summary
================================================================================
Install 10 Packages
Total download size: 2.1 M
Installed size: 5.9 M
Is this ok [y/N]: y
Downloading Packages:
(1/10): apr-1.7.0-11.el9.x86_64.rpm 6.4 MB/s | 127 kB 00:00
(2/10): apr-util-bdb-1.6.1-20.el9.x86_64.rpm 625 kB/s | 15 kB 00:00
(3/10): apr-util-openssl-1.6.1-20.el9.x86_64.rp 1.9 MB/s | 17 kB 00:00
...output omitted...
Total 24 MB/s | 2.1 MB 00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
 Preparing : 1/1
 Installing : apr-1.7.0-11.el9.x86_64 1/10
 Installing : apr-util-bdb-1.6.1-20.el9.x86_64 2/10
 Installing : apr-util-openssl-1.6.1-20.el9.x86_64 3/10
...output omitted...
Installed:
 apr-1.7.0-11.el9.x86_64 apr-util-1.6.1-20.el9.x86_64
 apr-util-bdb-1.6.1-20.el9.x86_64 apr-util-openssl-1.6.1-20.el9.x86_64
...output omitted...
Complete!
```

The dnf update PACKAGENAME command obtains and installs a newer version of the specified
package, including any dependencies.

```sh
[root@host ~]# dnf update
```

Use the dnf list kernel command to list all installed and available kernels. To view the
currently running kernel, use the uname command. The uname command -r option shows only
the kernel version and release, and the uname command -a option shows the kernel release and
additional information

```sh
[root@rocky2 ~]# dnf list kernel
Last metadata expiration check: 3:08:05 ago on Mon 12 Aug 2024 06:25:56 PM +03.
Installed Packages
kernel.x86_64                                                            5.14.0-362.8.1.el9_3                                                             @minimal
kernel.x86_64                                                            5.14.0-427.18.1.el9_4                                                            @baseos 
Available Packages
kernel.x86_64                                                            5.14.0-427.28.1.el9_4                                                            baseos  
[root@rocky2 ~]# uname -r
5.14.0-427.18.1.el9_4.x86_64
[root@rocky2 ~]# uname -a
Linux rocky2 5.14.0-427.18.1.el9_4.x86_64 #1 SMP PREEMPT_DYNAMIC Mon May 27 16:35:12 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```


The dnf remove PACKAGENAME command removes an installed software package, including any
supported packages

```sh
[root@host ~]# dnf remove httpd
```

Install and Remove Groups of Software with DNF


```sh
[root@rocky2 ~]# dnf group list
Last metadata expiration check: 3:09:30 ago on Mon 12 Aug 2024 06:25:56 PM +03.
Available Environment Groups:
   Server with GUI
   Server
   Workstation
   Custom Operating System
   Virtualization Host
Installed Environment Groups:
   Minimal Install
Available Groups:
   Legacy UNIX Compatibility
   Console Internet Tools
   Container Management
   Development Tools
   .NET Development
   Graphical Administration Tools
   Headless Management
   Network Servers
   RPM Development Tools
   Scientific Support
   Security Tools
   Smart Card Support
   System Tools
```

The dnf group info command displays information about a group. It includes a list of
mandatory, default, and optional package names

```sh
[root@rocky2 ~]# dnf group info "RPM Development Tools"
Last metadata expiration check: 3:10:11 ago on Mon 12 Aug 2024 06:25:56 PM +03.
Group: RPM Development Tools
 Description: Tools used for building RPMs, such as rpmbuild.
 Mandatory Packages:
   redhat-rpm-config
   rpm-build
 Default Packages:
   rpmdevtools
 Optional Packages:
   rpmlint
```

The dnf group install command installs a group that installs its mandatory and default
packages and their dependent packages

```sh
[root@host ~]# dnf group install "RPM Development Tools"
...output omitted...
Installing Groups:
 RPM Development Tools
Transaction Summary
================================================================================
Install 19 Packages
Total download size: 4.7 M
Installed size: 15 M
Is this ok [y/N]: y
...output omitted...

```

View Transaction History


All installation and removal transactions are logged in the /var/log/dnf.rpm.log file

```sh
[user@host ~]$ tail -5 /var/log/dnf.rpm.log
2022-03-23T16:46:43-0400 SUBDEBUG Installed: python-srpm-macros-3.9-52.el9.noarch
2022-03-23T16:46:43-0400 SUBDEBUG Installed: redhat-rpm-config-194-1.el9.noarch
2022-03-23T16:46:44-0400 SUBDEBUG Installed: elfutils-0.186-1.el9.x86_64
2022-03-23T16:46:44-0400 SUBDEBUG Installed: rpm-build-4.16.1.3-11.el9.x86_64
2022-03-23T16:46:44-0400 SUBDEBUG Installed: rpmdevtools-9.5-1.el9.noarch
```

The dnf history command displays a summary of installation and removal transactions

```sh
[root@host ~]# dnf history
ID | Command line | Date and time | Action(s) | Altered
--------------------------------------------------------------------------------
 7 | group install RPM Develop | 2022-03-23 16:46 | Install | 20
 6 | install httpd | 2022-03-23 16:21 | Install | 10 EE
 5 | history undo 4 | 2022-03-23 15:04 | Removed | 20
 4 | group install RPM Develop | 2022-03-23 15:03 | Install | 20
 3 | | 2022-03-04 03:36 | Install | 5
 2 | | 2022-03-04 03:33 | Install | 767 EE
 1 | -y install patch ansible- | 2022-03-04 03:31 | Install | 80

```

The dnf history undo command reverses a transaction

```sh
[root@host ~]# dnf history undo 6
...output omitted...
Removing:
 apr-util-openssl x86_64 1.6.1-20.el9 @rhel-9.0-for-x86_64-appstream-rpms 24 k
 httpd x86_64 2.4.51-5.el9 @rhel-9.0-for-x86_64-appstream-rpms 4.7 M
...output omitted...
```


Summary of DNF Commands


| Task: | Command: |
|-------|----------|
| List installed and available packages by name  | dnf list [NAME-PATTERN] |
| List installed and available groups | dnf group list |
| Search for a package by keyword | dnf search KEYWORD |
| Show details of a package | dnf info PACKAGENAME |
| Install a package | dnf install PACKAGENAME |
| Install a package group | dnf group install GROUPNAME |
| Update all packages | dnf update |
| Remove a package | dnf remove PACKAGENAME |
| Display transaction history | dnf history |


## Manage Package Module Streams with DNF




Manage Modules with DNF


You can find some important commands when managing modules in the following list:
• dnf module list : List the available modules with the module name, stream, profiles, and a
summary.

• dnf module list module-name : List the module streams for a specific module and
retrieve their status.

• dnf module info module-name : Display details of a module, including the available
profiles and a list of the packages that the module installs. Running the dnf module info
command without specifying a module stream lists the packages that are installed from the
default profile and stream. Use the module-name:stream format to view a specific module
stream. Add the --profile option to display information about packages that each of the
module's profiles installed.

• dnf module provides package : Display which module provides a specific package




# Enable DNF Software Repositories


## Enable Red Hat Software Repositories

The dnf repolist all
command lists all available repositories and their statuses

```sh
[user@host ~]$ dnf repolist all
repo id repo name status
rhel-9.0-for-x86_64-appstream-rpms RHEL 9.0 AppStream enabled
rhel-9.0-for-x86_64-baseos-rpms RHEL 9.0 BaseOS enabled


[root@rocky2 ~]# dnf repolist all
repo id                                            repo name                                                                                              status
appstream                                          Rocky Linux 9 - AppStream                                                                              enabled 
appstream-debuginfo                                Rocky Linux 9 - AppStream - Debug                                                                      disabled
appstream-source                                   Rocky Linux 9 - AppStream - Source                                                                     disabled
baseos                                             Rocky Linux 9 - BaseOS                                                                                 enabled 
baseos-debuginfo                                   Rocky Linux 9 - BaseOS - Debug                                                                         disabled
baseos-source                                      Rocky Linux 9 - BaseOS - Source                                                                        disabled
crb                                                Rocky Linux 9 - CRB                                                                                    disabled
crb-debuginfo                                      Rocky Linux 9 - CRB - Debug                                                                            disabled
crb-source                                         Rocky Linux 9 - CRB - Source                                                                           disabled
devel                                              Rocky Linux 9 - Devel WARNING! FOR BUILDROOT ONLY DO NOT LEAVE ENABLED                                 disabled
devel-debuginfo                                    Rocky Linux 9 - Devel Debug WARNING! FOR BUILDROOT ONLY DO NOT LEAVE ENABLED                           disabled
devel-source                                       Rocky Linux 9 - Devel Source WARNING! FOR BUILDROOT ONLY DO NOT LEAVE ENABLED                          disabled
extras                                             Rocky Linux 9 - Extras                                                                                 enabled 
extras-debuginfo                                   Rocky Linux 9 - Extras Debug                                                                           disabled
extras-source                                      Rocky Linux 9 - Extras Source                                                                          disabled
highavailability                                   Rocky Linux 9 - High Availability                                                                      disabled
highavailability-debuginfo                         Rocky Linux 9 - High Availability - Debug                                                              disabled
highavailability-source                            Rocky Linux 9 - High Availability - Source                                                             disabled
nfv                                                Rocky Linux 9 - NFV                                                                                    disabled
nfv-debuginfo                                      Rocky Linux 9 - NFV Debug                                                                              disabled
nfv-source                                         Rocky Linux 9 - NFV Source                                                                             disabled
plus                                               Rocky Linux 9 - Plus                                                                                   disabled
plus-debuginfo                                     Rocky Linux 9 - Plus - Debug                                                                           disabled
plus-source                                        Rocky Linux 9 - Plus - Source                                                                          disabled
resilientstorage                                   Rocky Linux 9 - Resilient Storage                                                                      disabled
resilientstorage-debuginfo                         Rocky Linux 9 - Resilient Storage - Debug                                                              disabled
resilientstorage-source                            Rocky Linux 9 - Resilient Storage - Source                                                             disabled
rt                                                 Rocky Linux 9 - Realtime                                                                               disabled
rt-debuginfo                                       Rocky Linux 9 - Realtime Debug                                                                         disabled
rt-source                                          Rocky Linux 9 - Realtime Source                                                                        disabled
sap                                                Rocky Linux 9 - SAP                                                                                    disabled
sap-debuginfo                                      Rocky Linux 9 - SAP Debug                                                                              disabled
sap-source                                         Rocky Linux 9 - SAP Source                                                                             disabled
saphana                                            Rocky Linux 9 - SAPHANA                                                                                disabled
saphana-debuginfo                                  Rocky Linux 9 - SAPHANA Debug                                                                          disabled
saphana-source                                     Rocky Linux 9 - SAPHANA Source                                                                         disabled
```

The dnf config-manager command can enable and disable repositories. For example, the
following command enables the rhel-9-server-debug-rpms repository

```sh
[user@host ~]$ dnf config-manager --enable rhel-9-server-debug-rpms
```


Add DNF Repositories


```sh
[user@host ~]$ dnf config-manager \
--add-repo="https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/"
Adding repo from: https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/
```

The corresponding .repo file is visible in the /etc/yum.repos.d/ directory

```sh
[user@host ~]$ cd /etc/yum.repos.d
[user@host yum.repos.d]$ cat \
dl.fedoraproject.org_pub_epel_9_Everything_x86_64_.repo
[dl.fedoraproject.org_pub_epel_9_Everything_x86_64_]
name=created by dnf config-manager from https://dl.fedoraproject.org/pub/epel/9/
Everything/x86_64/
baseurl=https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/
enabled=1
```

the following .repo file uses the gpgkey parameter to reference a local key

```sh
[EPEL]
name=EPEL 9
baseurl=https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
```

RPM Configuration Packages for Local Repositories


For example, the following command installs the RHEL9 Extra Packages for Enterprise Linux
(EPEL) repository RPM

```sh
[user@host ~]$ rpm --import \
http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-9
[user@host ~]$ dnf install \
https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
```

The .repo files often list multiple repository references in a single file. Each repository reference
begins with a single-word name in square brackets

```sh
[user@host ~]$ cat /etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=
$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$releasever
...output omitted...
[epel-source]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Source
#baseurl=https://download.example/pub/epel/$releasever/Everything/source/tree/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-
$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$releasever
gpgcheck=1
```









