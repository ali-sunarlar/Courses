# Control Services and Daemons


## List Service Units

```sh
[user@rocky2 ~]$ systemctl list-units --type=service
  UNIT                               LOAD   ACTIVE SUB     DESCRIPTION
  auditd.service                     loaded active running Security Auditing Service
  crond.service                      loaded active running Command Scheduler
  dbus-broker.service                loaded active running D-Bus System Message Bus
  dracut-shutdown.service            loaded active exited  Restore /run/initramfs on shutdown
  firewalld.service                  loaded active running firewalld - dynamic firewall daemon
  getty@tty1.service                 loaded active running Getty on tty1
```

UNIT

The service unit name.(servisin ismi)

LOAD

Whether the systemd daemon properly parsed the unit's configuration and loaded the unit into memory.(memory'e yüklü çalışmaya hazır olduğunu gösterir)

ACTIVE

The high-level activation state of the unit. This information indicates whether the unit startedsuccessfully.(yapıda yüklü olduğunu gösterir)

SUB

The low-level activation state of the unit. This information indicates more detailed information about the unit. The information varies based on unit type, state, and how the unit is executed.(şuanki durumunu gösterir)

DESCRIPTION

The short description of the unit.(açıklama)

 Use the --state= option to filter by the values in the LOAD, ACTIVE, or SUB fields.

(aktif olmayıp çalışmayan servislerin çıktısı görüntülenir)

```sh
[user@rocky2 ~]$ systemctl list-units --type=service --all
  UNIT                                   LOAD      ACTIVE   SUB     DESCRIPTION
  auditd.service                         loaded    active   running Security Auditing Service
● autofs.service                         not-found inactive dead    autofs.service
  crond.service                          loaded    active   running Command Scheduler
  dbus-broker.service                    loaded    active   running D-Bus System Message Bus
● display-manager.service                not-found inactive dead    display-manager.service
  dm-event.service                       loaded    inactive dead    Device-mapper event daemon
  dnf-makecache.service                  loaded    inactive dead    dnf makecache
  dracut-cmdline.service                 loaded    inactive dead    dracut cmdline hook
  dracut-initqueue.service               loaded    inactive dead    dracut initqueue hook
```

socket bazlı servislerin çıktısı. Ağ-Network üzerinden kullanılıyorsa

```sh
[user@rocky2 ~]$ systemctl list-units --type=socket
  UNIT                            LOAD   ACTIVE SUB       DESCRIPTION
  dbus.socket                     loaded active running   D-Bus System Message Bus Socket
  dm-event.socket                 loaded active listening Device-mapper event daemon FIFOs
  lvm2-lvmpolld.socket            loaded active listening LVM2 poll daemon socket
  sssd-kcm.socket                 loaded active listening SSSD Kerberos Cache Manager responder socket
  systemd-coredump.socket         loaded active listening Process Core Dump Socket
  systemd-initctl.socket          loaded active listening initctl Compatibility Named Pipe
  systemd-journald-dev-log.socket loaded active running   Journal Socket (/dev/log)

```

bütün servislerin çıktısı.

Loaded memory e yüklü ve çalışmaya hazır olduğunu gösterir

Active yapıda yüklü olduğunu gösterir

Sub service nin şuanki durumu gösterir



```sh
[user@rocky2 ~]$ systemctl list-units --type=service
  UNIT                               LOAD   ACTIVE SUB     DESCRIPTION
  auditd.service                     loaded active running Security Auditing Service
  crond.service                      loaded active running Command Scheduler
  dbus-broker.service                loaded active running D-Bus System Message Bus
  dracut-shutdown.service            loaded active exited  Restore /run/initramfs on shutdown
  firewalld.service                  loaded active running firewalld - dynamic firewall daemon
  getty@tty1.service                 loaded active running Getty on tty1
```

The systemctl command without any arguments lists units that are both loaded and active.

```sh
[user@rocky2 ~]$ systemctl
  UNIT                                                                                                     LOAD   ACTIVE SUB       DESCRIPTION                                                   >
  proc-sys-fs-binfmt_misc.automount                                                                        loaded active running   Arbitrary Executable File Formats File System Automount Point >
  sys-devices-pci0000:00-0000:00:07.1-ata2-host1-target1:0:0-1:0:0:0-block-sr0.device                      loaded active plugged   VMware_Virtual_IDE_CDROM_Drive Rocky-9-3-x86_64-dvd
  sys-devices-pci0000:00-0000:00:11.0-0000:02:00.0-usb1-1\x2d2-1\x2d2.1-1\x2d2.1:1.0-bluetooth-hci0.device loaded active plugged   /sys/devices/pci0000:00/0000:00:11.0/0000:02:00.0/usb1/1-2/1-2>
  sys-devices-pci0000:00-0000:00:11.0-0000:02:01.0-sound-card0-controlC0.device                            loaded active plugged   /sys/devices/pci0000:00/0000:00:11.0/0000:02:01.0/sound/card0/>
  sys-devices-pci0000:00-0000:00:15.0-0000:03:00.0-net-ens160.device                                       loaded active plugged   VMXNET3 Ethernet Controller
  sys-devices-pci0000:00-0000:00:16.0-0000:0b:00.0-nvme-nvme0-nvme0n1-nvme0n1p1.device                     loaded active plugged   VMware Virtual NVMe Disk 1
  sys-devices-pci0000:00-0000:00:16.0-0000:0b:00.0-nvme-nvme0-nvme0n1-nvme0n1p2.device                     loaded active plugged   VMware Virtual NVMe Disk 2
```

