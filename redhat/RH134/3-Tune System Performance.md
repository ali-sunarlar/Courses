# Tune System Performance

## Adjust Tuning Profiles


Tuning profile Tune Performance

Optimizasyon yapmak için ön ayarlarda aksiyon almamızı sağlar. Sistem performansı artırılmak istenebilir. Bir uygulamanın veya bir kullanım senaryosuna göre bazı aksiyonların alınması gerekirse tune performance profilleri devreye girer.

Değiştirmemiz ve düzenlememiz gerektirdiği durumlar olabilir.

Yapının çalışmanın altyapıya göre değişiklik yapılması gerekebilir(VM veya Fiziksel sunucularda)

Genellikle fiziksel katmanda güncelleme yapılabilir. Sanal katmanda çok kullanılmaz

Statik tuning -->Sistemin veya uygulamanın performance optimize edebilmek için sabit tanımlamalar. Stabil şekilde yönetimi kolaylaştırır. Sistem gereksinimine göre değişmez(Sistem gereksinimlerine göre belirlenir.) dezavantajı sistem performans değiştiğinde uyumlu hale gelmez

Dinamik tuning --> CPU, Memory, Disk IO, network yük artıkca ve azaldıkça otomatik belirlenir. 


• disk: Monitors the disk load based on the number of IO operations for every disk device.

• net: Monitors the network load based on the number of transferred packets per network card.

• load: Monitors the CPU load for every CPU.


• disk: Sets different disk parameters, for example, the disk scheduler, the spin-down timeout, or
the advanced power management.
• net: Configures the interface speed and the Wake-on-LAN (WoL) functionality.
• cpu: Sets different CPU parameters, for example, the CPU governor or the latency
dynamic_tuning = 0 ise kapalı demektir. Bu statik bir tuning aktif olduğu anlamına gelir.

Dynamic tuning default'da disable durumdadır. /etc/tuned/tuned-main.conf dosyasindaki dynamic_tuning değeri 1 yapılır.

tune kurulumu

