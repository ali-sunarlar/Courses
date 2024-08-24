

# Manage Network-Attached Storage with NFS

Identify NFS export information, create a directory to use as a mount point, mount an NFS export
with the mount command or by configuring the /etc/fstab file, and unmount an NFS export
with the umount command.


## Accessing Exported NFS Directories

The Network File System (NFS) is an internet standard protocol that Linux, UNIX, and similar
operating systems use as their native network file system. NFS is an open standard that supports
native Linux permissions and file-system attributes.

Red Hat 9'da nfs 4.2 kullanıyor daha önceki versiyonları destekliyor. NFSv4 sadece TCP bağlantısı kullanırken NFSv3 TCP ve UDP kullanır

By default, Red Hat Enterprise Linux 9 uses NFS version 4.2. RHEL fully supports both NFSv3 and
NFSv4 protocols. NFSv3 could use either a TCP or a UDP transport protocol, but NFSv4 allows
only TCP connections.

NFS servers export directories. NFS clients mount exported directories to an existing local mount
point directory. NFS clients can mount exported directories in multiple ways:



• Manually by using the mount command.(manuel olarak eklenebilir)

• Persistently at boot by configuring entries in the /etc/fstab file.(kalıcı olarak ekleme)

• On demand by configuring an automounter method.(isteğe bağlı tek seferlik automount yöntemi)


The automounter methods, which include the autofs service and the systemd.automount
facility, are discussed in the Automount Network-Attached Storage section. You
must install the nfs-utils package to obtain the client tools for manually mounting, or for
automounting, to obtain exported NFS directories.


```sh
[root@host ~]# dnf install nfs-utils
```


RHEL also supports mounting shared directories from Microsoft Windows systems by using the
same methods as for the NFS protocol, by using either the Server Message Block (SMB) or the
Common Internet File System (CIFS) protocols. Mounting options are protocol-specific and
depend on your Windows Server or Samba Server configuration.


Query a Server's Exported NFS Directories

The NFS protocol changed significantly between NFSv3 and NFSv4. The method to query a
server to view the available exports is different for each protocol version.

NFSv3 used the RPC protocol, which requires a file server that supports NFSv3 connections to run
the rpcbind service. An NFSv3 client connects to the rpcbind service at port 111 on the server
to request NFS service. The server responds with the current port for the NFS service. Use the
showmount command to query the available exports on an RPC-based NFSv3 server

```sh
[root@host ~]# showmount --exports server
Export list for server
/shares/test1
/shares/test2
```

The NFSv4 protocol eliminated the use of the legacy RPC protocol for NFS transactions. Use of
the showmount command on a server that supports only NFSv4 times out without receiving a
response, because the rpcbind service is not running on the server. However, querying an NFSv4
server is simpler than querying an NFSv3 server.

NFSv4 introduced an export tree that contains all of the paths for the server's exported
directories. To view all of the exported directories, mount the root (/) of the server's export tree.
Mounting the export tree's root provides browseable paths for all exported directories, as children
of the tree's root directory, but does not mount ("bind") any of the exported directories.

```sh
[root@host ~]# mkdir /mountpoint
[root@host ~]# mount server:/ /mountpoint
[root@host ~]# ls /mountpoint
```


To mount an NFSv4 export while browsing the mounted export tree, change directory into an
exported directory path. Alternatively, use the mount command with an exported directory's
full path name to mount a single exported directory. Exported directories that use Kerberos
security do not allow mounting or accessing a directory while browsing an export tree, even though
you can view the export's path name. Mounting Kerberos-protected shares requires additional
server configuration and using Kerberos user credentials, which are discussed in the Red Hat
Security: Identity Management and Active Directory Integration (RH362)
training course.


Manually Mount Exported NFS Directories

After identifying the NFS export to mount, create a local mount point if it does not yet exist. The
\mnt directory is available for use as a temporary mount point, but recommended practice is not
to use \mnt for long-term or persistent mounting.

```sh
[root@host ~]# mkdir /mountpoint
```


As with local volume file systems, mount the NFS export to access its contents. NFS shares can be
mounted temporarily or permanently, only by a privileged user.

```sh
[root@host ~]# mount -t nfs -o rw,sync server:/export /mountpoint
```

The -t nfs option specifies the NFS file-system type. However, when the mount command
detects the server:/export syntax, the command defaults to the NFS type. The -o sync option
specifies that all transactions to the exported file system are performed synchronously, which is
strongly recommended for all production network mounts where transactions must be completed
or else return as failed.


Using a manual mount command is not persistent. When the system reboots, that NFS export will
not still be mounted. Manual mounts are useful for providing temporary access to an exported
directory, or for test mounting an NFS export before persistently mounting it.


Persistently Mount Exported NFS Directories

To persistently mount an NFS export, edit the /etc/fstab file and add the mount entry with
similar syntax to manual mounting.

```sh
[root@host ~]# vim /etc/fstab
...
server:/export /mountpoint nfs rw,soft 0 0
```



