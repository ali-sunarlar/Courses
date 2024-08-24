# Identify File Systems and Devices

## Storage Management Concepts

Red Hat Enterprise Linux (RHEL) uses the Extents File System (XFS) as the default local file
system. RHEL supports the Extended File System (ext4) file system for managing local files.
Starting with RHEL 9, the exFAT file system is supported for removable media use. In an enterprise
server cluster, shared disks use the Global File System 2 (GFS2) file system to manage concurrent
multi-node access


File Systems, Storage, and Block Devices

Block Device Naming


| Type of device | Device naming pattern |
|----------------|-----------------------|
| SATA/SAS/USB-attached storage (SCSI driver)  | /dev/sda, /dev/sdb, /dev/sdc, … |
| virtio-blk paravirtualized storage (VMs) | /dev/vda, /dev/vdb, /dev/vdc,… |
| virtio-scsi paravirtualized storage (VMs) | /dev/sda, /dev/sdb, /dev/sdc, … |
| NVMe-attached storage (SSDs) | /dev/nvme0, /dev/nvme1, … |
| SD/MMC/eMMC storage (SD cards) | /dev/mmcblk0, /dev/mmcblk1, … |


An extended listing of the /dev/sda1 device file on the host machine reveals the b file type,
which stands for a block device

```sh
[user@host ~]$ ls -l /dev/sda1
brw-rw----. 1 root disk 8, 1 Feb 22 08:00 /dev/sda1
```

The following example displays the file systems and mount points on the host machine


```sh
[user@host ~]$ df
Filesystem 1K-blocks Used Available Use% Mounted on
devtmpfs 912584 0 912584 0% /dev
tmpfs 936516 0 936516 0% /dev/shm
tmpfs 936516 16812 919704 2% /run
tmpfs 936516 0 936516 0% /sys/fs/cgroup
/dev/vda3 8377344 1411332 6966012 17% /
/dev/vda1 1038336 169896 868440 17% /boot
tmpfs 187300 0 187300 0% /run/user/1000
```

View the file systems on the host machine with all units converted to human-readable format

```sh
[user@host ~]$ df -h
Filesystem Size Used Avail Use% Mounted on
devtmpfs 892M 0 892M 0% /dev
tmpfs 915M 0 915M 0% /dev/shm
tmpfs 915M 17M 899M 2% /run
tmpfs 915M 0 915M 0% /sys/fs/cgroup
/dev/vda3 8.0G 1.4G 6.7G 17% /
/dev/vda1 1014M 166M 849M 17% /boot
tmpfs 183M 0 183M 0% /run/user/1000
```

View the disk usage report for the /usr/share directory on the host machine

```sh
[root@host ~]# du /usr/share
...output omitted...
176 /usr/share/smartmontools
184 /usr/share/nano
8 /usr/share/cmake/bash-completion
8 /usr/share/cmake
356676 /usr/share
```

View the disk usage report in human-readable format for the /usr/share directory

```sh
[root@host ~]# du -h /usr/share
...output omitted...
176K /usr/share/smartmontools
184K /usr/share/nano
8.0K /usr/share/cmake/bash-completion
8.0K /usr/share/cmake
369M /usr/share
```


# Mount and Unmount File Systems

## Mount File Systems Manually

You can mount the file system in one of the following ways with the mount command

• With the device file name in the /dev directory.

• With the UUID, a universally unique identifier of the device.



Identify a Block Device

```sh
[root@host ~]# lsblk
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
vda 252:0 0 10G 0 disk
├─vda1 252:1 0 1M 0 part
├─vda2 252:2 0 200M 0 part /boot/efi
├─vda3 252:3 0 500M 0 part /boot
└─vda4 252:4 0 9.3G 0 part /
vdb 252:16 0 5G 0 disk
vdc 252:32 0 5G 0 disk
vdd 252:48 0 5G 0 disk
```

Mount File System with the Partition Name

The following example mounts the /dev/vda4 partition on the /mnt/data mount point

```sh
[root@host ~]# mount /dev/vda4 /mnt/data
```


Mount File System with Partition UUID

```sh
[root@host ~]# lsblk -fp
NAME FSTYPE FSVER LABEL UUID FSAVAIL FSUSE% MOUNTPOINTS
/dev/vda
├─/dev/vda1
├─/dev/vda2 vfat FAT16 7B77-95E7 192.3M 4% /boot/efi
├─/dev/vda3 xfs boot 2d67e6d0-...-1f091bf1 334.9M 32% /boot
└─/dev/vda4 xfs root efd314d0-...-ae98f652 7.7G 18% /
/dev/vdb
/dev/vdc
/dev/vdd
```