```sh
[root@rocky2 ~]# dnf install tuned
Last metadata expiration check: 1:44:01 ago on Sat 17 Aug 2024 10:58:27 PM +03.
Dependencies resolved.
=============================================================================================================================================================================
 Package                                         Architecture                      Version                                           Repository                         Size 
=============================================================================================================================================================================
Installing:
 tuned                                           noarch                            2.22.1-1.el9                                      baseos                            323 k 
Installing dependencies:
 dmidecode                                       x86_64                            1:3.5-3.el9                                       baseos                             95 k 
 hdparm                                          x86_64                            9.62-2.el9                                        baseos                             95 k 
 libtraceevent                                   x86_64                            1.5.3-3.el9                                       baseos                            213 k 
 polkit                                          x86_64                            0.117-11.el9                                      baseos                            145 k 
 polkit-libs                                     x86_64                            0.117-11.el9                                      baseos                            8.3 M 
 polkit-pkla-compat                              x86_64                            0.1-21.el9                                        baseos                             44 k 
 python3-linux-procfs                            noarch                            0.7.3-1.el9                                       baseos                             30 k 
 python3-perf                                    x86_64                            5.14.0-427.31.1.el9_4                             baseos                            5.1 M 
 python3-pyudev                                  noarch                            0.22.0-6.el9                                      baseos                             76 k 
 virt-what                                       x86_64                            1.25-5.el9                                        baseos                             33 k 

Transaction Summary
=============================================================================================================================================================================
Install  11 Packages

Total download size: 14 M
Installed size: 32 M
Is this ok [y/N]: Y
Downloading Packages:
(1/11): python3-linux-procfs-0.7.3-1.el9.noarch.rpm                                                                                           77 kB/s |  30 kB     00:00    
(2/11): polkit-pkla-compat-0.1-21.el9.x86_64.rpm                                                                                              89 kB/s |  44 kB     00:00     
(3/11): dmidecode-3.5-3.el9.x86_64.rpm                                                                                                       191 kB/s |  95 kB     00:00    
(4/11): python3-pyudev-0.22.0-6.el9.noarch.rpm                                                                                               656 kB/s |  76 kB     00:00     
(5/11): virt-what-1.25-5.el9.x86_64.rpm                                                                                                      391 kB/s |  33 kB     00:00     
(6/11): hdparm-9.62-2.el9.x86_64.rpm                                                                                                         908 kB/s |  95 kB     00:00     
(7/11): libtraceevent-1.5.3-3.el9.x86_64.rpm                                                                                                 426 kB/s | 213 kB     00:00     
(8/11): tuned-2.22.1-1.el9.noarch.rpm                                                                                                        423 kB/s | 323 kB     00:00     
(9/11): polkit-0.117-11.el9.x86_64.rpm                                                                                                       386 kB/s | 145 kB     00:00     
(10/11): python3-perf-5.14.0-427.31.1.el9_4.x86_64.rpm                                                                                       2.5 MB/s | 5.1 MB     00:02    
(11/11): polkit-libs-0.117-11.el9.x86_64.rpm                                                                                                 1.2 MB/s | 8.3 MB     00:06     
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                        1.7 MB/s |  14 MB     00:08     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                     1/1 
  Installing       : polkit-libs-0.117-11.el9.x86_64                                                                                                                    1/11 
  Installing       : dmidecode-1:3.5-3.el9.x86_64                                                                                                                       2/11 
  Installing       : virt-what-1.25-5.el9.x86_64                                                                                                                        3/11 
  Running scriptlet: polkit-0.117-11.el9.x86_64                                                                                                                         4/11 
  Installing       : polkit-0.117-11.el9.x86_64                                                                                                                         4/11 
  Running scriptlet: polkit-0.117-11.el9.x86_64                                                                                                                         4/11 
  Installing       : polkit-pkla-compat-0.1-21.el9.x86_64                                                                                                               5/11 
  Installing       : libtraceevent-1.5.3-3.el9.x86_64                                                                                                                   6/11 
  Installing       : python3-perf-5.14.0-427.31.1.el9_4.x86_64                                                                                                          7/11 
  Installing       : hdparm-9.62-2.el9.x86_64                                                                                                                           8/11 
  Installing       : python3-pyudev-0.22.0-6.el9.noarch                                                                                                                 9/11 
  Installing       : python3-linux-procfs-0.7.3-1.el9.noarch                                                                                                           10/11 
  Installing       : tuned-2.22.1-1.el9.noarch                                                                                                                         11/11 
  Running scriptlet: tuned-2.22.1-1.el9.noarch                                                                                                                         11/11 
Created symlink /etc/systemd/system/multi-user.target.wants/tuned.service → /usr/lib/systemd/system/tuned.service.

  Verifying        : python3-linux-procfs-0.7.3-1.el9.noarch                                                                                                            1/11 
  Verifying        : dmidecode-1:3.5-3.el9.x86_64                                                                                                                       2/11 
  Verifying        : polkit-pkla-compat-0.1-21.el9.x86_64                                                                                                               3/11 
  Verifying        : python3-pyudev-0.22.0-6.el9.noarch                                                                                                                 4/11 
  Verifying        : virt-what-1.25-5.el9.x86_64                                                                                                                        5/11 
  Verifying        : hdparm-9.62-2.el9.x86_64                                                                                                                           6/11 
  Verifying        : tuned-2.22.1-1.el9.noarch                                                                                                                          7/11 
  Verifying        : libtraceevent-1.5.3-3.el9.x86_64                                                                                                                   8/11 
  Verifying        : polkit-libs-0.117-11.el9.x86_64                                                                                                                    9/11 
  Verifying        : polkit-0.117-11.el9.x86_64                                                                                                                        10/11 
  Verifying        : python3-perf-5.14.0-427.31.1.el9_4.x86_64                                                                                                         11/11 

Installed:
  dmidecode-1:3.5-3.el9.x86_64           hdparm-9.62-2.el9.x86_64                 libtraceevent-1.5.3-3.el9.x86_64            polkit-0.117-11.el9.x86_64
  polkit-libs-0.117-11.el9.x86_64        polkit-pkla-compat-0.1-21.el9.x86_64     python3-linux-procfs-0.7.3-1.el9.noarch     python3-perf-5.14.0-427.31.1.el9_4.x86_64      
  python3-pyudev-0.22.0-6.el9.noarch     tuned-2.22.1-1.el9.noarch                virt-what-1.25-5.el9.x86_64

Complete!
```