Then, you can mount the NFS export by using only the mount point. The mount command obtains
the NFS server and mount options from the matching entry in the /etc/fstab file.

```sh
[root@host ~]# mount /mountpoint

```



Unmount Exported NFS Directories

As a privileged user, unmount an NFS export with the umount command. Unmounting a share
does not remove its entry in the /etc/fstab file, if that file exists. Entries in the /etc/fstab file
are persistent and are remounted during boot.


```sh
[root@host ~]# umount /mountpoint
```

A mounted directory can sometimes fail to unmount, and returns an error that the device is
busy. The device is busy because either an application is keeping a file open within the file system,
or some user's shell has a working directory in the mounted file-system's root directory or below it.


To resolve the error, check your own active shell windows, and use the cd command to leave the
mounted file system. If subsequent attempts to unmount the file system still fail, then use the
lsof (list open files) command to query the mount point. The lsof command returns a list of
open file names and the process which is keeping the file open

```sh
[root@host ~]# lsof /mountpoint
COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
program 5534 user txt REG 252.4 910704 128 /home/user/program
```


With this information, gracefully close any processes that are using files on this file system, and
retry the unmount. In critical scenarios only, when an application cannot be closed gracefully, kill
the process to close the file. Alternatively, use the umount -f option to force the unmount, which
can cause loss of unwritten data for all open files.



```sh
[root@rocky2 ~]# mkdir /public

```



# Automount Network-Attached Storage


## Mount NFS Exports with the Automounter

The automounter is a service (autofs) that automatically mounts file systems and NFS exports
on demand, and automatically unmounts file systems and NFS exports when the mounted
resources are no longer in current use.

The automounter function was created to solve the problem that unprivileged users do not
have sufficient permissions to use the mount command. Without use of the mount command,
normal users cannot access removable media such as CDs, DVDs, and removable disk drives.
Furthermore, if a local or remote file system is not mounted at boot time by using the /etc/
fstab configuration, then a normal user is unable to mount and access those unmounted file
systems.


The automounter configuration files are populated with file system mount information, in a similar
way to /etc/fstab entries. Although /etc/fstab file systems mount during system boot and
remain mounted until system shutdown or other intervention, automounter file systems do not
necessarily mount during system boot. Instead, automounter-controlled file systems mount on
demand, when a user or application attempts to enter the file system mount point to access files.

Automounter Benefits

Resource use for automounter file systems is equivalent to file systems that are mounted at
boot, because a file system uses resources only when a program is reading and writing open files.
Mounted but idle file systems and unmounted file systems use the same amount of resources:
almost none.

The automounter advantage is that by unmounting the file system each time it is no longer in use,
the file system is protected from unexpected corruption while it is open. When the file system is
directed to mount again, the autofs service uses the most current mount configuration, unlike an
/etc/fstab mount, which might still use a configuration that was mounted months ago during
the last system boot. Additionally, if your NFS server configuration includes redundant servers and
paths, then the automounter can select the fastest connection each time that a new file system is
requested.

The Automounter autofs Service Method

The autofs service supports the same local and remote file systems as in the /etc/fstab file,
including NFS and SMB file sharing protocols, and supports the same protocol-specific mount
options, including security parameters. File systems that are mounted through the automounter
are available by default to all users, but can be restricted through access permission options.

Because the automounter is a client-side configuration that uses the standard mount and umount
commands to manage file systems, automounted file systems in use exhibit identical behavior
to file systems that are mounted by using /etc/fstab. The difference is that an automounter
file system remains unmounted until the mount point is accessed, which causes the file system to
mount immediately, and to remain mounted while the file system is in use. When all files on the file
system are closed, and all users and processes leave the mount point directory, the automounter
unmounts the file system after a minimal time out.

Direct and Indirect Map Use Cases


The automounter supports both direct and indirect mount-point mapping, to handle the two types
of demand mounting. A direct mount is when a file system mounts to an unchanging, known mount
point location. Almost all the file system mounts that you configured, before learning about the
automounter, are examples of direct mounts. A direct mount point exists as a permanent directory,
the same as other normal directories.

An indirect mount is when the mount point location is not known until the mount demand occurs.
An example of an indirect mount is the configuration for remote-mounted home directories,
where a user's home directory includes their username in the directory path. The user's remote file
system is mounted to their home directory, only after the automounter learns which user specified
to mount their home directory, and determines the mount point location to use. Although indirect
mount points appear to exist, the autofs service creates them when the mount demand occurs,
and deletes them again when the demand has ended and the file system is unmounted.


Configure the Automounter Service

The process to configure an automount has many steps.

First, you must install the autofs and nfs-utils packages.

```sh
[user@host ~]$ sudo dnf install autofs nfs-utils
```
These packages contain all requirements to use the automounter for NFS exports

Create a Master Map

Next, add a master map file to /etc/auto.master.d. This file identifies the base directory for
mount points and identifies the mapping file to create the automounts.

```sh
[user@host ~]$ sudo vim /etc/auto.master.d/demo.autofs
```

