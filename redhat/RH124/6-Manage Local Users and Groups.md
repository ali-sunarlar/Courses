# Manage Local Users and Groups

## Describe User and Group Concepts

### User

Üç tip kullanıcı tipi

Regular user

System User--> service user(Service'ler için kullanilan user'lar)

Super User--> root


Her kullanıcının id aralığı vardır.

UID Ranges

Red Hat Enterprise Linux uses specific UID numbers and ranges of numbers for specific purposes.

• UID 0 : The superuser (root) account UID.

• UID 1-200 : System account UIDs statically assigned to system processes.

• UID 201-999 : UIDs assigned to system processes that do not own files on this system.

Software that requires an unprivileged UID is dynamically assigned UID from this available pool.

• UID 1000+ : The UID range to assign to regular, unprivileged users

Use the id command to show information about the currently logged-in user:

```sh
[root@rocky2 user]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```
To view basic information about another user, pass the username to the id command as an
argument:

```sh
[root@rocky2 user]# id operator1
uid=1001(operator1) gid=1001(operator1) groups=1001(operator1),30000(operators)
```

Use the ps command -a option to view all processes with a terminal. Use the ps
command -u option to view the user that is associated with a process.

```sh
[root@rocky2 user]#  ps -au
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         759  0.0  0.0   3044  1060 tty1     Ss+  Mar08   0:00 /sbin/agetty -o -p -- \u --noclear - linux
user        2496  0.0  0.2   7444  4208 pts/1    Ss   07:42   0:00 -bash
root        2522  0.0  0.4  19360  8696 pts/1    S    07:43   0:00 sudo -s
root        2526  0.0  0.2   7576  4432 pts/1    S    07:43   0:00 /bin/bash
root        2883  0.0  0.2  10140  3640 pts/1    R+   12:38   0:00 ps -au
```

Bütün kullanıcıların bilgileri yer alır
```sh
[root@rocky2 user]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
.
.
.
tech1:x:1010:1010::/home/tech1:/bin/bash
tech2:x:1011:1011::/home/tech2:/bin/bash
database1:x:1012:35003::/home/database1:/bin/bash
student:x:1013:1013::/home/student:/bin/bash
production1:x:1014:1014::/home/production1:/bin/bash
```

Consider each part of the code block, separated by a colon:

• student : The username for this user.

• x : The user's encrypted password was historically stored here; this is now a placeholder.

• 1013 : The UID number for this user account.

• 1013 : The GID number for this user account's primary group. Groups are discussed later in this
section.

• User One : A brief comment, description, or the real name for this user.

• /home/student : The user's home directory, and the initial working directory when the login
shell starts.

• /bin/bash : The default shell program for this user that runs at login. Some accounts use the
/sbin/nologin shell to disallow interactive logins with that account.

User description

```sh
[root@rocky2 user]#  usermod --comment "operator admin" operator1
[root@rocky2 user]#  usermod -c "operator admin" operator2
[root@rocky2 user]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
.
.
.
operator1:x:1001:1001:operator admin:/home/operator1:/bin/bash
operator2:x:1002:1002:operator admin:/home/operator2:/bin/bash
```





### Group



```sh
[root@rocky2 user]# cat /etc/group
root:x:0:
bin:x:1:
daemon:x:2:
sys:x:3:
adm:x:4:
.
.
.
operators:x:30000:operator1,operator2,operator3
admin:x:30001:sysadmin1,sysadmin2,sysadmin3
operator3:x:1003:
sysadmin1:x:1004:
sysadmin2:x:1005:
sysadmin3:x:1006:
consultant1:x:1007:
consultant2:x:1008:
consultant3:x:1009:
consultants:x:35000:
contractor1:x:35001:
techdocs:x:35002:tech1,tech2
```


Consider each part of the code block, separated by a colon:

• operators : Name for this group.

• x : Obsolete group password field; this is now a placeholder.

• 30000 : The GID number for this group (10000).

• operator1,operator2,operator3 : A list of users that are members of this group as a secondary group.


#### Primary Groups and Secondary Groups

1001(operator1)--> primary (kullanıcı ile beraber oluşan gruplardır)
30000(operators) 30001(admin)--> secodary veya supplementary gruplar