tune yapılandırma dosyasi
```sh
[root@rocky2 user]# cat /etc/tuned/tuned-main.conf
cat: /etc/tuned/tuned-main.conf: No such file or directory
[root@rocky2 user]# yum -y install tuned
#kurulması gerekmektedir.
[root@rocky2 user]# cat /etc/tuned/tuned-main.conf
# Global tuned configuration file.

# Whether to use daemon. Without daemon it just applies tuning. It is
# not recommended, because many functions don't work without daemon,
# e.g. there will be no D-Bus, no rollback of settings, no hotplug,
# no dynamic tuning, ...
daemon = 1

# Dynamicaly tune devices, if disabled only static tuning will be used.
dynamic_tuning = 0

# How long to sleep before checking for events (in seconds)
# higher number means lower overhead but longer response time.
sleep_interval = 1

# Update interval for dynamic tunings (in seconds).
# It must be multiply of the sleep_interval.
update_interval = 10
.
.
.
[root@rocky2 ~]# systemctl is-active tuned
inactive



[user@rocky2 ~]$ systemctl enable --now tuned
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-unit-files ====
Authentication is required to manage system service or unit files.
Authenticating as: user
Password:
==== AUTHENTICATION COMPLETE ====
==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ====
Authentication is required to reload the systemd state.
Authenticating as: user
Password:
==== AUTHENTICATION COMPLETE ====
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'tuned.service'.
Authenticating as: user
Password:
==== AUTHENTICATION COMPLETE ====

[root@rocky2 user]# systemctl is-active tuned
active

```




## The tuned Utility

performance boosting, powersaving profilleri 

The tuned application provides profiles in the following categories:

• Power-saving profiles

• Performance-boosting profiles


The performance-boosting profiles include profiles that focus on the following aspects:

• Low latency for storage and network

• High throughput for storage and network

• Virtual machine performance

• Virtualization host performance


 tuning profiles distributed with Red Hat Enterprise Linux 9

| Tuned Profile | Purpose   |
|--|--|
| balanced | Ideal for systems that require a compromise between power saving and performance. |
| powersave | Tunes the system for maximum power saving. |
| throughput-performance | Tunes the system for maximum throughput. |
| accelerator-performance | Tunes the same as throughput-performance, and also reduces the latency to less than 100 μs. |
| latency-performance | Ideal for server systems that require low latency at the expense of power consumption. |
| network-throughput | Derived from the throughput-performance profile. Additional network tuning parameters are applied for maximum network throughput. |
| network-latency | Derived from the latency-performance profile. Enables additional network tuning parameters to provide low network latency. |
| desktop | Derived from the balanced profile. Provides faster response of interactive applications. |
| hpc-compute | Derived from the latency-performance profile. Ideal for high-performance computing. |
| virtual-guest | Tunes the system for maximum performance if it runs on a virtual machine. |
| virtual-host | Tunes the system for maximum performance if it acts as a host for virtual machines. |
| intel-sst  | Optimized for systems with Intel Speed Select Technology configurations. Use it as an overlay on other profiles. |
| optimize-serial-console | Increases responsiveness of the serial console. Use it as an overlay on other profiles. |


tune performance default profilleri /usr/lib/tuned dizini altında yer alır. Bu profiller düzenlenebilmektedir.

