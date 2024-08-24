# Manage Basic Storage

## Add Partitions, File Systems, and Persistent Mounts

Partition Disks

MBR Partition Scheme

Master boot recort, 32 bit partition size ile ilerleniyor. Maksimum 2 TB. 15 farkli partitions


GPT Partition Scheme

uefi unified Extensible Firmware Interface

128 farkli partitions, 64 bit size ile ilerlenir.

Partition yönetim editorleri

fdisk (is a historical favorite and has supported GPT partitions for years.)

parted (and the libparted library have been the RHEL standard for years.)

gdisk ( and other fdisk variants were initially created to support GPT.)

gnome-disk(is the default GNOME graphical tool, replacing gparted upstream. ) 


```sh
[root@rocky2 ~]# lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0                 11:0    1 1024M  0 rom
nvme0n1            259:0    0   20G  0 disk
├─nvme0n1p1        259:1    0    1G  0 part /boot
└─nvme0n1p2        259:2    0   19G  0 part
  ├─rootvg-LV_root 253:0    0   16G  0 lvm  /
  └─rootvg-LV_swap 253:1    0    3G  0 lvm  [SWAP]
nvme0n2            259:3    0    5G  0 disk
nvme0n3            259:4    0    5G  0 disk
nvme0n4            259:5    0    5G  0 disk
nvme0n5            259:6    0    5G  0 disk

#msdos --> mbr'dır

[root@rocky2 ~]# parted /dev/nvme0n1 print
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n1: 21.5GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  1075MB  1074MB  primary  xfs          boot
 2      1075MB  21.5GB  20.4GB  primary               lvm

[root@rocky2 ~]# parted /dev/nvme0n2 print
Error: /dev/nvme0n2: unrecognised disk label
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n2: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: unknown
Disk Flags:

[root@rocky2 ~]# parted /dev/nvme0n2 mklabel gpt
Information: You may need to update /etc/fstab.

[root@rocky2 ~]# parted /dev/nvme0n2
GNU Parted 3.5
Using /dev/nvme0n2
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mkpart
Partition name?  []? primary
File system type?  [ext2]? xfs
Start? 0%
End? 100%
(parted) quit
Information: You may need to update /etc/fstab.

[root@rocky2 ~]# udevadm settle

[root@rocky2 ~]# parted /dev/nvme0n2
GNU Parted 3.5
Using /dev/nvme0n2
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) print
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n2: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  5368MB  5367MB               primary

[root@rocky2 ~]# lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0                 11:0    1 1024M  0 rom
nvme0n1            259:0    0   20G  0 disk
├─nvme0n1p1        259:1    0    1G  0 part /boot
└─nvme0n1p2        259:2    0   19G  0 part
  ├─rootvg-LV_root 253:0    0   16G  0 lvm  /
  └─rootvg-LV_swap 253:1    0    3G  0 lvm  [SWAP]
nvme0n2            259:3    0    5G  0 disk
└─nvme0n2p1        259:7    0    5G  0 part
nvme0n3            259:4    0    5G  0 disk
nvme0n4            259:5    0    5G  0 disk
nvme0n5            259:6    0    5G  0 disk

#2. disk
[root@rocky2 ~]# parted /dev/nvme0n3
GNU Parted 3.5
Using /dev/nvme0n3
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel msdos
(parted) print
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n3: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start  End  Size  Type  File system  Flags

(parted) mkpart
Partition type?  primary/extended? xfs
parted: invalid token: xfs
Partition type?  primary/extended? primary
File system type?  [ext2]? xfs
Start? 0%
End? 50%
(parted) print
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n3: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  2684MB  2683MB  primary  xfs

(parted) quit
Information: You may need to update /etc/fstab.

[root@rocky2 ~]# lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0                 11:0    1 1024M  0 rom
nvme0n1            259:0    0   20G  0 disk
├─nvme0n1p1        259:1    0    1G  0 part /boot
└─nvme0n1p2        259:2    0   19G  0 part
  ├─rootvg-LV_root 253:0    0   16G  0 lvm  /
  └─rootvg-LV_swap 253:1    0    3G  0 lvm  [SWAP]
nvme0n2            259:3    0    5G  0 disk
└─nvme0n2p1        259:7    0    5G  0 part
nvme0n3            259:4    0    5G  0 disk
└─nvme0n3p1        259:9    0  2.5G  0 part
nvme0n4            259:5    0    5G  0 disk
nvme0n5            259:6    0    5G  0 disk
[root@rocky2 ~]# parted /dev/nvme0n4
GNU Parted 3.5
Using /dev/nvme0n4
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel gpt
(parted) mkpart
Partition name?  []? userdata
File system type?  [ext2]? xfs
Start? print
Error: Invalid number.
(parted) mkpart
Partition name?  []? userdata
File system type?  [ext2]? xfs
Start? 0%
End? 50%
(parted) print
Model: VMware Virtual NVMe Disk (nvme)
Disk /dev/nvme0n4: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name      Flags
 1      1049kB  2684MB  2683MB  xfs          userdata

(parted) quit
Information: You may need to update /etc/fstab.

#işlerin ardından udevadm settle çalıştırılması gerekir-avantaj sağlar. Dev directory'i tarar eklemiş olduğunuz disklerin çıktısını gösterir.
[root@rocky2 ~]# udevadm settle

#işlemlerin tek satırda yapılması
[root@rocky2 ~]# parted /dev/nvme0n5 mklabel gpt
Information: You may need to update /etc/fstab.

[root@rocky2 ~]# parted /dev/nvme0n5 mkpart primary xfs 0% 50%
Information: You may need to update /etc/fstab.

[root@rocky2 ~]# udevadm settle
[root@rocky2 ~]# lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0                 11:0    1 1024M  0 rom
nvme0n1            259:0    0   20G  0 disk
├─nvme0n1p1        259:1    0    1G  0 part /boot
└─nvme0n1p2        259:2    0   19G  0 part
  ├─rootvg-LV_root 253:0    0   16G  0 lvm  /
  └─rootvg-LV_swap 253:1    0    3G  0 lvm  [SWAP]
nvme0n2            259:3    0    5G  0 disk
└─nvme0n2p1        259:7    0    5G  0 part
nvme0n3            259:4    0    5G  0 disk
└─nvme0n3p1        259:9    0  2.5G  0 part
nvme0n4            259:5    0    5G  0 disk
└─nvme0n4p1        259:10   0  2.5G  0 part
nvme0n5            259:6    0    5G  0 disk
└─nvme0n5p1        259:8    0  2.5G  0 part
```