The name of the master map file is mostly arbitrary (although typically meaningful), and it must
have an extension of .autofs for the subsystem to recognize it. You can place multiple entries in
a single master map file; alternatively, you can create multiple master map files, each with its own
logically grouped entries.

Add the master map entry for indirectly mapped mounts, in this case:

```sh
/shares /etc/auto.demo
```

This entry uses the /shares directory as the base for indirect automounts. The /etc/
auto.demo file contains the mount details. Use an absolute file name. The auto.demo file must
be created before starting the autofs service.

Create an Indirect Map

Now, create the mapping files. Each mapping file identifies the mount point, mount options, and
source location to mount for a set of automounts.

```sh
[user@host ~]$ sudo vim /etc/auto.demo
```

The mapping file-naming convention is /etc/auto.name, where name reflects the content of
the map.

```sh
work -rw,sync serverb:/shares/work
```


The format of an entry is mount point, mount options, and source location. This example shows a
basic indirect mapping entry. Direct maps and indirect maps that use wildcards are covered later in
this section.

Known as the key in the man pages, the mount point is created and removed automatically by the
autofs service. In this case, the fully qualified mount point is /shares/work (see the master
map file). The /shares and /shares/work directories are created and removed as needed by
the autofs service.

In this example, the local mount point mirrors the server's directory structure. However, this
mirroring is not required; the local mount point can have an arbitrary name. The autofs service
does not enforce a specific naming structure on the client.

Mount options start with a dash character (-) and are comma-separated with no white space.
The file system mount options for manual mounting are also available when automounting. In this
example, the automounter mounts the export with read/write access (rw option), and the server is
synchronized immediately during write operations (sync option).

Useful automounter-specific options include -fstype= and -strict. Use fstype to specify
the file-system type, for example nfs4 or xfs, and use strict to treat errors when mounting file
systems as fatal.

The source location for NFS exports follows the host:/pathname pattern, in this example
serverb:/shares/work. For this automount to succeed, the NFS server, serverb, must
export the directory with read/write access, and the user that requests access must have standard
Linux file permissions on the directory. If serverb exports the directory with read/only access,
then the client gets read/only access even if it requested read/write access.

Wildcards in an Indirect Map

When an NFS server exports multiple subdirectories within a directory, then the automounter can
be configured to access any of those subdirectories with a single mapping entry.

Continuing the previous example, if serverb:/shares exports two or more subdirectories, and
they are accessible with the same mount options, then the content for the /etc/auto.demo file
might appear as follows:

```sh
* -rw,sync serverb:/shares/&
```

The mount point (or key) is an asterisk character (*), and the subdirectory on the source location is
an ampersand character (&). Everything else in the entry is the same.

When a user attempts to access /shares/work, the * key (which is work in this example)
replaces the ampersand in the source location and serverb:/exports/work is mounted.
As with the indirect example, the autofs service creates and removes the work directory
automatically.

Create a Direct Map


A direct map is used to map an NFS export to an absolute path mount point. Only one direct map
file is necessary, and can contain any number of direct maps.

To use directly mapped mount points, the master map file might appear as follows:


```sh
/- /etc/auto.direct
```


All direct map entries use /- as the base directory. In this case, the mapping file that contains the
mount details is /etc/auto.direct.

The content for the /etc/auto.direct file might appear as follows:

```sh
/mnt/docs -rw,sync serverb:/shares/docs
```


The mount point (or key) is always an absolute path. The rest of the mapping file uses the same
structure.

In this example, the /mnt directory exists, and it is not managed by the autofs service. The
autofs service creates and removed the full /mnt/docs directory automatically.


Start the Automounter Service

Lastly, use the systemctl command to start and enable the autofs service.

```sh
[user@host ~]$ sudo systemctl enable --now autofs
Created symlink /etc/systemd/system/multi-user.target.wants/autofs.service → /usr/
lib/systemd/system/autofs.service.
```

## The Alternative systemd.automount Method

The systemd daemon can automatically create unit files for entries in /etc/fstab that include
the x-systemd.automount option. Use the systemctl daemon-reload command after
modifying an entry's mount options, to generate a new unit file, and then use the systemctl
start unit.automount command to enable that automount configuration.

The naming of the unit is based on its mount location. For example, if the mount point is
/remote/finance, then the unit file is named remote-finance.automount. The systemd
daemon mounts the file system when the /remote/finance directory is initially accessed.

This method can be simpler than installing and configuring the autofs service. However, a
systemd.automount unit can support only absolute path mount points, similar to autofs direct
maps.














 https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-20-04

```sh
[root@host ~]# dnf install nfs-utils
[root@host ~]# showmount --exports serverip

[root@host ~]# mkdir /mountpoint
[root@host ~]# mount server:/ /mountpoint
[root@host ~]# ls /mountpoint
[root@host ~]# mount -t nfs -o rw,sync server:/export /mountpoint
[root@host ~]# vi /etc/fstab
server:/export /mountpoint nfs rw,soft 0 0
[root@host ~]# umount /mountpoint
```