```sh
[root@rocky2 user]# id operator1
uid=1001(operator1) gid=1001(operator1) groups=1001(operator1),30000(operators),30001(admin)
```





## Gain Superuser Access

The Superuser

root 

Switch User Accounts

sudo su --> runas admin 

kullanıcının yetkisi olsa dahi yetkili işlemlerde sudo kullanilir.

```sh
[root@rocky2 user]# su - operator1
Last login: Wed Feb 28 03:43:43 +03 2024 on pts/1
Last failed login: Sat Mar  2 15:16:15 +03 2024 from 192.168.2.133 on ssh:notty
There were 5 failed login attempts since the last successful login.
[root@rocky2 user]# sudo su - operator1
Last login: Sat Mar  9 15:02:13 +03 2024 on pts/1
[operator1@rocky2 ~]$ su -
Password:
Last login: Tue Feb 27 23:32:05 +03 2024 on pts/0
Last failed login: Wed Mar  6 21:28:20 +03 2024 from ::1 on ssh:notty
There were 3 failed login attempts since the last successful login.
[root@rocky2 ~]#
```

su - yeni bir session başlatır

Run Commands with Sudo

The next table summarizes the differences between the su, su -, and sudo commands:

|           | su    | su -    | sudo    |
|--|--|--|--|
| Become new user | Yes | Yes | Per escalated command |
| Environment | Current user's | New user's | Current user's |
| Password required | New user's | New user's | Current user's |
| Privileges | Same as new user | Same as new user | Defined by configuration |
| Activity logged | su command only | su command only | Per escalated command |


kullanıcılara belirli-spesifik yetkilendirme yapabilmek için Command Aliases - Cmnd_Alias kullanilir.

kullaniciya sudo ile çalıştırabileceği işlevler belirtilir

```sh
[root@rocky2 ~]# vi /etc/sudoers

## Command Aliases
## These are groups of related commands...

## Networking
# Cmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig, /bin/ping, /sbin/dhclient, /usr/bin/net, /sbin/iptables, /usr/bin/rfcomm, /usr/bin/wvdial, /sbin/iwconfig, /sbin/mii-tool

## Installation and management of software
# Cmnd_Alias SOFTWARE = /bin/rpm, /usr/bin/up2date, /usr/bin/yum

## Services
# Cmnd_Alias SERVICES = /sbin/service, /sbin/chkconfig, /usr/bin/systemctl start, /usr/bin/systemctl stop, /usr/bin/systemctl reload, /usr/bin/systemctl restart, /usr/bin/systemctl status, /usr/bin/systemctl enable, /usr/bin/systemctl disable

## Updating the locate database
# Cmnd_Alias LOCATE = /usr/bin/updatedb

## Storage
# Cmnd_Alias STORAGE = /sbin/fdisk, /sbin/sfdisk, /sbin/parted, /sbin/partprobe, /bin/mount, /bin/umount

## Delegating permissions
# Cmnd_Alias DELEGATING = /usr/sbin/visudo, /bin/chown, /bin/chmod, /bin/chgrp
.
.
.
## Allows members of the 'sys' group to run networking, software,
## service management apps and more.
# %sys ALL = NETWORKING, SOFTWARE, SERVICES, STORAGE, DELEGATING, PROCESSES, LOCATE, DRIVERS

```

sudoers.d altında custome sudoers dosyalarını oluşturup yetkilendirmeler yapılabilir.Group yetkilendirmeleri % ile başlar.

```sh
[root@rocky2 ~]# vi /etc/sudoers.d/
admin        consultants  operator1
[root@rocky2 ~]# vi /etc/sudoers.d/consultants
#grup yetkilendirmesi

%consultants ALL=(ALL) ALL
~
#kullanıcı yetkilendirmesi
[root@rocky2 ~]# vi /etc/sudoers.d/operator1

operator1 ALL=(ALL) ALL
~
#kullaniciya sadece kullanıcı ekleme yetkisi verme
[root@rocky2 ~]# vi /etc/sudoers.d/useradd

operator2 ALL=/sbin/useradd NOPASSWD:ALL
~
~
```



## Manage Local User Accounts

### Create Users from the Command Line