## Create File Systems

```sh
[root@rocky2 ~]# mkfs.xfs /dev/nvme0n2p1
meta-data=/dev/nvme0n2p1         isize=512    agcount=4, agsize=327552 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=1310208, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

[root@rocky2 ~]# mkfs.ext4 /dev/nvme0n3p1
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 655104 4k blocks and 163840 inodes
Filesystem UUID: d8f0bdfc-8ca7-411b-a337-f3dc0a80db5d
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done


```

## Mount File Systems

Mount edilmesi

```sh
#formatlanması gerekmektedir.
[root@rocky2 ~]# mount /dev/nvme0n2p1 /mnt/datadisk1
mount: /mnt/datadisk1: wrong fs type, bad option, bad superblock on /dev/nvme0n2p1, missing codepage or helper program, or other error.

[root@rocky2 ~]# mkfs.xfs /dev/nvme0n2p1
meta-data=/dev/nvme0n2p1         isize=512    agcount=4, agsize=327552 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=1310208, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@rocky2 ~]# mount /dev/nvme0n2p1 /mnt/datadisk1


[root@rocky2 ~]# mkfs.ext4 /dev/nvme0n3p1
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 655104 4k blocks and 163840 inodes
Filesystem UUID: d8f0bdfc-8ca7-411b-a337-f3dc0a80db5d
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

[root@rocky2 ~]# mkdir /mnt/datadisk2
[root@rocky2 ~]# mount /dev/nvme0n3p1 /mnt/datadisk2

[root@rocky2 ~]# df -h
Filesystem                  Size  Used Avail Use% Mounted on
devtmpfs                    4.0M     0  4.0M   0% /dev
tmpfs                       867M   84K  866M   1% /dev/shm
tmpfs                       347M  6.8M  340M   2% /run
/dev/mapper/rootvg-LV_root   16G  1.9G   15G  12% /
/dev/nvme0n1p1              960M  360M  601M  38% /boot
tmpfs                       174M     0  174M   0% /run/user/1000
/dev/nvme0n2p1              5.0G   68M  4.9G   2% /mnt/datadisk1
/dev/nvme0n3p1              2.4G   24K  2.3G   1% /mnt/datadisk2
[root@rocky2 ~]# lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0                 11:0    1 1024M  0 rom
nvme0n1            259:0    0   20G  0 disk
├─nvme0n1p1        259:1    0    1G  0 part /boot
└─nvme0n1p2        259:2    0   19G  0 part
  ├─rootvg-LV_root 253:0    0   16G  0 lvm  /
  └─rootvg-LV_swap 253:1    0    3G  0 lvm  [SWAP]
nvme0n2            259:3    0    5G  0 disk
└─nvme0n2p1        259:7    0    5G  0 part /mnt/datadisk1
nvme0n3            259:4    0    5G  0 disk
└─nvme0n3p1        259:9    0  2.5G  0 part /mnt/datadisk2
nvme0n4            259:5    0    5G  0 disk
└─nvme0n4p1        259:10   0  2.5G  0 part
nvme0n5            259:6    0    5G  0 disk
└─nvme0n5p1        259:8    0  2.5G  0 part


[root@rocky2 ~]# mount | grep nvme0n1p1
/dev/nvme0n1p1 on /boot type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)


```