manuel

```sh
[user@rocky2 ~]$ man systemctl

SYSTEMCTL(1)                                                                              systemctl                                                                              SYSTEMCTL(1)

NAME
       systemctl - Control the systemd system and service manager

SYNOPSIS
       systemctl [OPTIONS...] COMMAND [UNIT...]

DESCRIPTION
       systemctl may be used to introspect and control the state of the "systemd" system and service manager. Please refer to systemd(1) for an introduction into the basic concepts and
       functionality this tool manages.

COMMANDS
       The following commands are understood:

   Unit Commands (Introspection and Modification)
       list-units [PATTERN...]
           List units that systemd currently has in memory. This includes units that are either referenced directly or through a dependency, units that are pinned by applications
           programmatically, or units that were active in the past and have failed. By default only units which are active, have pending jobs, or have failed are shown; this can be changed
           with option --all. If one or more PATTERNs are specified, only units matching one of them are shown.
.
.
.

```


service komutu

```sh
[root@rocky2 ~]# service
Usage: service < option > | --status-all | [ service_name [ command | --full-restart ] ]
```



## View Service States


```sh
[user@rocky2 ~]$ man systemctl

[user@rocky2 ~]$ systemctl status sshd.service
● sshd.service - OpenSSH server daemon
      #bu kısım memor yüklü çalışmaya hazır bir service     #1. enabled OS kapanip acildiginda devreye girecek 2. enabled service kurulur kurulmaz devreye girecek anlamindadir. 2. enabled değiştirelemez.
     Loaded: loaded (/usr/lib/systemd/system/sshd.service;  enabled; preset: enabled)
    #running yerine excited bulunuyor tek sefer calismasi icin tanımlanmıştır.
    #running active waiting bulunuyorsa bir taskın tamamlanması bekleniyordur.
     Active: active (running) since Fri 2024-03-08 19:19:14 +03; 2 days ago
       Docs: man:sshd(8)
             man:sshd_config(5)
             #process id
   Main PID: 749 (sshd)
      Tasks: 1 (limit: 10834)
     Memory: 6.3M
        CPU: 13.761s
        #CGroup --> diğer servislerden izole bir şekilde kaynak tüketimi sağlanır. Kaynak çakışması ve service izolesi sağlanır.
     CGroup: /system.slice/sshd.service
             └─749 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
#Son 10 log
Mar 08 19:19:14 rocky2.lab.example.com sshd[749]: Server listening on :: port 22.
Mar 08 19:19:14 rocky2.lab.example.com systemd[1]: Started OpenSSH server daemon.
Mar 08 19:22:25 rocky2.lab.example.com sshd[1274]: Accepted password for user from 192.168.2.1 port 60782 ssh2
Mar 08 22:27:23 rocky2.lab.example.com sshd[1584]: Accepted password for user from 192.168.2.1 port 55851 ssh2
Mar 09 07:42:44 rocky2.lab.example.com sshd[2491]: Accepted password for user from 192.168.2.1 port 57367 ssh2
Mar 09 07:42:44 rocky2.lab.example.com sshd[2491]: pam_unix(sshd:session): session opened for user user(uid=1000) by (uid=0)
Mar 09 20:52:25 rocky2.lab.example.com sshd[3814]: Accepted password for user from 192.168.2.1 port 61205 ssh2
Mar 11 00:38:39 rocky2.lab.example.com sshd[6057]: Accepted password for user from 192.168.2.1 port 53193 ssh2
Mar 11 12:40:18 rocky2.lab.example.com sshd[6941]: Accepted password for user from 192.168.2.1 port 59228 ssh2
Mar 11 12:40:18 rocky2.lab.example.com sshd[6941]: pam_unix(sshd:session): session opened for user user(uid=1000) by (uid=0)

```

Service Unit Information

|   Field    |  Description     
|--|--|
| Loaded | Whether the service unit is loaded into memory. |
| Active | Whether the service unit is running and if so, for how long.
| Docs   | Where to find more information about the service. |
| Main PID | The main process ID of the service, including the command name. |
| Status | More information about the service. |
| Process | More information about related processes. |
| CGroup | More information about related control groups. |



Service States in the Output of systemctl

| Keyword | Description |
| loaded | The unit configuration file is processed. |
| active (running) | The service is running with continuing processes. |
| active (exited) | The service successfully completed a one-time configuration. |
| active (waiting) | The service is running but waiting for an event. |
| inactive | The service is not running. |
| enabled | The service starts at boot time. |
| disabled | The service is not set to start at boot time. |
| static | The service cannot be enabled, but an enabled unit might start it automatically. |