```sh
[user@rocky2 ~]$ ls -l /usr/lib/tuned
total 16
drwxr-xr-x. 2 root root    24 Mar 17 18:04 accelerator-performance
drwxr-xr-x. 2 root root    24 Mar 17 18:04 aws
drwxr-xr-x. 2 root root    24 Mar 17 18:04 balanced
drwxr-xr-x. 2 root root    24 Mar 17 18:04 desktop
-rw-r--r--. 1 root root 15381 Aug 29  2023 functions
drwxr-xr-x. 2 root root    24 Mar 17 18:04 hpc-compute
drwxr-xr-x. 2 root root    24 Mar 17 18:04 intel-sst
drwxr-xr-x. 2 root root    24 Mar 17 18:04 latency-performance
drwxr-xr-x. 2 root root    24 Mar 17 18:04 network-latency
drwxr-xr-x. 2 root root    24 Mar 17 18:04 network-throughput
drwxr-xr-x. 2 root root    24 Mar 17 18:04 optimize-serial-console
drwxr-xr-x. 2 root root    41 Mar 17 18:04 powersave
drwxr-xr-x. 2 root root    27 Mar 17 18:04 recommend.d
drwxr-xr-x. 2 root root    24 Mar 17 18:04 throughput-performance
drwxr-xr-x. 2 root root    24 Mar 17 18:04 virtual-guest
drwxr-xr-x. 2 root root    24 Mar 17 18:04 virtual-host
```

örnek powersave profil config'i(düşük güç tüketimi ile alakalı profil)

```sh
[user@rocky2 ~]$ cat /usr/lib/tuned//powersave/
script.sh   tuned.conf
[user@rocky2 ~]$ cat /usr/lib/tuned//powersave/tuned.conf
#
# tuned configuration
#

[main]
summary=Optimize for low power consumption

[cpu]
#cpu çalışma hızı belirtilir. Çalışma modu
governor=ondemand|powersave
#enerji verimliliği
energy_perf_bias=powersave|power

#asus tarafında super hybrid engine denilen bir teknoloji 
[eeepc_she]

#sanal bellek, bellek yönetimi
[vm]

#ses zaman aşımı
[audio]
timeout=10

#video ile ilgili zaman aşımı
[video]
radeon_powersave=dpm-battery, auto

[disk]
# Comma separated list of devices, all devices if commented out.
# devices=sda

[net]
# Comma separated list of devices, all devices if commented out.
# devices=eth0

[scsi_host]
alpm=min_power

[sysctl]
vm.laptop_mode=5
vm.dirty_writeback_centisecs=1500
kernel.nmi_watchdog=0

[script]
script=${i:PROFILE_DIR}/script.sh
```

network-latency profil çıktıları

```sh
[user@rocky2 ~]$ cat /usr/lib/tuned/network-latency/tuned.conf
#
# tuned configuration
#

[main]
summary=Optimize for deterministic performance at the cost of increased power consumption, focused on low latency network performance
include=latency-performance

[vm]
transparent_hugepages=never

#aksiyonlar burada alınıyor
[sysctl]
#ağ işlemlerlerinde bekleme süresi
net.core.busy_read=50
net.core.busy_poll=50
#tcp portlarının açılma süresi
net.ipv4.tcp_fastopen=3
#uniform memory access- network tarafında dengelemek için kullanılır.
kernel.numa_balancing=0
#ne kadar süreleyle bir işlem yapılırken bekleme süresi belirtilir. Network tarafında bir işlem yapılırken beklenen süre işlem yapılmazsa timeout alınır.
kernel.hung_task_timeout_secs = 600
#hata izlemeyi devreye almak veya devre dışı bırakmak
kernel.nmi_watchdog = 0
#bellek kullanım istatistikleri
vm.stat_interval = 10
#timer tanımlanmışsa bekleme süresi
kernel.timer_migration = 0

[bootloader]
#ağ gecikcesini azaltmak için farkli yontemler uygulanabilir.
cmdline_network_latency=skew_tick=1 tsc=reliable rcupdate.rcu_normal_after_boot=1

[rtentsk]

```

