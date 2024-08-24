# Control Access to Files

## Linux File-system Permissions

Effects of Permissions on Files and Directories

|Permission|  Effect on files      |   Effect on directories        |
|--|--|--|
| r (read) | File contents can be read. | Contents of the directory (the file names) can be listed. |
| w (write) | File contents can be changed. | Any file in the directory can be created or deleted. |
| x (execute) | Files can be executed as commands. | The directory can become the current working directory. You can run the cd command to it, but it also requires read permission to list files there.|


## View File and Directory Permissions and Ownership

r - read

w - write

x - execute

Kullanıcı bazlı - grup bazlı - diğer kullanicilar için uygulayabilirim

```sh
[root@rocky2 dev]# ls -l /dev
total 0
crw-r--r--. 1 root root     10, 235 Mar  8 19:19 autofs
drwxr-xr-x. 2 root root         160 Mar  8 19:19 block
drwxr-xr-x. 2 root root          60 Mar  8 19:18 bsg
drwxr-xr-x. 3 root root          60 Mar  8 19:18 bus
lrwxrwxrwx. 1 root root           3 Mar  8 19:19 cdrom -> sr0
drwxr-xr-x. 2 root root        3120 Mar  8 19:19 char
crw--w----. 1 root tty       5,   1 Mar  8 19:19 console
lrwxrwxrwx. 1 root root          11 Mar  8 19:18 core -> /proc/kcore
drwxr-xr-x. 4 root root          80 Mar  8 19:18 cpu
crw-------. 1 root root     10, 124 Mar  8 19:19 cpu_dma_latency
drwxr-xr-x. 8 root root         160 Mar  8 19:19 disk
brw-rw----. 1 root disk    253,   0 Mar  8 19:19 dm-0
brw-rw----. 1 root disk    253,   1 Mar  8 19:19 dm-1

```


|The first character of the long listing is the file type, and is interpreted as follows:|
|--|
| • - is a regular file. |
| • d is a directory. |
| • l is a symbolic link. |
| • c is a character device file. |
| • b is a block device file. |
| • p is a named pipe file. |
| • s is a local socket file. |



drwxr-xr--. 3 root root          60 Mar  8 19:18 bus

drwx(owner)  r-x(grup veya kullanıcı)  r--(owner ve gruba dahil olmayan herhangi bir kullanıcı) .(Nokta işareti ACL) 3 root root          60 Mar  8 19:18 bus

üçlü olarak ayrılır

rwx owner'ın yetkisi read write ve execute yetkisi var

r-x grup ve kullanıcın yetkisini tanımlar sadece read

r-- owner ve gruba dahil olmayan herhangi bir kullanıcı

. ACL belirtir (Access Control List) eğer (.) Nokta işareti değil + işareti varsa ACL tanımlanmıştır.

ACL

owner veya kullanıcı-grup yetkilendirmeleri değiştirilmeden yetkilendirme için

```sh
[root@rocky2 ~]# getfacl dosya1.txt
# file: dosya1.txt
# owner: root
# group: root
user::rw-
group::r--
other::r--
[root@rocky2 ~]# setfacl -m u:operator1:rwx dosya1.txt
[root@rocky2 ~]# getfacl dosya1.txt
# file: dosya1.txt
# owner: root
# group: root
user::rw-
user:operator1:rwx
group::r--
mask::rwx
other::r--
[root@rocky2 ~]# ls -l
total 24
-rw-------.  1 root root 1425 Feb 25 20:09 anaconda-ks.cfg
drwxr-xr-x. 10 root root 4096 Mar  9 01:37 Documents
-rw-rwxr--+  1 root root    0 Mar  8 23:17 dosya1.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya2.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya3.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya4.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya5.txt
drwxr-xr-x.  2 root root 4096 Mar  8 23:12 files
drwxr-xr-x.  2 root root    6 Mar  8 23:11 folders
-rw-r--r--.  1 root root   60 Mar  9 04:27 output.txt
drwxr-xr-x.  4 root root   34 Mar  8 23:07 parentfolder
drwxr-xr-x.  2 root root    6 Mar  6 21:27 serverbackup
-rw-r--r--.  1 root root 5811 Mar  9 04:29 users.txt
drwxr-xr-x.  2 root root   54 Mar  8 23:15 Videos
```


## Manage File System Permissions from the Command Line


### Change Permissions with the Symbolic Method(Sembolik Metot)


chmod Who/What/Which file|directory

| Who | Set | Description|
|--|--|--|
| u | user | The file owner. |
| g | group | Member of the file's group. |
| o | other | Users who are not the file owner nor members of the file's group. |
| a | all | All the three previous groups. |


Operators