Mount the file system by the file-system UUID

```sh
[root@host ~]# mount UUID="efd314d0-b56e-45db-bbb3-3f32ae98f652" /mnt/data
```

Unmount File Systems

The umount command uses the mount point as an argument to unmount a file system

```sh
[root@host ~]# umount /mnt/data
```


In the following example, the umount command fails because the shell uses the /mnt/data
directory as its current working directory, and thus generates an error message

```sh
[root@host ~]# cd /mnt/data
[root@host data]# umount /mnt/data
umount: /mnt/data: target is busy.
```

The lsof command lists all open files and the processes that are accessing the file system. The
list helps to identify which processes are preventing the file system from successfully unmounting

```sh
[root@host data]# lsof /mnt/data
COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
bash 1593 root cwd DIR 253,17 6 128 /mnt/data
lsof 2532 root cwd DIR 253,17 19 128 /mnt/data
lsof 2533 root cwd DIR 253,17 19 128 /mnt/data
```

After identifying the processes, wait for the processes to complete or send the SIGTERM or
SIGKILL signal to terminate them. In this case, it is sufficient to change the current working
directory to a directory outside the mount point

```sh
[root@host data]# cd
[root@host ~]# umount /mnt/data
```




# Locate Files on the System


## Search for Files

• The locate command searches a pre-generated index for file names or file paths and returns
the results instantly.

• The find command searches for files in real time by parsing the file-system hierarchy.


## Locate Files by Name

The locate database updates automatically every day. However, the root user might issue the
updatedb command to force an immediate update

```sh
[root@host ~]# updatedb
```

locate the files that the developer user can read, and that match the passwd keyword in the name or path

```sh
[developer@host ~]$ locate passwd
/etc/passwd
/etc/passwd-
/etc/pam.d/passwd
...output omitted...
```

The following example show the file name or path for a partial match with the search query

```sh
[root@host ~]# locate image
/etc/selinux/targeted/contexts/virtual\_image_context
/usr/bin/grub2-mkimage
/usr/lib/sysimage
...output omitted...
```

The locate command -i option performs a case-insensitive search. This option returns all
possible combinations of matching uppercase and lowercase letters


```sh
[developer@host ~]$ locate -i messages
...output omitted...
/usr/share/locale/zza/LC_MESSAGES
/usr/share/makedumpfile/eppic_scripts/ap_messages_3_10_to_4_8.c
/usr/share/vim/vim82/ftplugin/msmessages.vim
...output omitted...
```


The locate command -n option limits the number of returned search results. The following
example limits the search results from the locate command to the first five matches

```sh
[developer@host ~]$ locate -n 5 passwd
/etc/passwd
/etc/passwd-
/etc/pam.d/passwd
...output omitted...
```


## Search for Files in Real Time

To search for files by file name, use the find command -name FILENAME option to return the
path of files that match FILENAME exactly. For example, to search for the sshd_config files in
the root / directory, run the following command

```sh
[root@host ~]# find / -name sshd_config
/etc/ssh/sshd_config

[root@rocky2 ~]# find / -name sshd_config
/etc/ssh/sshd_config
```

In the following example, starting in the / directory, search for files that end with the .txt
extension

```sh
[root@host ~]# find / -name '*.txt'
...output omitted...
/usr/share/libgpg-error/errorref.txt
/usr/share/licenses/audit-libs/lgpl-2.1.txt
/usr/share/licenses/pam/gpl-2.0.txt
...output omitted...
```


To search for files in the /etc/ directory that contain the pass string, run the following command


```sh
[root@host ~]# find /etc -name '*pass*'
/etc/passwd-
/etc/passwd
/etc/security/opasswd
...output omitted...

[root@rocky2 ~]# find /etc -name '*pass*'
/etc/passwd
/etc/passwd-
/etc/security/opasswd
/etc/pam.d/passwd
/etc/pam.d/password-auth
```


To perform a case-insensitive search for a file name, use the find command -iname option,
followed by the file name to search. To search files with case-insensitive text that matches the
messages string in their names in the root / directory, run the following command