```sh
[root@rocky2 ~]#  useradd --help
Usage: useradd [options] LOGIN
       useradd -D
       useradd -D [options]

Options:
      --badname                 do not check for bad names
  -b, --base-dir BASE_DIR       base directory for the home directory of the
                                new account
      --btrfs-subvolume-home    use BTRFS subvolume for home directory
  -c, --comment COMMENT         GECOS field of the new account
  -d, --home-dir HOME_DIR       home directory of the new account
  -D, --defaults                print or change default useradd configuration
  -e, --expiredate EXPIRE_DATE  expiration date of the new account
  -f, --inactive INACTIVE       password inactivity period of the new account
  -g, --gid GROUP               name or ID of the primary group of the new
                                account
  -G, --groups GROUPS           list of supplementary groups of the new
                                account
  -h, --help                    display this help message and exit
  -k, --skel SKEL_DIR           use this alternative skeleton directory
  -K, --key KEY=VALUE           override /etc/login.defs defaults
  -l, --no-log-init             do not add the user to the lastlog and
                                faillog databases
  -m, --create-home             create the user's home directory
  -M, --no-create-home          do not create the user's home directory
  -N, --no-user-group           do not create a group with the same name as
                                the user
  -o, --non-unique              allow to create users with duplicate
                                (non-unique) UID
  -p, --password PASSWORD       encrypted password of the new account
  -r, --system                  create a system account
  -R, --root CHROOT_DIR         directory to chroot into
  -P, --prefix PREFIX_DIR       prefix directory where are located the /etc/* files
  -s, --shell SHELL             login shell of the new account
  -u, --uid UID                 user ID of the new account
  -U, --user-group              create a group with the same name as the user
  -Z, --selinux-user SEUSER     use a specific SEUSER for the SELinux user mapping

```

The /etc/login.defs file sets some of the default options for user accounts, such as the range
of valid UID numbers and default password aging rules.

(kullanıcı, grup ve system kullanıcılarının id tanımlarının bulunduğu. Home dizininde hangi yetkinin default olarak atanacağı. Password yaşı ile alakalı bilgiler yer alır. Kullanici şifre algoritmaları  ). Bu dosyadaki değişiklikler varolan kullanıcıları etkilemez yeni oluşturulanlar için geçerli olur.

```sh
[root@rocky2 ~]# vi /etc/login.defs
# HOME_MODE is used by useradd(8) and newusers(8) to set the mode for new
# home directories.
# If HOME_MODE is not set, the value of UMASK is used to create the mode.
HOME_MODE       0700
.
.
.
# Password aging controls:
#
#       PASS_MAX_DAYS   Maximum number of days a password may be used.
#       PASS_MIN_DAYS   Minimum number of days allowed between password changes.
#       PASS_MIN_LEN    Minimum acceptable password length.
#       PASS_WARN_AGE   Number of days warning given before a password expires.
#
PASS_MAX_DAYS   99999
PASS_MIN_DAYS   0
PASS_WARN_AGE   7
.
.
.
#
# Min/max values for automatic uid selection in useradd(8)
#
UID_MIN                  1000
UID_MAX                 60000
# System accounts
SYS_UID_MIN               201
SYS_UID_MAX               999
# Extra per user uids
SUB_UID_MIN                100000
SUB_UID_MAX             600100000
SUB_UID_COUNT               65536

#
# Min/max values for automatic gid selection in groupadd(8)
#
GID_MIN                  1000
GID_MAX                 60000
# System accounts
SYS_GID_MIN               201
SYS_GID_MAX               999
# Extra per user group ids
SUB_GID_MIN                100000
SUB_GID_MAX             600100000
SUB_GID_COUNT               65536
.
.
.
#
# If set to MD5, MD5-based algorithm will be used for encrypting password
# If set to SHA256, SHA256-based algorithm will be used for encrypting password
# If set to SHA512, SHA512-based algorithm will be used for encrypting password
# If set to BLOWFISH, BLOWFISH-based algorithm will be used for encrypting password
# If set to DES, DES-based algorithm will be used for encrypting password (default)
#
ENCRYPT_METHOD SHA512

```

User Create


```sh
#description ile user oluşturma
[root@rocky2 ~]#  useradd -c "operator user" operator4
[root@rocky2 ~]# passwd operator4
Changing password for user operator4.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
```