| What | Operation | Description |
|--|--|--|
| + | add | Adds the permissions to the file. |
| - | remove | Removes the permissions to the file. |
| = | set exactly | Set exactly the provided permissions to the file. |


Permissions

| Which | Mode | Description |
|--|--|--|
| r | read | Read access to the file. Listing access to the directory. |
| w | write | Write permissions to the file or directory. |
| x | execute | Execute permissions to the file. Allows to enter the directory, and access files and subdirectories inside the directory. |
| X | special execute | Execute permissions for a directory, or execute permissions to a file if it has at least one of the execute bits set. |



chmod   u - user    +/-/=   dosyaismi/dizinisimi

        g - group   +/-/=   dosyaismi/dizinisimi     
        
        o - other   +/-/=   dosyaismi/dizinisimi

        a - all     +/-/=   dosyaismi/dizinisimi

chmod u+rwx dosyaismi

chmod ug+rwx

chmod og+rwx

chmod u=rw 

chmod u-x


bütün herkesin yetkisi alınır
```sh
[root@rocky2 ~]# chmod a-rwx dosya1.txt
[root@rocky2 ~]# ls -l dosya1.txt
----------+ 1 root root 0 Mar  8 23:17 dosya1.txt
[root@rocky2 ~]# chmod a-rwx dosya2.txt
[root@rocky2 ~]# ls -l dosya2.txt
----------. 1 root root 0 Mar  8 23:17 dosya2.txt
```

user'a read yetkisi verme

```sh
[root@rocky2 ~]# chmod u+r dosya2.txt
[root@rocky2 ~]# ls -l dosya2.txt
-r--------. 1 root root 0 Mar  8 23:17 dosya2.txt
```

group ve other için sadece execute yetkisi

```sh
[root@rocky2 ~]# chmod go+x dosya2.txt
[root@rocky2 ~]# ls -l dosya2.txt
-r----x--x. 1 root root 0 Mar  8 23:17 dosya2.txt
```

User'ı read write execute yetkisi ile eşitleme

```sh
[root@rocky2 ~]# chmod u=rwx dosya2.txt
[root@rocky2 ~]# ls -l dosya2.txt
-rwx--x--x. 1 root root 0 Mar  8 23:17 dosya2.txt
```

User'ı sadece read verme diğer yetkileri alma

```sh
[root@rocky2 ~]# chmod u=r dosya2.txt
[root@rocky2 ~]# ls -l dosya2.txt
-r----x--x. 1 root root 0 Mar  8 23:17 dosya2.txt
```

