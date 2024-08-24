
## Introduction to the Bash Shell

shell regular user'da ($) karakteri bulunur

```sh
[user@host ~]$
```

super user'da ise (#) karakteri bulunur

```sh
[root@host ~]#
```


uzak bir sunucuya ssh baglantisinin yapilmasi

```sh
[user@host ~]$ ssh remoteuser@remotehost
remoteuser@remotehost's password: password
[remoteuser@remotehost ~]$
```

public key ile ssh baglantisinin yapilmasi

```sh
[user@host ~]$ ssh -i mylab.pem remoteuser@remotehost
[remoteuser@remotehost ~]$
```

public key ile ssh baglantisi ilk defa yapildiginda uyari alinir

```sh
[user@host ~]$ ssh -i mylab.pem remoteuser@remotehost
The authenticity of host 'remotehost (192.0.2.42)' can't be established.
ECDSA key fingerprint is 47:bf:82:cd:fa:68:06:ee:d8:83:03:1a:bb:29:14:a3.
Are you sure you want to continue connecting (yes/no)? yes
[remoteuser@remotehost ~]$
```

## Execute Commands with the Bash Shell

### Basic Command Syntax



```sh
[user@host ~]$ whoami
user
[user@host ~]$
```

Tek satirda birden fazla komut yazmak icin, komutlar (;) isareti ile birleştirilerek yazilabilir.


```sh
[user@host ~]$ command1 ; command2
command1 output
command2 output
[user@host ~]$
```

#### Write Simple Commands

data ile tarih ve saat goruntulenir. (+) işareti ile arguman alinarak farkli ciktilar elde edilebilir.

```sh
[user@host ~]$ date
Sun Feb 27 08:32:42 PM EST 2022
[user@host ~]$ date +%R
20:33
[user@host ~]$ date +%x
02/27/2022
[root@rocky2 user]# date +%R
22:35
```

passwd secenek almadan calistirilirsa varsayilan kullanicinin parolasini degistirir. Super kullanicilar diğer kullacilarin parolasini degistirebilir.

```sh
[user@host ~]$ passwd
Changing password for user user.
Current password: old_password
New password: new_password
Retype new password: new_password
passwd: all authentication tokens updated successfully.
```

Farkli dosya tipleri bulunmaktadir

```sh
[user@host ~]$ file /etc/passwd
/etc/passwd: ASCII text
[user@host ~]$ file /bin/passwd
/bin/passwd: setuid ELF 64-bit LSB pie executable, x86-64, version 1
 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2,
 BuildID[sha1]=a467cb9c8fa7306d41b96a820b0178f3a9c66055, for GNU/Linux 3.2.0,
 stripped
[user@host ~]$ file /home
/home: directory
```

### View the Contents of Files

cat, icerik goruntulemek icin kullanilan komutlardan biridir

```sh
[user@host ~]$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
...output omitted...
```

birden fazla dosyanin goruntulenmesi icin

```sh
[user@host ~]$ cat file1 file2
Hello World!!
Introduction to Linux commands.
```

yon tuslari asagiya, yukariya goruntuleme yapilabilir. Cikmak icin q tusuna basilir

head ve tail komutlari goruntulemek icin kullanilabilir. Varsayilan olarak 10 satiri goruntulerler. -n parametresi ile istedidigimiz satir sayisi belirtilebilir

```sh
[user@host ~]$ head /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
[user@host ~]$ tail -n 3 /etc/passwd
gdm:x:42:42::/var/lib/gdm:/sbin/nologin
gnome-initial-setup:x:980:978::/run/gnome-initial-setup/:/sbin/nologin
dnsmasq:x:979:977:Dnsmasq DHCP and DNS server:/var/lib/dnsmasq:/sbin/nologin
```

wc komutu bir dosyadaki satirlari, kelimeleri ve karakterleri sayar. -l, -w veya -c seceneklerini kullanarak
sirasiyla yalnizca belirtilen sayida satiri, sozcuğu veya karakteri goruntuler.

```sh
[user@host ~]$ wc /etc/passwd
41 98 2338 /etc/passwd
[user@host ~]$ wc -l /etc/passwd ; wc -l /etc/group
41 /etc/passwd
63 /etc/group
[user@host ~]$ wc -c /etc/group /etc/hosts
883 /etc/group
114 /etc/hosts
997 total
```

### Write a Long Command on Multiple Lines

Bir komutu birden fazla satira yazmak icin ters egik cizgi karakterini (\) kullanin

```sh
[user@host ~]$ head -n 3 \
/usr/share/dict/words \
/usr/share/dict/linux.words
==> /usr/share/dict/words <==
1080
10-point
10th
==> /usr/share/dict/linux.words <==
1080
10-point
10th
```

### Display the Command History

history, onceden calistirilmis komutlarin listesini goruntuler

```sh
[user@host ~]$ history
...output omitted...
 23 clear
 24 who
 25 pwd
 26 ls /etc
 27 uptime
 28 ls -l
 29 date
 30 history
 .
 .
 312 ls
[root@rocky2 user]# !312
ls
consultant1.txt  Documents  dosya10  dosya12  dosya14  dosya16  dosya18  dosya2   dosya3  dosya5  dosya7  dosya9      klasor  test1
directory        dosya1     dosya11  dosya13  dosya15  dosya17  dosya19  dosya20  dosya4  dosya6  dosya8  hostbackup  test    yum.conf
[root@rocky2 user]# !ls
ls
consultant1.txt  Documents  dosya10  dosya12  dosya14  dosya16  dosya18  dosya2   dosya3  dosya5  dosya7  dosya9      klasor  test1
directory        dosya1     dosya11  dosya13  dosya15  dosya17  dosya19  dosya20  dosya4  dosya6  dosya8  hostbackup  test    yum.conf
```

### Edit the Command Line

Useful Command-line Editing Shortcuts

| Shortcut | Description    |
|--|--|
|   Ctrl+A  |   Jump to the beginning of the command line. |
|   Ctrl+E  |   Jump to the end of the command line.   |
|   Ctrl+U  |   Clear from the cursor to the beginning of the command line.    |
|   Ctrl+K  |   Clear from the cursor to the end of the command line.  |
|   Ctrl+LeftArrow  |   Jump to the beginning of the previous word on the command line.    |
|   Ctrl+RightArrow |   Jump to the end of the next word on the command line. |
|   Ctrl+R  |   Search the history list of commands for a pattern. |