### Persistently Mount File Systems

```sh
#bu işlemler kalıcı hale getirmek için fstab altında (OS açılıp kapandığında bu işlemler kalkar - mount edilmesi )




[root@rocky2 ~]# lsblk -fs
NAME     FSTYPE FSVER LABEL UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sr0
rootvg-LV_root
│        xfs                d230417f-721c-44dc-8830-cea4576fa936     14.1G    12% /
└─nvme0n1p2
         LVM2_m LVM2        iILB9i-JnGo-0wje-VUv8-z1R7-jiDs-Wetitm
  └─nvme0n1

rootvg-LV_swap
│        swap   1           6bee958c-f72f-408c-91d7-1fa11ec89867                  [SWAP]
└─nvme0n1p2
         LVM2_m LVM2        iILB9i-JnGo-0wje-VUv8-z1R7-jiDs-Wetitm
  └─nvme0n1

nvme0n1p1
│        xfs                92e2631a-8a4e-4290-b086-f358e1c16a08    600.5M    37% /boot
└─nvme0n1

nvme0n2p1
│        xfs                93dd64e0-8e6e-4346-8b6a-16e04484c814      4.9G     1% /mnt/datadisk1
└─nvme0n2

nvme0n5p1
│
└─nvme0n5

nvme0n3p1
│        ext4   1.0         d8f0bdfc-8ca7-411b-a337-f3dc0a80db5d      2.2G     0% /mnt/datadisk2
└─nvme0n3

nvme0n4p1
│
└─nvme0n4


[root@rocky2 ~]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Sun Feb 25 17:05:10 2024
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rootvg-LV_root /                       xfs     defaults        0 0
UUID=92e2631a-8a4e-4290-b086-f358e1c16a08 /boot                   xfs     defaults        0 0
/dev/mapper/rootvg-LV_swap none                    swap    defaults        0 0



[root@rocky2 ~]# vi /etc/fstab
#
# /etc/fstab
# Created by anaconda on Sun Feb 25 17:05:10 2024
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rootvg-LV_root /                       xfs     defaults        0 0
UUID=92e2631a-8a4e-4290-b086-f358e1c16a08 /boot                   xfs     defaults        0 0
/dev/mapper/rootvg-LV_swap none                    swap    defaults        0 0
UUID=d8f0bdfc-8ca7-411b-a337-f3dc0a80db5d       /mnt/datadisk2  ext4    defaults        00
UUID=93dd64e0-8e6e-4346-8b6a-16e04484c814       /mnt/datadisk1  xfs     defaults        00


```