Kullanıcı bir sonraki girişinde parola değiştirmesi sağlanır. 0 hemen ilk login 2. loginden sonra veya  5. loginden parola değiştirmesi zorlanabilir. 
```sh
[root@rocky2 ~]# change -d 0 operator4
[root@rocky2 ~]# change -d 2 operator4
```

### Modify Existing Users from the Command Line


|usermod options:|   Usage        |
|--|--|
| -a, --append | Use it with the -G option to add the secondary groups to the user's current set of group memberships instead of replacing the set of secondary groups with a new set. |
| -c, --comment | COMMENT Add the COMMENT text to the comment field. |
| -d, --home HOME_DIR | Specify a home directory for the user account. |
| -g, --gid GROUP | Specify the primary group for the user account. |
| -G, --groups | GROUPS Specify a comma-separated list of secondary groups for the user account. |
|-L, --lock | Lock the user account. |
| -m, --move-home | Move the user's home directory to a new location. You must use it with the -d option. |
| -s, --shell | SHELL Specify a particular login shell for the user account. |
| -U, --unlock | Unlock the user account. |



### Delete Users from the Command Line

"userdel -r" kullanıcıyı passwd dosyasından siler ve kullanıcının home dizinine de siler.

userdel -r seçeneğini belirtmeden bir kullanıcıyı kaldırdığınızda, kullanıcının dosyaları
artık atanmamış bir UID'ye aittir. Bir kullanıcı oluşturursanız ve bu kullanıcıya atanırsa
silinen kullanıcının UID'si, yeni hesap bu dosyalara sahip olacaktır; bu bir güvenlik önlemidir
risk. Tipik olarak, kuruluş güvenlik politikaları kullanıcı hesaplarının silinmesine izin vermez ve
bunun yerine bu senaryoyu önlemek için bunların kullanılmasını kilitleyin


```sh
[root@rocky2 ~]#  useradd -c "operator user" operator4
[root@rocky2 ~]# ls -l /home
total 4
drwx------. 4 ansible     ansible         111 Mar  3 04:29 ansible
drwx------. 2 consultant1 consultant1      83 Feb 28 03:16 consultant1
drwx------. 2 consultant2 consultant2      62 Feb 28 01:00 consultant2
drwx------. 2 consultant3 consultant3      62 Feb 28 01:00 consultant3
drwxrwx---. 2 consultant1 consultants      29 Feb 28 03:18 consultants
drwx------. 2 database1   databaseadmins   83 Feb 28 04:00 database1
drwx------. 2 operator1   operator1        83 Feb 28 02:09 operator1
drwx------. 3 operator2   operator2        95 Mar  2 15:16 operator2
drwx------. 2 operator3   operator3        62 Feb 28 00:22 operator3
drwx------. 2 operator4   operator4        62 Mar  9 17:02 operator4
drwx------. 3 production1 production1      74 Mar  2 15:30 production1
[root@rocky2 ~]# userdel operator4
[root@rocky2 ~]# ls -l /home
total 4
drwx------. 4 ansible     ansible         111 Mar  3 04:29 ansible
drwx------. 2 consultant1 consultant1      83 Feb 28 03:16 consultant1
drwx------. 2 consultant2 consultant2      62 Feb 28 01:00 consultant2
drwx------. 2 consultant3 consultant3      62 Feb 28 01:00 consultant3
drwxrwx---. 2 consultant1 consultants      29 Feb 28 03:18 consultants
drwx------. 2 database1   databaseadmins   83 Feb 28 04:00 database1
drwx------. 2 operator1   operator1        83 Feb 28 02:09 operator1
drwx------. 3 operator2   operator2        95 Mar  2 15:16 operator2
drwx------. 2 operator3   operator3        62 Feb 28 00:22 operator3
drwx------. 2        1016           1016   62 Mar  9 17:02 operator4
drwx------. 3 production1 production1      74 Mar  2 15:30 production1
drwx------. 3 student     student         103 Mar  6 21:29 student
[root@rocky2 ~]# useradd -u 1016 operator5
[root@rocky2 ~]# ls -l /home
total 4
drwx------. 4 ansible     ansible         111 Mar  3 04:29 ansible
drwx------. 2 consultant1 consultant1      83 Feb 28 03:16 consultant1
drwx------. 2 consultant2 consultant2      62 Feb 28 01:00 consultant2
drwx------. 2 consultant3 consultant3      62 Feb 28 01:00 consultant3
drwxrwx---. 2 consultant1 consultants      29 Feb 28 03:18 consultants
drwx------. 2 database1   databaseadmins   83 Feb 28 04:00 database1
drwx------. 2 operator1   operator1        83 Feb 28 02:09 operator1
drwx------. 3 operator2   operator2        95 Mar  2 15:16 operator2
drwx------. 2 operator3   operator3        62 Feb 28 00:22 operator3
drwx------. 2 operator5   operator5        62 Mar  9 17:02 operator4
drwx------. 2 operator5   operator5        62 Mar  9 18:04 operator5
drwx------. 3 production1 production1      74 Mar  2 15:30 production1
drwx------. 3 student     student         103 Mar  6 21:29 student
[root@rocky2 ~]# userdel -r operator5
[root@rocky2 ~]# ls -l /home
total 4
drwx------. 4 ansible     ansible         111 Mar  3 04:29 ansible
drwx------. 2 consultant1 consultant1      83 Feb 28 03:16 consultant1
drwx------. 2 consultant2 consultant2      62 Feb 28 01:00 consultant2
drwx------. 2 consultant3 consultant3      62 Feb 28 01:00 consultant3
drwxrwx---. 2 consultant1 consultants      29 Feb 28 03:18 consultants
drwx------. 2 database1   databaseadmins   83 Feb 28 04:00 database1
drwx------. 2 operator1   operator1        83 Feb 28 02:09 operator1
drwx------. 3 operator2   operator2        95 Mar  2 15:16 operator2
drwx------. 2 operator3   operator3        62 Feb 28 00:22 operator3
drwx------. 2        1016           1016   62 Mar  9 17:02 operator4
drwx------. 3 production1 production1      74 Mar  2 15:30 production1
drwx------. 3 student     student         103 Mar  6 21:29 student

```


