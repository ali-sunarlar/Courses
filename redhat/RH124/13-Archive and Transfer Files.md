
# Manage Compressed tar Archives

## Create Archives from the Command Line

Common Options of the tar Utility

One of the following tar command actions is required to perform a tar operation:

• -c or --create : Create an archive file.

• -t or --list : List the contents of an archive.

• -x or --extract : Extract an archive.


The following tar command general options are commonly included:

• -v or --verbose : Show the files being archived or extracted during the tar operation. (Detaylı gösterir)

• -f or --file : Follow this option with the archive file name to create or open.

• -p or --preserve-permissions : Preserve the original file permissions when extracting.(hangi dizine çıkartılıyorsa o dizinin permission'ları ile çıkartılır.)

• --xattrs : Enable extended attribute support, and store extended file attributes.

• --selinux : Enable SELinux context support, and store SELinux file contexts.

• -a or --auto-compress : Use the archive's suffix to determine the algorithm to use.(otomatik yapmak için)

• -z or --gzip : Use the gzip compression algorithm, resulting in a .tar.gz suffix.(genellikle kullanılır)

• -j or --bzip2 : Use the bzip2 compression algorithm, resulting in a .tar.bz2 suffix.

• -J or --xz : Use the xz compression algorithm, resulting in a .tar.xz suffix.

• -Z or --compress : Uses an LZ-variant algorithm, resulting in a .tar.Z suffix.

## Create an Archive


```sh
[user@host ~]$ tar -cf mybackup.tar myapp1.log myapp2.log myapp3.log
[user@host ~]$ ls mybackup.tar
archive.tar
```

the root user creates the /root/etc-backup.tar archive of the /etc directory.

```sh
[root@host ~]# tar -cf /root/etc-backup.tar /etc
tar: Removing leading `/' from member names
```

List Archive Contents

```sh
[root@host ~]# tar -tf /root/etc.tar
etc/
etc/fstab
etc/crypttab
etc/mtab
...output omitted...
```

Extract Archive Contents

```sh
[root@host ~]# mkdir /root/etcbackup
[root@host ~]# cd /root/etcbackup
[root@host etcbackup]# tar -tf /root/etc.tar
etc/
etc/fstab
etc/crypttab
etc/mtab
...output omitted...
[root@host etcbackup]# tar -xf /root/etc.tar
```

The --preserve-permissions option is enabled by default for a superuser.

```sh
[user@host scripts]# tar -xpf /home/user/myscripts.tar
...output omitted...
```


## Create a Compressed Archive

• gzip compression is the legacy, fastest method, and is widely available across platforms.

• bzip2 compression creates smaller archives but is less widely available than gzip.

• xz compression is newer, and offers the best compression ratio of the available methods.

• compress is a legacy LZ algorithm variation, and is widely available across platforms.


gzip - genellikle kullanılan en eski yöntemdir. en hızlısı da budur sıkıştırma için. Orjinal dosya boyutunu %20 kadar azaltarak sıkıştırır. Aktif olarak çoğu platformda kullanılır(xz, bzip2 her platforda bulunmayabilir.)

bzip2 - daha iyi bir sıkıştırma oranı verir. Sıkıştırma işlemi gzip'e göre yavaştır.Orjinal dosya boyunutu %40-%50 kadar azaltarak sıkıştırır.

xz - daha yüksek bir sıkıştırma oranı verir. Sıkıştırma işlemi en yavaş olandır. En yeni olandır.



Create the /root/etcbackup.tar.gz archive with gzip compression from the contents of the /etc directory:

```sh
[root@host ~]# tar -czf /root/etcbackup.tar.gz /etc
tar: Removing leading `/' from member names
```

Create the /root/logbackup.tar.bz2 archive with bzip2 compression from the contents of the /var/log directory:

```sh
[root@host ~]$ tar -cjf /root/logbackup.tar.bz2 /var/log
tar: Removing leading `/' from member names
```

Create the /root/sshconfig.tar.xz archive with xz compression from the contents of the /etc/ssh directory:

```sh
[root@host ~]$ tar -cJf /root/sshconfig.tar.xz /etc/ssh
tar: Removing leading `/' from member names
```

List the archived content in the /root/etcbackup.tar.gz file, which uses the gzip compression


```sh
[root@host ~]# tar -tf /root/etcbackup.tar.gz
etc/
etc/fstab
etc/crypttab
etc/mtab
...output omitted...
```


Extract Compressed Archive Contents

If you do include an incorrect compression type, tar reports that the specified compression type does not match the file's type.

```sh
[root@host etcbackup]# tar -tf /root/etcbackup.tar.gz
etc/
etc/fstab
etc/crypttab
etc/mtab
...output omitted...
[root@host logbackup]# tar -tf /root/logbackup.tar
var/log/
var/log/lastlog
var/log/README
var/log/private/
...output omitted...
```

The gzip and xz commands provide an -l option to view the uncompressed size of a compressed
single or archive file. Use this option to verify sufficient space is available before uncompressing or
extracting a file

sıkıştırma oranı görüntüleme

```sh
[user@host ~]$ gzip -l file.tar.gz
 compressed uncompressed ratio uncompressed_name
 221603125 303841280 27.1% file.tar
[user@host ~]$ xz -l file.xz
Strms Blocks Compressed Uncompressed Ratio Check Filename
 1 1 195.7 MiB 289.8 MiB 0.675 CRC64 file.x
```



# Transfer Files Between Systems Securely


## Transfer Remote Files with the Secure File Transfer Program

bütün platformlarda genel olarak mevcuttur.

```sh
[user@host ~]$ sftp remoteuser@remotehost
remoteuser@remotehost's password: password
Connected to remotehost.
sftp>
```

List the available sftp commands by using the help command in the sftp session

```sh
sftp> help
Available commands:
bye                                Quit sftp
cd path                            Change remote directory to 'path'
chgrp [-h] grp path                Change group of file 'path' to 'grp'
chmod [-h] mode path               Change permissions of file 'path' to 'mode'
chown [-h] own path                Change owner of file 'path' to 'own'
df [-hi] [path]                    Display statistics for current directory or
                                   filesystem containing 'path'
exit                               Quit sftp
get [-afpR] remote [local]         Download file
help                               Display this help text
lcd path                           Change local directory to 'path'
lls [ls-options [path]]            Display local directory listing
lmkdir path                        Create local directory
ln [-s] oldpath newpath            Link remote file (-s for symlink)
lpwd                               Print local working directory
ls [-1afhlnrSt] [path]             Display remote directory listing
lumask umask                       Set local umask to 'umask'
mkdir path                         Create remote directory
progress                           Toggle display of progress meter
put [-afpR] local [remote]         Upload file
pwd                                Display remote working directory
quit                               Quit sftp
reget [-fpR] remote [local]        Resume download file
rename oldpath newpath             Rename remote file
reput [-fpR] local [remote]        Resume upload file
rm path                            Delete remote file
rmdir path                         Remove remote directory
symlink oldpath newpath            Symlink remote file
version                            Show SFTP version
!command                           Execute 'command' in local shell
!                                  Escape to local shell
?                                  Synonym for help
sftp>
```

the pwd command prints the current working directory on the remote host. To print the current working directory on your local host, use the lpwd command

```sh
sftp> pwd
Remote working directory: /home/remoteuser
sftp> lpwd
Local working directory: /home/user
```

The next example uploads the /etc/hosts file on the local system to the newly created /home/
remoteuser/hostbackup directory on the remotehost machine. The sftp session expects
that the put command is followed by a local file in the connecting user's home directory, in this
case the /home/remoteuser directory

```sh
sftp> mkdir hostbackup
sftp> cd hostbackup
sftp> put /etc/hosts
Uploading /etc/hosts to /home/remoteuser/hostbackup/hosts
/etc/hosts 100% 227 0.2KB/s 00:00
```

To copy a whole directory tree recursively, use the sftp command -r option. The following
example recursively copies the /home/user/directory local directory to the remotehost
machine

```sh
sftp> put -r directory
Uploading directory/ to /home/remoteuser/directory
Entering directory/
file1 100% 0 0.0KB/s 00:00
file2 100% 0 0.0KB/s 00:00
sftp> ls -l
drwxr-xr-x 2 student student 32 Mar 21 07:51 directory
```

To download the /etc/yum.conf file from the remote host to the current directory on the local
system, execute the get /etc/yum.conf command, then exit the sftp session

```sh
sftp> get /etc/yum.conf
Fetching /etc/yum.conf to yum.conf
/etc/yum.conf 100% 813 0.8KB/s 00:00
sftp> exit
[user@host ~]$
```

To get a remote file with the sftp command on a single command line, without opening an
interactive session, use the following syntax. You cannot use single command line syntax to put
files on a remote host

```sh
[user@host ~]$ sftp remoteuser@remotehost:/home/remoteuser/remotefile
Connected to remotehost.
Fetching /home/remoteuser/remotefile to remotefile
remotefile 100% 7 
 15.7KB/s 00:00
```



```sh
[root@rocky2 ~]# scp
usage: scp [-346ABCOpqRrTv] [-c cipher] [-D sftp_server_path] [-F ssh_config]
           [-i identity_file] [-J destination] [-l limit]
           [-o ssh_option] [-P port] [-S program] source ... target
```

Password ile remote server upload

```sh
[root@rocky2 ~]# touch dosya1
[root@rocky2 ~]# scp dosya1 user1@192.168.100.132:/home/user1
user1@192.168.100.132's password: 
dosya1

[user1@rocky2 root]$ cd /home/user1
[user1@rocky2 ~]$ ls -a
.  ..  .bash_history  .bash_logout  .bash_profile  .bashrc  dosya1
```

Key ile remmote server upload

```sh
[root@rocky2 ~]# scp -i mykey dosya1 user1@192.168.100.132:/home/user1
```

Folder transfer remote server upload

```sh
[root@rocky2 ~]# mkdir scp_folder
[root@rocky2 ~]# scp -r scp_folder/ user1@192.168.100.132:/home/user1
user1@192.168.100.132's password: 


[user1@rocky2 root]$ cd /home/user1
[user1@rocky2 ~]$ ls
dosya1  scp_folder
```


key ile remote server download

```sh
[user1@rocky2 ~]$ cd scp_folder/
[user1@rocky2 scp_folder]$ ls
[root@rocky2 ~]# cd scp_folder/
[root@rocky2 scp_folder]# ls
[root@rocky2 scp_folder]# scp user1@192.168.100.132:/home/user1/dosya1 .
user1@192.168.100.132's password: 
[root@rocky2 scp_folder]# ls
dosya1
```

iki farklı sunucudan birbirine transfer

```sh
[root@rocky2 ~]# scp root@127.0.0.1:/var/log/secure root@192.168.100.132:/root/scp_folder
root@192.168.100.132's password: 
The authenticity of host '127.0.0.1 (127.0.0.1)' can't be established.
ED25519 key fingerprint is SHA256:eCCOXFLNbD7JLUz2XUY9cuTEHWY8oNh5wfhJtlc6eOE.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: 192.168.100.132
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '127.0.0.1' (ED25519) to the list of known hosts.
root@127.0.0.1's password: 
secure 

[root@rocky2 ~]# cd scp_folder/
[root@rocky2 scp_folder]# ls -l
total 12
-rw-r--r--. 1 root root    0 Aug 12 12:28 dosya1
-rw-------. 1 root root 9757 Aug 12 12:33 secure
```


Bandwidth limit

KB cinsinden belirlenir.

B --> cache kullanımı, ara bellek kullanımı için uzun sürecek kopyalamalarda kullanılması önerilir.

```sh
scp -l 1000 dosya.txt

scp --bwlimit=1024 -B dosya.txt

#4 mb'lık bir cache, ara bellek kullanılması sınırlandırabilir
scp --bwlimit=1024 -B 4096 dosya.txt root@localhost:/root/
```


Bölerek transfer

```sh
[root@rocky2 scp_folder]# ls
dosya1  secure  securebackup.tar.gz
[root@rocky2 scp_folder]# split -n 4 securebackup.tar.gz splitsecurebackup
[root@rocky2 scp_folder]# ls -l
total 32
-rw-r--r--. 1 root root    0 Aug 12 12:28 dosya1
-rw-------. 1 root root 9757 Aug 12 12:33 secure
-rw-r--r--. 1 root root 1448 Aug 12 12:50 securebackup.tar.gz
-rw-r--r--. 1 root root  362 Aug 12 12:53 splitsecurebackupaa
-rw-r--r--. 1 root root  362 Aug 12 12:53 splitsecurebackupab
-rw-r--r--. 1 root root  362 Aug 12 12:53 splitsecurebackupac
-rw-r--r--. 1 root root  362 Aug 12 12:53 splitsecurebackupad
```







# Synchronize Files Between Systems Securely


## Synchronize Remote Files and Directories


When synchronizing with the rsync command, two standard options are the -v and -a options.
The rsync command -v or --verbose option provides a more detailed output. This option is
helpful for troubleshooting and viewing live progress.
The rsync command -a or --archive option enables "archive mode". This option enables
recursive copying and turns on many valuable options to preserve most characteristics of the files.
Archive mode is the same as specifying the following options


Options Enabled with rsync -a (Archive Mode)

| Option | Description |
|--------|-------------|
| -r, --recursive | Synchronize the whole directory tree recursively |
| -l, --links | Synchronize symbolic links |
| -p, --perms | Preserve permissions |
| -t, --times | Preserve time stamps |
| -g, --group | Preserve group ownership |
| -o, --owner | Preserve the owner of the files |
| -D, --devices | Preserve device files |

Archive mode does not preserve hard links because it might add significant time to the
synchronization. Use the rsync command -H option to preserve hard links too

For example, to synchronize the contents of the /var/log directory to the /tmp directory

```sh
[user@host ~]$ su -
Password: password
[root@host ~]# rsync -av /var/log /tmp
receiving incremental file list
log/
log/README
log/boot.log
...output omitted...
log/tuned/tuned.log
sent 11,592,423 bytes received 779 bytes 23,186,404.00 bytes/sec
total size is 11,586,755 speedup is 1.00
[user@host ~]$ ls /tmp
log ssh-RLjDdarkKiW1
[user@host ~]$
```


In this example, the content of the /var/log/ directory is synchronized into the /tmp directory
instead of creating the log directory in the /tmp directory

```sh
[root@host ~]# rsync -av /var/log/ /tmp
sending incremental file list
./
README
boot.log
...output omitted...
tuned/tuned.log
sent 11,592,389 bytes received 778 bytes 23,186,334.00 bytes/sec
total size is 11,586,755 speedup is 1.00
[root@host ~]# ls /tmp
anaconda dnf.rpm.log-20190318 private
audit dnf.rpm.log-20190324 qemu-ga
boot.log dnf.rpm.log-20190331 README
...output omitted...
```

In this example, synchronize the local /var/log directory to the /tmp directory on the hosta
system

-a (dosya izinleri,dosya sahiplikleri, soft link, hard link vs tamamnını korur )
arşiv modu

-v (ayrıntılı çıktı alınması sağlanır)

-r dizin yetkilerinin kopyalanan tarafda da aynı olmasını sağlar

-z compress yapar(sıkıştırma yapar)


```sh
[root@host ~]# rsync -av /var/log hosta:/tmp
root@hosta's password: password
receiving incremental file list
log/
log/README
log/boot.log
...output omitted...
sent 9,783 bytes received 290,576 bytes 85,816.86 bytes/sec
total size is 11,585,690 speedup is 38.57
```

In the same way, the /var/log remote directory on the hosta machine synchronizes to the /tmp
directory on the host machine

```sh
[root@host ~]# rsync -av hosta:/var/log /tmp
root@hosta's password: password
receiving incremental file list
log/boot.log
log/dnf.librepo.log
log/dnf.log
...output omitted...
sent 9,783 bytes received 290,576 bytes 85,816.86 bytes/sec
total size is 11,585,690 speedup is 38.57
```

```sh
[root@servera ~]# rsync -av /var/log student@serverb:/home/student/serverlogs
...output omitted...
student@serverb's password: student
sending incremental file list
log/
log/README -> ../../usr/share/doc/systemd/README.logs
log/boot.log
...output omitted...
sent 1,390,819 bytes received 508 bytes 309,183.78 bytes/sec
total size is 1,388,520 speedup is 1.00
```