```sh
[root@host ~]# find / -iname '*messages*'
/sys/power/pm_debug_messages
/usr/lib/locale/C.utf8/LC_MESSAGES
/usr/lib/locale/C.utf8/LC_MESSAGES/SYS_LC_MESSAGES
...output omitted...
```


Search for Files Based on Ownership or Permission

To search for files in the /home/developer directory that the developer user owns

```sh
[developer@host ~]$ find -user developer
.
./.bash_logout
./.bash_profile
...output omitted...


```

To search for files in the /home/developer directory that the developer group owns


```sh
[developer@host ~]$ find -group developer
.
./.bash_logout
./.bash_profile
...output omitted...
```

To search for files in the /home/developer directory that the 1000 user ID owns

```sh
[developer@host ~]$ find -uid 1000
.
./.bash_logout
./.bash_profile
...output omitted...
```


To search for files in the /home/developer directory that the 1000 group ID owns

```sh
[developer@host ~]$ find -gid 1000
.
./.bash_logout
./.bash_profile
...output omitted...
```

The find command -user and -group options search for files where the file owner and group
owner are different. The following example lists files that the root user owns and with the mail
group

```sh
[root@host ~]# find / -user root -group mail
/var/spool/mail
...output omitted...

```


the following commands match any file in the /home directory for which the owning
user has read, write, and execute permissions, members of the owning group have read and write
permissions, and others have read-only access. Both commands are equivalent, but the first one
uses the octal method for permissions while the second one uses the symbolic methods

```sh
[root@host ~]# find /home -perm 764
...output omitted...
[root@host ~]# find /home -perm u=rw,g=rwx,o=r
...output omitted...
```

The find command -ls option is very convenient when searching files by permissions, because it
provides information for the files including their permissions

```sh
[root@host ~]# find /home -perm 764 -ls
 26207447 0 -rwxrw-r-- 1 user user 0 May 10 04:29 /home/user/file1
```


To search for files for which the user has at least write and execute permissions, the group has at
least write permission, and others have at least read permission

```sh
[root@host ~]# find /home -perm -324
...output omitted...
[root@host ~]# find /home -perm -u=wx,g=w,o=r
...output omitted...
```

To search for files for which the user has read permissions, or the group has at least read
permissions, or others have at least write permission

```sh
[root@host ~]# find /home -perm /442
...output omitted...
[root@host ~]# find /home -perm /u=r,g=r,o=w
...output omitted...
```


Find Files Based on Size


• For kilobytes, use the k unit with k always in lowercase.

• For megabytes, use the M unit with M always in uppercase.

• For gigabytes, use the G unit with G always in uppercase.


You can use the plus + and minus - characters to include files that are larger and smaller than
the given size, respectively. The following example shows a search for files with an exact size of
10 megabytes


```sh
[developer@host ~]$ find -size 10M
...output omitted...
```

To search for files with a size of more than 10 gigabytes:


```sh
[developer@host ~]$ find -size +10G
...output omitted...
```

To search for files with a size of less than 10 kilobytes

```sh
[developer@host ~]$ find -size -10k
...output omitted...
```


Search for Files Based on Modification Time

To search for all files with content that changed 120 minutes ago

```sh
[root@host ~]# find / -mmin 120
...output omitted...
```


The + modifier in front of the minutes finds all files in the / directory that changed more than
n minutes ago. To search for all files with content that changed 200 minutes ago

```sh
[root@host ~]# find / -mmin +200
...output omitted...
```

The - modifier searches for all files in the / directory that changed less than n minutes ago. The
following example lists files that changed less than 150 minutes ago

```sh
[root@host ~]# find / -mmin -150
...output omitted...
```

Search for Files Based on File Type


• For regular files, use the f flag.

• For directories, use the d flag.

• For soft links, use the l flag.

• For block devices, use the b flag.


Search for all directories in the /etc directory

```sh
[root@host ~]# find /etc -type d
/etc
/etc/tmpfiles.d
/etc/systemd
/etc/systemd/system
/etc/systemd/system/getty.target.wants
...output omitted...

```


Search for all soft links in the / directory

```sh
[root@host ~]# find / -type l
...output omitted...
```

Search for all block devices in the /dev directory

```sh
[root@rocky2 ~]# find /dev -type b
/dev/dm-1
/dev/dm-0
/dev/sr0
/dev/nvme0n1p2
/dev/nvme0n1p1
/dev/nvme0n1
```

Search for all regular files with more than one hard link


```sh
[root@host ~]# find / -type f -links +1
...output omitted...
```