## Verify the Status of a Service

The command returns the service unit state, which is usually active or inactive.

```sh
[root@host ~]# systemctl is-active sshd.service
active
```

The command returns whether the service unit is enabled to start at boot time, and is usually
enabled or disabled.

```sh
[root@host ~]# systemctl is-enabled sshd.service
enabled
```

The command returns active if the service is properly running, or failed if an error occurred
during startup. If the unit was stopped, it returns unknown or inactive.

```sh
[root@host ~]# systemctl is-failed sshd.service
active
```

To list all the failed units

```sh
[root@host ~]# systemctl --failed --type=service
```



# Control System Services

## Start and Stop Services

```sh
[root@host ~]# systemctl status sshd.service
● sshd.service - OpenSSH server daemon
 Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset:
 enabled)
 Active: active (running) since Wed 2022-03-23 11:58:18 EDT; 2min 56s ago
...output omitted...
```

durdurmak icin

```sh
[root@host ~]# systemctl stop sshd.service
```

baslatmak icin

```sh
[root@host ~]# systemctl start sshd
```

restart etmek icin

```sh
[root@host ~]# systemctl restart sshd.service
```

örnek olarak nginx'de worker connections sayisi güncellendi. Çalışan nginx servisinde yapılan bu config degişikliğinin hemen yansıması ve aktif connection'ları düşürmeden yapmak icin

```sh
[root@host ~]# systemctl reload sshd.service
```

The command reloads the configuration
changes if the reloading function is available. Otherwise, the command restarts the service to
implement the new configuration changes:

```sh
[root@host ~]# systemctl reload-or-restart sshd.service
```

## List Unit Dependencies

bagımlılıkları listeleme

```sh
[root@host ~]# systemctl stop cups.service
Warning: Stopping cups, but it can still be activated by:
 cups.path
 cups.socket
```



```sh
[root@host ~]# systemctl list-dependencies sshd.service
sshd.service
● ├─system.slice
● ├─sshd-keygen.target
● │ ├─sshd-keygen@ecdsa.service
● │ ├─sshd-keygen@ed25519.service
● │ └─sshd-keygen@rsa.service
● └─sysinit.target
...output omitted...
```




## Mask and Unmask Services

service kitleme. Eğer kitleme yapıldıysa root kullanıcısı olsa bile start vs bir şey yapılamaz

```sh
[root@host ~]# systemctl mask sendmail.service
Created symlink /etc/systemd/system/sendmail.service → /dev/null.
```

görüntüleme

```sh
[root@host ~]# systemctl list-unit-files --type=service
UNIT FILE STATE
...output omitted...
sendmail.service masked
...output omitted...
```

start yapılamıyor

```sh
[root@host ~]# systemctl start sendmail.service
Failed to start sendmail.service: Unit sendmail.service is masked.
```

```sh
[root@host ~]# systemctl unmask sendmail
Removed /etc/systemd/system/sendmail.service.
```


## Enable Services to Start or Stop at Boot

You can create or remove these links by using the systemctl
command with the enable or disable option.


```sh
[root@root ~]# systemctl enable sshd.service
Created symlink /etc/systemd/system/multi-user.target.wants/sshd.service → /usr/
lib/systemd/system/sshd.service.
```

This command creates a symbolic link from the service unit file, usually in the /usr/lib/
systemd/system directory, to the disk location where the systemd command looks for files, in
the /etc/systemd/system/TARGETNAME.target.wants directory. Enabling a service does
not start the service in the current session. To start the service and enable it to start automatically
during boot, you can execute both the systemctl start and systemctl enable commands,
or use the equivalent systemctl enable --now command.


```sh
[root@root ~]# systemctl enable --now sshd.service
Created symlink /etc/systemd/system/multi-user.target.wants/sshd.service → /usr/
lib/systemd/system/sshd.service.
```

disabled yapma ve kontrol etme

```sh
[root@host ~]# systemctl disable --now sshd.service
Removed /etc/systemd/system/multi-user.target.wants/sshd.service.

```

durumunu kontrol etme

```sh
[root@host ~]# systemctl is-enabled sshd.service
enabled
```

Useful Service Management Commands

|   Command |  Task |
|--|--|
| systemctl status UNIT | View detailed information about a unit's state.|
| systemctl stop UNIT | Stop a service on a running system. |
| systemctl start UNIT | Start a service on a running system. |
| systemctl restart UNIT | Restart a service on a running system. |
| systemctl reload UNIT | Reload the configuration file of a running service. |
| systemctl mask UNIT | Disable a service from being started, both manually and at boot. |
| systemctl unmask UNIT | Make a masked service available. |
| systemctl enable UNIT | Configure a service to start at boot time. Use the --now option to also start the service. |
| systemctl disable UNIT | Disable a service from starting at boot time. Use the --now option to also stop the service. |