throughput-performance profil config dosyası. (CPU,Memory ve disk IO en yüksek seviyede kullanılan profildir )

```sh
[user@rocky2 ~]$ cat /usr/lib/tuned/throughput-performance/tuned.conf
#
# tuned configuration
#

[main]
summary=Broadly applicable tuning that provides excellent performance across a variety of common server workloads

[variables]
# CPU değişkenleri tanımlanmış
thunderx_cpuinfo_regex=CPU part\s+:\s+(0x0?516)|(0x0?af)|(0x0?a[0-3])|(0x0?b8)\b
amd_cpuinfo_regex=model name\s+:.*\bAMD\b

[cpu]
governor=performance
energy_perf_bias=performance
#min performan yüzdesi
min_perf_pct=100

# Marvell ThunderX
[vm.thunderx]
type=vm
uname_regex=aarch64
cpuinfo_regex=${thunderx_cpuinfo_regex}
transparent_hugepages=never

[disk]
#kaç sektorlük iş yapılacağı belirtilir.
# The default unit for readahead is KiB.  This can be adjusted to sectors
# by specifying the relevant suffix, eg. (readahead => 8192 s). There must
# be at least one space between the number and suffix (if suffix is specified).
readahead=>4096

[sysctl]
# If a workload mostly uses anonymous memory and it hits this limit, the entire
# working set is buffered for I/O, and any more write buffering would require
# swapping, so it's time to throttle writes until I/O can catch up.  Workloads
# that mostly use file mappings may be able to use even higher values.
#
# The generator of dirty data starts writeback at this percentage (system default
# is 20%)
vm.dirty_ratio = 40

# Start background writeback (via writeback threads) at this percentage (system
# default is 10%)
vm.dirty_background_ratio = 10

# PID allocation wrap value.  When the kernel's next PID value
# reaches this value, it wraps back to a minimum PID value.
# PIDs of value pid_max or larger are not allocated.
#
# A suggested value for pid_max is 1024 * <# of cpu cores/threads in system>
# e.g., a box with 32 cpus, the default of 32768 is reasonable, for 64 cpus,
# 65536, for 4096 cpus, 4194304 (which is the upper limit possible).
#kernel.pid_max = 65536

# The swappiness parameter controls the tendency of the kernel to move
# processes out of physical memory and onto the swap disk.
# 0 tells the kernel to avoid swapping processes out of physical memory
# for as long as possible
# 100 tells the kernel to aggressively swap processes out of physical memory
# and move them to swap cache
vm.swappiness=10

# The default kernel value 128 was over twenty years old default,
# kernel-5.4 increased it to 4096, thus do not have it lower than 2048
# on older kernels
net.core.somaxconn=>2048

# Marvell ThunderX
[sysctl.thunderx]
type=sysctl
uname_regex=aarch64
cpuinfo_regex=${thunderx_cpuinfo_regex}
kernel.numa_balancing=0

```



```sh
[root@rocky2 user]# sysctl vm.dirty_background_ratio
vm.dirty_background_ratio = 10
[root@rocky2 user]# sysctl vm.dirty_ratio
vm.dirty_ratio = 30

[root@rocky2 user]# cat /usr/lib/tuned/virtual-guest/tuned.conf
#
# tuned configuration
#

[main]
summary=Optimize for running inside a virtual guest
include=throughput-performance

[sysctl]
# If a workload mostly uses anonymous memory and it hits this limit, the entire
# working set is buffered for I/O, and any more write buffering would require
# swapping, so it's time to throttle writes until I/O can catch up.  Workloads
# that mostly use file mappings may be able to use even higher values.
#
# The generator of dirty data starts writeback at this percentage (system default
# is 20%)
vm.dirty_ratio = 30

# Filesystem I/O is usually much more efficient than swapping, so try to keep
# swapping low.  It's usually safe to go even lower than this on systems with
# server-grade storage.
vm.swappiness = 30

```



## Manage Profiles from the Command Line