#### Set Passwords from the Command Line

UID Ranges
Red Hat Enterprise Linux uses specific UID numbers and ranges of numbers for specific purposes.

• UID 0 : The superuser (root) account UID.

• UID 1-200 : System account UIDs statically assigned to system processes.

• UID 201-999 : UIDs assigned to system processes that do not own files on this system. Software that requires an unprivileged UID is dynamically assigned UID from this available pool.

• UID 1000+ : The UID range to assign to regular, unprivileged users.



## Manage Local Group Accounts

### Manage Local Groups



```sh
[root@rocky2 ~]# groupadd -g 10000 group01
[root@rocky2 ~]# tail /etc/group
techdocs:x:35002:tech1,tech2
tech1:x:1010:
tech2:x:1011:
databaseadmins:x:35003:
Students:x:35004:student
student:x:1013:
productions:x:35005:production1
production1:x:1014:
ansible:x:1015:
group01:x:10000:
#system grubu oluşturmak için
[root@rocky2 ~]# groupadd -r group02
[root@rocky2 ~]# tail /etc/group
tech1:x:1010:
tech2:x:1011:
databaseadmins:x:35003:
Students:x:35004:student
student:x:1013:
productions:x:35005:production1
production1:x:1014:
ansible:x:1015:
group01:x:10000:
group02:x:991:

```

#### Change Group Membership from the Command Line


Use the usermod -g command to change a user's primary group.

Use the usermod -aG command to add a user to a secondary group.

```sh
[root@rocky2 ~]# usermod -g group01 operator1
[root@rocky2 ~]# usermod -g group02 operator2
[root@rocky2 ~]# id operator1
uid=1001(operator1) gid=10000(group01) groups=10000(group01),30000(operators),30001(admin)
[root@rocky2 ~]# id operator2
uid=1002(operator2) gid=991(group02) groups=991(group02),30000(operators)
[root@rocky2 ~]# usermod -aG group01 operator2
[root@rocky2 ~]# usermod -aG group02 operator1
[root@rocky2 ~]# id operator2
uid=1002(operator2) gid=991(group02) groups=991(group02),30000(operators),10000(group01)
[root@rocky2 ~]# id operator1
uid=1001(operator1) gid=10000(group01) groups=10000(group01),30000(operators),30001(admin),991(group02)
```