Yeni eklenen disk lsblk vs gozukmezse. En gözükmezse reboot edilir.

```sh
#çalıştırabilir
[root@rocky2 ~]# partprobe

[root@rocky2 ~]# rescan-scsi-bus
-bash: rescan-scsi-bus: command not found

for HOST in /sys/class/scsi_host/host*/scan; do echo "- - -" >  ${HOST}; done

echo 1 > /sys/block/sdd/device/rescan

[root@rocky2 ~]# udevadm trigger

#fiziksel donanımlarla ilgili log'lar görüntülenebilir.
[root@rocky2 ~]# tail /var/log/messages
Mar 19 00:21:18 rocky2 kernel: nvme0n5: p1
Mar 19 00:23:52 rocky2 NetworkManager[756]: <info>  [1710797032.7123] dhcp4 (ens160): state changed new lease, address=192.168.2.131
Mar 19 00:23:52 rocky2 systemd[1]: Starting Network Manager Script Dispatcher Service...
Mar 19 00:23:52 rocky2 systemd[1]: Started Network Manager Script Dispatcher Service.
Mar 19 00:24:03 rocky2 systemd[1]: NetworkManager-dispatcher.service: Deactivated successfully.
Mar 19 00:25:38 rocky2 systemd-logind[749]: Watching system buttons on /dev/input/event0 (Power Button)
Mar 19 00:25:40 rocky2 systemd[4535]: Reached target Sound Card.
Mar 19 00:25:40 rocky2 systemd[4535]: Reached target Bluetooth.
Mar 19 00:25:42 rocky2 systemd-logind[749]: Watching system buttons on /dev/input/event1 (AT Translated Set 2 keyboard)
Mar 19 00:25:43 rocky2 systemd-udevd[4598]: id: Truncating stdout of 'dmi_memory_id' up to 16384 byte.


[root@rocky2 ~]# lsscsi
[2:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0 
[N:0:0:5]    disk    VMware Virtual NVMe Disk__5                /dev/nvme0n5
[N:0:0:3]    disk    VMware Virtual NVMe Disk__3                /dev/nvme0n3
[N:0:0:2]    disk    VMware Virtual NVMe Disk__2                /dev/nvme0n2
[N:0:0:1]    disk    VMware Virtual NVMe Disk__1                /dev/nvme0n1
[N:0:0:4]    disk    VMware Virtual NVMe Disk__4                /dev/nvme0n4

```

Use the lsblk --fs command to scan the block devices that are connected to a machine and
retrieve the file-system UUIDs.

```sh
[root@rocky4 user]# lsblk --fs
NAME               FSTYPE      FSVER            LABEL                UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sr0                iso9660     Joliet Extension Rocky-9-3-x86_64-dvd 2023-11-12-21-32-45-00
nvme0n1
├─nvme0n1p1        xfs                                               92e2631a-8a4e-4290-b086-f358e1c16a08    685.7M    29% /boot
└─nvme0n1p2        LVM2_member LVM2 001                              iILB9i-JnGo-0wje-VUv8-z1R7-jiDs-Wetitm
  ├─rootvg-LV_root xfs                                               d230417f-721c-44dc-8830-cea4576fa936     13.9G    13% /
  └─rootvg-LV_swap swap        1                                     6bee958c-f72f-408c-91d7-1fa11ec89867                  [SWAP]
```



## Manage Swap Space

### Swap Space Calculation

| RAM | Swap space | Swap space if allowing for hibernation |
| 2 GB or less | Twice the RAM | Three times the RAM |
| Between 2 GB and 8 GB | Same as RAM | Twice the RAM |
| Between 8 GB and 64 GB | At least 4 GB | 1.5 times the RAM |
| More than 64 GB | At least 4 | GB Hibernation is not recommended |

### Create Swap Space