```sh
#service enable yapılmamışsa alınan çıktı
[user@rocky2 ~]$ tuned-adm active
Cannot talk to TuneD daemon via DBus. Is TuneD daemon running?
No current active profile.

#service enable yapıldıktan sonra default atanan profile göre değişiklik gösterir
[user@rocky2 ~]$ tuned-adm active
Current active profile: virtual-guest

[user@rocky2 ~]$ tuned-adm active
Current active profile: powersave
```


tuned-adm list

```sh
[user@rocky2 ~]$ tuned-adm list
Available profiles:
- accelerator-performance     - Throughput performance based tuning with disabled higher latency STOP states
- aws                         - Optimize for aws ec2 instances
- balanced                    - General non-specialized tuned profile
- desktop                     - Optimize for the desktop use-case
- hpc-compute                 - Optimize for HPC compute workloads
- intel-sst                   - Configure for Intel Speed Select Base Frequency
- latency-performance         - Optimize for deterministic performance at the cost of increased power consumption
- network-latency             - Optimize for deterministic performance at the cost of increased power consumption, focused on low latency network performance
- network-throughput          - Optimize for streaming network throughput, generally only necessary on older CPUs or 40G+ networks
- optimize-serial-console     - Optimize for serial console use.
- powersave                   - Optimize for low power consumption
- throughput-performance      - Broadly applicable tuning that provides excellent performance across a variety of common server workloads
- virtual-guest               - Optimize for running inside a virtual guest
- virtual-host                - Optimize for running KVM guests
Current active profile: virtual-guest
```



```sh
#değiştirmek için 
[root@rocky2 user]# tuned-adm profile powersave
[root@rocky2 user]# tuned-adm active
Current active profile: powersave
#recommend yüzdelik kullanıma göre otomatik profil atar.
[root@rocky2 user]# tuned-adm recommend
virtual-guest
#kapatmak için
[root@rocky2 user]# tuned-adm off
[root@rocky2 user]# tuned-adm active
No current active profile.
#geri açmak için tekrar profile seçilebilir.
[root@rocky2 user]# tuned-adm profile virtual-guest
[root@rocky2 user]# tuned-adm active
Current active profile: virtual-guest

#profile config'lerin sysctl ile görüntülenmesi
[root@rocky2 user]# tuned-adm profile throughput-performance
[root@rocky2 user]# sysctl vm.dirty_ratio
vm.dirty_ratio = 40
[root@rocky2 user]# sysctl vm.dirty_background_ratio
vm.dirty_background_ratio = 10
[root@rocky2 user]# tuned-adm profile virtual-guest
[root@rocky2 user]# sysctl vm.dirty_background_ratio
vm.dirty_background_ratio = 10
[root@rocky2 user]# sysctl vm.dirty_ratio
vm.dirty_ratio = 30
[root@rocky2 user]# sysctl vm.swappiness
vm.swappiness = 30

```


# Influence Process Scheduling

## Linux Process Scheduling

CPU önceliklendirme