#### Modify Existing Groups from the Command Line

ismini ve gid'sini değiştirme sonra silme.Farklı bir kullanıcı eklenmişse grup direk silinmez

```sh
[root@rocky2 ~]# groupmod -n group0022 group02
[root@rocky2 ~]#  tail /etc/group
tech2:x:1011:
databaseadmins:x:35003:
Students:x:35004:student
student:x:1013:
productions:x:35005:production1
production1:x:1014:
ansible:x:1015:
group01:x:10000:operator2
help:x:35006:
group0022:x:991:operator2,operator1
[root@rocky2 ~]# groupmod -g 20000 group0022
[root@rocky2 ~]#  tail /etc/group
tech2:x:1011:
databaseadmins:x:35003:
Students:x:35004:student
student:x:1013:
productions:x:35005:production1
production1:x:1014:
ansible:x:1015:
group01:x:10000:operator2
help:x:35006:
group0022:x:20000:operator2,operator1
[root@rocky2 ~]# groupdel group0022

```



#### Temporarily Change Your Primary Group



```sh
[root@rocky2 ~]# newgrp group01
[root@rocky2 ~]# newgrp techdocs
[root@rocky2 ~]# id
uid=0(root) gid=35002(techdocs) groups=35002(techdocs),0(root),1002(operator2),10000(group01) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

```









## Manage User Passwords




### Shadow Passwords and Password Policy






```sh
[root@rocky2 ~]# cat /etc/shadow
root:$6$UknubP7XQPz9Ll95$UfcU2vcOZRpzIM3Z8OSZMRyqBJeUaZ2drODB7oyDjUggXUjG9xlpvsbuPxHiUC0en/zHN2CiEwiT6XXPdk5Wj/:19788:0:99999:7:::
bin:*:19469:0:99999:7:::
daemon:*:19469:0:99999:7:::
adm:*:19469:0:99999:7:::
.
.
.
user:$6$0tU2Xl7fGLKl/8xO$zJyBBOzURAu2dvtXNgU9J3fRm/DpVPsY9NRSlol28LtiMFqhRT2QMsVRW55fFiJtKkOYTgFsr2ZbeIfZhoMF20:19780:0:99999:7:::
operator1:$6$I/D2c571vvqpzdzK$7s24s2yC0N7eAim3ZptGR0MbsH3qrnRt/VprEOPoAj4LJn81FOBYvWGPC8dsllQZ4T7WKbcXUXO8zNG8zaVoe.:19784:0:90:7::19241:
operator2:$6$RWrIUmhyNrdnYJH8$lZ4HwIHORqDlQSW7NTc7t3kKmMc9erKUtKQeliBMEunkBPgUhGpmihHm0wiKsrrqhHmlbFso17tXaWPdG9vU.0:19784:0:99999:7:::

```
Each field of this code block is separated by a colon:

• operator1 : Name of the user account.

• $6$CSsXsd3rwghsdfarf : The encrypted password of the user.

• 17933 : The days from the epoch when the password was last changed, where the epoch is 1970-01-01 in the UTC time zone.

• 0 : The minimum days since the last password change before the user can change it again.

• 99999 : The maximum days without a password change before the password expires. An empty field means that the password never expires.

• 7 : The number of days ahead to warn the user that their password will expire.

• 2 : The number of days without activity, starting with the day the password expired, before the account is automatically locked.

• 18113 : The day when the account expires in days since the epoch. An empty field means that the account never expires.

• The last field is typically empty and reserved for future use.


Format of an Encrypted Password

• 6 : The hashing algorithm in use for this password. A 6 indicates a SHA-512 hash, the RHEL 9
default, a 1 indicates MD5, and a 5 indicates SHA-256.

• CSsXcYG1L/4ZfHr/ : The salt in use to encrypt the password; originally chosen at random.

• 2W6evvJahUfzfHpc9X.45Jc6H30E : The encrypted hash of the user's password; combining
the salt and the unencrypted password and then encrypting to generate the password hash.



### Configure Password Aging


The command defines a minimum age (-m) of zero days, a maximum age (-M)
of 90 days, a warning period (-W) of 7 days, and an inactivity period (-I) of 14 days