Dizin altında oluşturulan dosyalar dizinle aynı yetkide olmaz.(Umask diye bir kavram'dan dolayı böyledir )

```sh
[root@rocky2 ~]# ls -l
total 24
-rw-------.  1 root root 1425 Feb 25 20:09 anaconda-ks.cfg
drwxr-xr-x. 10 root root 4096 Mar  9 01:37 Documents
----------+  1 root root    0 Mar  8 23:17 dosya1.txt
-r----x--x.  1 root root    0 Mar  8 23:17 dosya2.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya3.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya4.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya5.txt
drwxr-xr-x.  2 root root 4096 Mar  8 23:12 files
drwxr-xr-x.  2 root root    6 Mar  8 23:11 folders
-rw-r--r--.  1 root root   60 Mar  9 04:27 output.txt
dr--r-xr-x.  4 root root   34 Mar  8 23:07 parentfolder
drwxr-xr-x.  2 root root    6 Mar  6 21:27 serverbackup
[root@rocky2 ~]# touch parentfolder/test1.txt parentfolder/test2.txt
[root@rocky2 ~]# ls -l parentfolder/
total 0
drwxr-xr-x. 2 root root 6 Mar  8 23:07 child1
drwxr-xr-x. 2 root root 6 Mar  8 23:07 child2
-rw-r--r--. 1 root root 0 Mar 10 07:42 test1.txt
-rw-r--r--. 1 root root 0 Mar 10 07:42 test2.txt
```


Dizin ve  dizin altındaki dizin ve dosyalar aynı yetkilerin verilmesi için

```sh
#yetki alma
[root@rocky2 ~]# chmod -R ugo-rwx parentfolder
[root@rocky2 ~]# ls -l parentfolder/
total 0
d---------. 2 root root 6 Mar  8 23:07 child1
d---------. 2 root root 6 Mar  8 23:07 child2
----------. 1 root root 0 Mar 10 07:42 test1.txt
----------. 1 root root 0 Mar 10 07:42 test2.txt
#yetki verme
[root@rocky2 ~]# chmod -R ugo+rwx parentfolder
[root@rocky2 ~]# ls -l parentfolder/
total 0
drwxrwxrwx. 2 root root 6 Mar  8 23:07 child1
drwxrwxrwx. 2 root root 6 Mar  8 23:07 child2
-rwxrwxrwx. 1 root root 0 Mar 10 07:42 test1.txt
-rwxrwxrwx. 1 root root 0 Mar 10 07:42 test2.txt
```


## Change Permissions with the Octal Method(Numerik Metot)

chmod ### file|directory

• Start with 0.

• If you want to add read permissions for this access level, then add 4.

• If you want to add write permissions, then add 2.

• If you want to add execute permissions, then add 1.

1   1   1   

4   2   1

4 + 2  + 1 =7

(u)User

1   1   0

r   w   x

4 + 2 + 0 =6

(g)Group

1   0   0

r   w   x

4 + 0 + 0 =4

(o)Other


1   0   0

r   w   x

4 + 0 + 0 =4


chmod 644 sample.xt

```sh
[root@rocky2 ~]# chmod 644 dosya3.txt
[root@rocky2 ~]# ls -l dosya3.txt
-rw-r--r--. 1 root root 0 Mar  8 23:17 dosya3.txt
```



## Change File and Directory User or Group Ownership


ownerlığı farklı bir kullanıcıya verme

```sh
[root@rocky2 ~]# chown operator1 dosya4.txt
[root@rocky2 ~]# ls -l dosya4.txt
-rw-r--r--. 1 operator1 root 0 Mar  8 23:17 dosya4.txt
```

dizin altındaki tüm klasörlerin ve dosyaların owner'lığını verme

```sh
[root@rocky2 ~]# chown -R operator1 parentfolder
[root@rocky2 ~]# ls -l parentfolder/
total 0
drwxrwxrwx. 2 operator1 root 6 Mar  8 23:07 child1
drwxrwxrwx. 2 operator1 root 6 Mar  8 23:07 child2
-rwxrwxrwx. 1 operator1 root 0 Mar 10 07:42 test1.txt
-rwxrwxrwx. 1 operator1 root 0 Mar 10 07:42 test2.txt
```

grubun ownerlığını değiştirme. Grup ownerlığı ile beraber kullanıcı ownerlığını da değiştirme

```sh
[root@rocky2 ~]# chown :operators dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
-rw-r--r--. 1 root operators 0 Mar  8 23:17 dosya5.txt
[root@rocky2 ~]# chown operator1:operators dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
-rw-r--r--. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt
```






## Manage Default Permissions and File Access

### Special Permissions

x bir komutu o komutun owner yetkisiyle çalıştırmak için

Effects of Special Permissions on Files and Directories

örnek olarak passwd root haklarıyla beraber çalıştırılır.

```sh
[root@rocky2 ~]# ls -l /bin/passwd
-rwsr-xr-x. 1 root root 32656 May 15  2022 /bin/passwd
```

|   Permission  | Effect on files   |    Effect on directories  |
|--|--|--|
|   u+s (suid)  | File executes as the userthat owns the file, not asthe user that ran the file. | No effect. |
|   g+s (sgid)  | File executes as the group that owns the file. | Files that are created in the directory have a group owner to match the group owner of the directory. |
| o+t (sticky) | No effect. | Users with write access to the directory can remove only files that they own; they cannot remove or force saves to files that other users own. |

User veya grup owner lığı ile çalıştır


Setting Special Permissions

• Symbolic : setuid = u+s; setgid = g+s; sticky = o+t

• Octal : In the added fourth preceding digit; setuid = 4; setgid = 2; sticky = 1

sticky --> sadece bulunduğu dizinde veya dosyada işlemler yapabilir. okuyabilir ama silinemez

chmod u + s

chmod g + s

chmod o + t

bütün herkesin yetkisinin alınması

```sh
[root@rocky2 ~]# chmod 000 dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
----------. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt
```

sadece kullanıcı için execute yetkisi

```sh
[root@rocky2 ~]# chmod u+x dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
---x------. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt
```

```sh
[root@rocky2 ~]# vi hello

vi hello
#!/bin/bash
echo "Hello $USER"
~
~
~
```

/bin altına kopyalayım ve user'lar için execute yetkisi verelim

```sh
[root@rocky2 ~]# chmod u+s /bin/hello
[root@rocky2 ~]# ls -l /bin/hello
-rwSr--r--. 1 root root 31 Mar 10 08:41 /bin/hello
[root@rocky2 ~]# chmod u+x /bin/hello
[root@rocky2 ~]# hello
Hello root
[root@rocky2 ~]# ls -l /bin/hello
-rwsr--r--. 1 root root 31 Mar 10 08:41 /bin/hello
[root@rocky2 user]# chmod a+x /bin/hello
[user@rocky2 ~]$ hello
Hello user
```

Add the setgid bit on the example directory by using the
symbolic method

```sh
[root@rocky2 ~]# chmod 000 dosya5.txt
[root@rocky2 ~]# chmod g+s dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
------S---. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt
```

Remove the setuid bit on the example directory by using the symbolic method

```sh
[root@rocky2 ~]# chmod u+s dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
---S--S---. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt
[root@rocky2 ~]# chmod u-s dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
------S---. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt
```

Set the setgid bit and add read, write, and execute permissions for user and group, with no
access for others, on the example directory by using the octal method

```sh
[root@rocky2 ~]# chmod 000 dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
----------. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt
[root@rocky2 ~]# chmod 2770 dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
-rwxrws---. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt

```

chmod 4700         user'a sticky permission ataması yapar

chmod 2700         sticky permission ataması yapar

chmod 1700          other'a sticky permission atama yapar


işletmek istediğimiz komutları owner'ın haklarıyla işletmek istediğimizde kullanırız

Add an extra 0 at the beginning of the permissions value when removing special permissions by using
the octal method

```sh
[root@rocky2 ~]# chmod 000 dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
----------. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt
[root@rocky2 ~]# chmod 00770 dosya5.txt
[root@rocky2 ~]# ls -l dosya5.txt
-rwxrwx---. 1 operator1 operators 0 Mar  8 23:17 dosya5.txt

```
 

### Default File Permissions

0022 herkesin okuma ve çalıştırma iznine sahip olduğunu belirtir

Default yetki tanımlama

```sh
[root@rocky2 ~]# umask
0022
[root@rocky2 ~]# touch test3.txt
[root@rocky2 ~]# ls -l test3.txt
-rw-r--r--. 1 root root 0 Mar 10 20:06 test3.txt
#herkese read write yetkisinin verilmesi
[root@rocky2 ~]# umask 0
[root@rocky2 ~]# touch test4.txt
[root@rocky2 ~]# ls -l test4.txt
-rw-rw-rw-. 1 root root 0 Mar 10 20:06 test4.txt
#bir sıfır veya 4 sıfır olması farketmez
[root@rocky2 ~]# umask 0000
[root@rocky2 ~]# touch test5.txt
[root@rocky2 ~]# ls -l test5.txt
-rw-rw-rw-. 1 root root 0 Mar 10 20:10 test5.txt
```

|       |   Symblolic   |   Numeric octal   |   Numeric Binary  |
|--|--|--|--|
| Initial file permissions | rw-rw-rw-  |   0666    |   000 110 110 110     |
| umask                     |--------w- |   0002    |   000 000 000 0010    |
| resulting file permissions |  rw-rw-r--   |   0664    |   000 110 110 100 |


default yapılandırmaların bulunduğu dosyalar ve default permission atanabilen dosyalar.

3 farkli dosya ve yöntem vardır.

/etc/profile

~/.bashrc

/etc/bashrc

İşlem yapmak yapıya uygun olmaz. Değişiklik yapılması önerilmez


/

```sh
[root@rocky2 ~]# cat /etc/profile
# /etc/profile

# System wide environment and startup programs, for login setup
# Functions and aliases go in /etc/bashrc

# It's NOT a good idea to change this file unless you know what you
# are doing. It's much better to create a custom.sh shell script in
# /etc/profile.d/ to make custom changes to your environment, as this
# will prevent the need for merging in future updates.
pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}
.
.
.

[root@rocky2 ~]# cat .bashrc
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
.
.
.

[root@rocky2 ~]# cat /etc/bashrc
# /etc/bashrc

# System wide functions and aliases
# Environment stuff goes in /etc/profile

# It's NOT a good idea to change this file unless you know what you
# are doing. It's much better to create a custom.sh shell script in
# /etc/profile.d/ to make custom changes to your environment, as this
# will prevent the need for merging in future updates.

# Prevent doublesourcing
if [ -z "$BASHRCSOURCED" ]; then
  BASHRCSOURCED="Y"

  # are we an interactive shell?
  if [ "$PS1" ]; then
    if [ -z "$PROMPT_COMMAND" ]; then
      case $TERM in
      xterm*|vte*)
        if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
        else
            PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        fi
        ;;
      screen*)
        if [ -e /etc/sysconfig/bash-prompt-screen ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
        else
            PROMPT_COMMAND='printf "\033k%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        fi
        ;;
      *)
        [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
        ;;
      esac
    fi
.
.
.

```


/etc/profile.d/ dizini altında custom tanımlamalar yapılabilir

```sh
[root@rocky2 ~]# vi /etc/profile.d/local-umask.sh

# Overrides default umask configuration asda sda
if [ $UID -gt 199 ] && [ "`id -gn`" = "`id -un`" ]; then
 umask 007
else
 umask 022
fi
~
~
~
```