```sh
#PR --> prioty (0-100 arasındadır)
#NC --> nice value(CPU önceliklendirme yapabilmek için kullanılan değer -20 ve +19 arasındadır. )
top - 21:24:35 up  3:25,  1 user,  load average: 0.00, 0.02, 0.07
Tasks: 156 total,   1 running, 155 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.2 us,  0.3 sy,  0.0 ni, 98.7 id,  0.0 wa,  0.7 hi,  0.2 si,  0.0 st
MiB Mem :   1732.1 total,   1054.9 free,    436.0 used,    396.0 buff/cache
MiB Swap:   3060.0 total,   3060.0 free,      0.0 used.   1296.2avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   3134 root      20   0   10592   4128   3488 R   0.7   0.2   0:00.10 top
   2189 root      20   0       0      0      0 I   0.3   0.0   0:34.78 kworker/1:0-pm
   2296 root      20   0       0      0      0 I   0.3   0.0   0:15.91 kworker/0:1-events
   2493 root      20   0  330600  27272  13524 S   0.3   1.5   0:02.79 tuned
      1 root      20   0  107800  17504  10816 S   0.0   1.0   0:03.13 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.04 kthreadd
      3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par_gp


[root@rocky2 user]#  ps aux --sort=pcpu
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           2  0.0  0.0      0     0 ?        S    22:31   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        I<   22:31   0:00 [rcu_gp]
root           4  0.0  0.0      0     0 ?        I<   22:31   0:00 [rcu_par_gp]
root           5  0.0  0.0      0     0 ?        I<   22:31   0:00 [slub_flushwq]
root           6  0.0  0.0      0     0 ?        I<   22:31   0:00 [netns]
root           8  0.0  0.0      0     0 ?        I<   22:31   0:00 [kworker/0:0H-events_highpri]
root           9  0.0  0.0      0     0 ?        I    22:31   0:00 [kworker/u256:0-events_unbound]
root          10  0.0  0.0      0     0 ?        I<   22:31   0:00 [mm_percpu_wq]
root          12  0.0  0.0      0     0 ?        I    22:31   0:00 [rcu_tasks_kthre]



[root@rocky2 user]# ps axo pid,comm,nice,cls --sort=-nice
    PID COMMAND          NI CLS
     39 khugepaged       19  TS
     38 ksmd              5  TS
      1 systemd           0  TS
      2 kthreadd          0  TS
     12 rcu_tasks_kthre   0  TS
     13 rcu_tasks_rude_   0  TS
     14 rcu_tasks_trace   0  TS
     15 ksoftirqd/0       0  TS
.
.
.
    556 xfs-cil/dm-0    -20  TS
    663 xfs-buf/nvme0n1 -20  TS
    665 xfs-conv/nvme0n -20  TS
    667 xfs-reclaim/nvm -20  TS
    669 xfs-blockgc/nvm -20  TS
    670 xfs-inodegc/nvm -20  TS
    671 xfs-log/nvme0n1 -20  TS
    672 xfs-cil/nvme0n1 -20  TS
    718 mpt_poll_0      -20  TS
    719 mpt/0           -20  TS
    722 scsi_tmf_2      -20  TS
    735 ttm             -20  TS
    757 kworker/u257:2- -20  TS
   1369 tls-strp        -20  TS



#bir process başlatıp nice ve prioity değerlerini kontrol etme
[root@rocky2 user]# sleep 60 &
[1] 3137
[root@rocky2 user]# ps -o pid,comm,nice 3137
    PID COMMAND          NI
   3137 sleep             0
[root@rocky2 user]# nice sleep 60 &
[2] 3139
[1]   Done                    sleep 60
[root@rocky2 user]# ps -o pid,comm,nice 3139
    PID COMMAND          NI
   3139 sleep            10

#4 process başlatıp jobs altında görüntüleme
[root@rocky2 user]# for i in {1..4}; do sha1sum /dev/zero & done
[3] 3152
[4] 3153
[5] 3154
[6] 3155
[2]   Done                    nice sleep 60
[root@rocky2 user]# jobs
[3]   Running                 sha1sum /dev/zero &
[4]   Running                 sha1sum /dev/zero &
[5]-  Running                 sha1sum /dev/zero &
[6]+  Running                 sha1sum /dev/zero &

#oluşturulan process'ler eşit derecede CPU kullanımı yapıyorlar
[root@rocky2 user]# ps u $(pgrep sha1sum)
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root        3152 46.0  0.1   9992  2212 pts/0    R    21:34   0:48 sha1sum /dev/zero
root        3153 46.0  0.1   9992  2212 pts/0    R    21:34   0:48 sha1sum /dev/zero
root        3154 46.4  0.1   9992  2212 pts/0    R    21:34   0:49 sha1sum /dev/zero
root        3155 46.4  0.1   9992  2212 pts/0    R    21:34   0:49 sha1sum /dev/zero

#sonradan nice değeri ataması yapılan process oluşturuluyor
[root@rocky2 user]# nice -n 10 sha1sum /dev/zero &
[7] 3162
[root@rocky2 user]# ps u $(pgrep sha1sum)
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root        3152 46.0  0.1   9992  2212 pts/0    R    21:34   3:47 sha1sum /dev/zero
root        3153 46.0  0.1   9992  2212 pts/0    R    21:34   3:47 sha1sum /dev/zero
root        3154 46.2  0.1   9992  2212 pts/0    R    21:34   3:48 sha1sum /dev/zero
root        3155 46.1  0.1   9992  2212 pts/0    R    21:34   3:48 sha1sum /dev/zero
root        3162  5.6  0.1   9992  2212 pts/0    RN   21:42   0:00 sha1sum /dev/zero
[root@rocky2 user]# jobs
[3]   Running                 sha1sum /dev/zero &
[4]   Running                 sha1sum /dev/zero &
[5]   Running                 sha1sum /dev/zero &
[6]-  Running                 sha1sum /dev/zero &
[7]+  Running                 nice -n 10 sha1sum /dev/zero &
[root@rocky2 user]# ps -o pid,pcpu,nice,comm $(pgrep sha1sum)
    PID %CPU  NI COMMAND
   3152 45.3   0 sha1sum
   3153 45.3   0 sha1sum
   3154 45.7   0 sha1sum
   3155 45.4   0 sha1sum
   3162  4.7  10 sha1sum
#farklı bir nice ataması
[root@rocky2 user]# renice -n 5 3155
3155 (process ID) old priority 0, new priority 5
[root@rocky2 user]# ps -o pid,pcpu,nice,comm $(pgrep sha1sum)
    PID %CPU  NI COMMAND
   3152 45.5   0 sha1sum
   3153 45.4   0 sha1sum
   3154 45.6   0 sha1sum
   3155 45.2   5 sha1sum
   3162  4.7  10 sha1sum

#ilgili process en öncelikli olarak belirlendi -20 yaparak
[root@rocky2 user]# renice -n -20 3162
3162 (process ID) old priority 10, new priority -20
[root@rocky2 user]# ps -o pid,pcpu,nice,comm $(pgrep sha1sum)
    PID %CPU  NI COMMAND
   3152 46.3   0 sha1sum
   3153 46.2   0 sha1sum
   3154 46.4   0 sha1sum
   3155 41.8   5 sha1sum
   3162  5.5 -20 sha1sum
[root@rocky2 user]# ps -o pid,pcpu,nice,comm $(pgrep sha1sum)
    PID %CPU  NI COMMAND
   3152 46.3   0 sha1sum
   3153 46.1   0 sha1sum
   3154 46.4   0 sha1sum
   3155 41.7   5 sha1sum
   3162  5.8 -20 sha1sum
[root@rocky2 user]# ps -o pid,pcpu,nice,comm $(pgrep sha1sum)
    PID %CPU  NI COMMAND
   3152 46.3   0 sha1sum
   3153 46.1   0 sha1sum
   3154 46.4   0 sha1sum
   3155 41.7   5 sha1sum
   3162  6.0 -20 sha1sum
[root@rocky2 user]# renice -n 0 3155
3155 (process ID) old priority 5, new priority 0
[root@rocky2 user]# ps -o pid,pcpu,nice,comm $(pgrep sha1sum)
    PID %CPU  NI COMMAND
   3152 43.7   0 sha1sum
   3153 43.5   0 sha1sum
   3154 43.7   0 sha1sum
   3155 37.2   0 sha1sum
   3162 24.4 -20 sha1sum
[root@rocky2 user]# ps -o pid,pcpu,nice,comm $(pgrep sha1sum)
    PID %CPU  NI COMMAND
   3152 43.6   0 sha1sum
   3153 43.5   0 sha1sum
   3154 43.7   0 sha1sum
   3155 37.1   0 sha1sum
   3162 24.6 -20 sha1sum

```


Lab 73-76