```sh
[root@rocky2 user]# chage -m 0 -M 90 -W 7 -I 14 sysadmin05

```


The cloudadmin10
user is new in the system and you want to set a custom password aging policy. You want to set the
account expiration 30 days from today, so you use the following commands:

```sh
#Use the date command to get the current date
[root@rocky2 user]# date +%F
2024-03-09
#Use the date command to get the date 30 days from now.
[root@rocky2 user]# date -d "+30 days" +%F
2024-04-09
#Use the chage command -E option to change the expiration date for the cloudadmin10 user.
[root@rocky2 user]# chage -E $(date -d "+30 days" +%F) cloudadmin10
#Use the chage command -l option to display the password aging policy for the cloudadmin10 user.
[root@rocky2 user]# chage -l cloudadmin10 | grep "Account expires"
Account expires                                         : Apr 09, 2024
[root@rocky2 user]# chage -l cloudadmin10
Last password change                                    : Mar 09, 2024
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : Apr 09, 2024
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7


[root@rocky2 user]# chage --help
Usage: chage [options] LOGIN

Options:
  -d, --lastday LAST_DAY        set date of last password change to LAST_DAY
  -E, --expiredate EXPIRE_DATE  set account expiration date to EXPIRE_DATE
  -h, --help                    display this help message and exit
  -i, --iso8601                 use YYYY-MM-DD when printing dates
  -I, --inactive INACTIVE       set password inactive after expiration
                                to INACTIVE
  -l, --list                    show account aging information
  -m, --mindays MIN_DAYS        set minimum number of days before password
                                change to MIN_DAYS
  -M, --maxdays MAX_DAYS        set maximum number of days before password
                                change to MAX_DAYS
  -R, --root CHROOT_DIR         directory to chroot into
  -W, --warndays WARN_DAYS      set expiration warning days to WARN_DAYS

```



```sh
[root@rocky2 user]# vi /etc/login.defs
# Password aging controls:
#
#       PASS_MAX_DAYS   Maximum number of days a password may be used.
#       PASS_MIN_DAYS   Minimum number of days allowed between password changes.
#       PASS_MIN_LEN    Minimum acceptable password length.
#       PASS_WARN_AGE   Number of days warning given before a password expires.
#
PASS_MAX_DAYS   99999
PASS_MIN_DAYS   0
PASS_WARN_AGE   7



#referans alınması gereken manuel sayfaları. Bütün açıklamalar bulunabilir. Standalone parola degisiklikleri
man login.defs
man crypt
man chage



```

### The nologin Shell

shell'e login olmasın isteniyorsa 

```sh
[root@rocky2 user]# usermod -s /sbin/nologin cloudadmin10
[root@rocky2 user]# su cloudadmin10
This account is currently not available.
#sonra geri alınması
[root@rocky2 user]# usermod -s /bin/bash cloudadmin10

```


### Restrict Access


```sh
[root@rocky2 user]# usermod -L cloudadmin10
[cloudadmin10@rocky2 ~]$ su - cloudadmin10
Password:
su: Authentication failure
[root@rocky2 user]# passwd -S cloudadmin10
cloudadmin10 LK 2024-03-09 0 99999 7 -1 (Password locked.)
[root@rocky2 user]# chage -l cloudadmin10
Last password change                                    : Mar 09, 2024
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : Mar 14, 2024
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
```

 the usermod command locks and expires the
cloudadmin10 user at 2024-03-14

```sh
[root@rocky2 user]# usermod -L -e 2024-03-14 cloudadmin10
[root@rocky2 user]# chage -l cloudadmin10
Last password change                                    : Mar 09, 2024
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : Mar 14, 2024
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
[root@rocky2 user]# passwd -S cloudadmin10
cloudadmin10 LK 2024-03-09 0 99999 7 -1 (Password locked.)

```


passwd -S 

PS-->Password Set

LK-->Locked

NP-->No Password


```sh
[root@rocky2 user]# passwd -S operator1
operator1 PS 2024-03-02 0 90 7 -1 (Password set, SHA512 crypt.)
[root@rocky2 user]# passwd -S cloudadmin10
cloudadmin10 LK 2024-03-09 0 99999 7 -1 (Password locked.)
```

