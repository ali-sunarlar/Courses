# Analyze and Store Logs


## Describe System Log Architecture


|  Logs             | Detail                                                                  |
| ----------------- | ----------------------------------------------------------------------- | 
| /var/log/messages | Sistem günlüğü mesajlarının çoğu burada günlüğe kaydedilir. |
| /var/log/secure | Güvenlik ve kimlik doğrulama olaylarıyla ilgili sistem günlüğü mesajları. |
| /var/log/maillog | Posta sunucusuyla ilgili sistem günlüğü mesajları. | 
| /var/log/cron | Görev zamanlayıcı ile ilgili logları tutar. |
| /var/log/boot.log | Sunucunun açılışındaki oluşan logları tutar | 

## Sample Rules of the rsyslog Service


Temel seviyede OS loglama için kullanılır. Toplamak, ayrıştırmak için kullanılır. 

1-Toplamak

2-Depolamak

3-(Kural setlerine göre)Analiz edilmesi için parse edilmesi

4-Gerekli aksiyonların alınması için log'ların yakalanması sağlanır

Overview of Syslog Facilities

Hangi bileşen, Hangi süreç

|Code |  Facility | Facility description |
|-----|-----------|----------------------|
| 0  | kern | Kernel messages|
| 1  | user  | User-level messages |
| 2 | mail | Mail system messages |
| 3 | daemon | System daemons messages |
| 4 | auth | Authentication and security messages |
| 5 | syslog | Internal syslog messages |
| 6 | lpr | Printer messages |
| 7 | news | Network news messages |
| 8 | uucp | UUCP protocol messages |
| 9 | cron | Clock daemon messages |
| 10 | authpriv | Non-system authorization messages |
| 11 | ftp | FTP protocol messages |
| 16-23 | local0 to local7 | Custom local messages |


Overview of Syslog Priorities

| Code | Priority | Priority description |
|------|----------|----------------------|
| 0 | emerg | System is unusable 
| 1 | alert | Action must be taken immediately |
| 2 | crit | Critical condition |
| 3 | err | Non-critical error condition |
| 4 | warning | Warning condition |
| 5 | notice | Normal but significant event |
| 6 | info | Informational event |
| 7 | debug | Debugging-level message |


Hangi path redirect yapıldığı belirtiliyor.

For example, the following line in the /etc/rsyslog.d file would record messages that are sent
to the authpriv facility at any priority to the /var/log/secure file:

```sh
#### RULES ####
.
.
.
authpriv.* /var/log/secure
```

The rsyslog service uses the facility and priority of log messages to determine how to handle
them. Rules configure this facility and priority in the /etc/rsyslog.conf file and in any file in
the /etc/rsyslog.d directory with the .conf extension. Software packages can easily add
rules by installing an appropriate file in the /etc/rsyslog.d directory.

Spesific veya özel tanımlamalar için /etc/rsyslod.d dizini altında tanımlamalar yapılır.

X çıktısı ile gelen logu özel bir path'e yönlendirmek için kullanılır.


```sh
[root@host ~]# vi /etc/rsyslog.conf

#### RULES ####
# Log all kernel messages to the console.
# Logging much else clutters up the screen.
#kern.* /dev/console
# Log anything (except mail) of level info or higher.
# Don't log private authentication messages!
*.info;mail.none;authpriv.none;cron.none /var/log/messages
# The authpriv file has restricted access.
authpriv.* /var/log/secure
# Log all the mail messages in one place.
mail.* -/var/log/maillog
# Log cron stuff
cron.* /var/log/cron
# Everybody gets emergency messages
.emerg :omusrmsg:
# Save news errors of level crit and higher in a special file.
uucp,news.crit /var/log/spooler
# Save boot messages also to boot.log
local7.* 
```

## Log File Rotation

Logrotate komutu, çok fazla yer almasını önlemek için günlük dosyalarını döndürür
/var /log dizininde. Bir günlük dosyası döndürüldüğünde, bir uzantı ile yeniden adlandırılır.
Rotasyon tarihini gösterir.

For example, the old /var/log/messages file is renamed to the
/var/log/messages-20220320 file when it is rotated on 2022-03-20. After the old log file
rotates, it creates a log file and notifies the service that wrote the log file.

Tipik olarak dört hafta boyunca rotasyonlardan sonra, en eski günlük dosyası serbest disk alanına atılır. A
Planlanan Job, herhangi bir günlüğün rotasyon gereksinimini görmek için günlük Logrotate komutunu çalıştırır
dosyalar. Çoğu günlük dosyası haftalık olarak döner; Logrotate komutu, bazı günlük dosyalarını daha hızlı veya daha fazla döndürür
yavaşça veya belirli bir boyuta ulaştıklarında.





```sh
[root@host ~]# vi /etc/rsyslog.conf
Append 
*.*@@logforwardingip:port // Bu tüm configleri yönlendirir.
mail.*@@logforwardingip:port // sadece mail loglarını yönlendirir.
```

## Analyze a Syslog Entry

```sh
Mar 20 20:11:48 localhost sshd[1433]: Failed password for student from 172.25.0.10
 port 59344 ssh2
```

• Mar 20 20:11:48 : Records the time stamp of the log entry.
• localhost : The host that sends the log message.
• sshd[1433] : The program or process name and PID number that sent the log message.
• Failed password for … : The message that was sent.







## Monitor Log Events

```sh
[root@host ~]# tail -f /var/log/secure

...output omitted...
Mar 20 09:01:13 host sshd[2712]: Accepted password for root from 172.25.254.254
 port 56801 ssh2
Mar 20 09:01:13 host sshd[2712]: pam_unix(sshd:session): session opened for user
 root by (uid=0)
```



## Send Syslog Messages Manually

To send a message to the rsyslog service to be recorded in the /var/log/boot.log log file,
execute the following logger command:

```sh
[root@host ~]# logger -p local7.notice "Log entry created on host"
```




# Review System Journal Entries


## Find Events on the System Journal


To retrieve log messages from the journal, use the journalctl command. You can use the
journalctl command to view all messages in the journal, or to search for specific events based
on a wide range of options and criteria. If you run the command as root, then you have full access
to the journal. Regular users can also use the journalctl command, but the system restricts
them from seeing certain messages.

OS loglarının biraz daha net bir şekilde yakalanması sağlanır.

```sh
[root@rocky2 ~]# systemctl status systemd-journald
● systemd-journald.service - Journal Service
     Loaded: loaded (/usr/lib/systemd/system/systemd-journald.service; static)
     Active: active (running) since Thu 2024-08-08 16:15:31 +03; 9h ago
TriggeredBy: ● systemd-journald.socket
             ● systemd-journald-dev-log.socket
       Docs: man:systemd-journald.service(8)
             man:journald.conf(5)
   Main PID: 590 (systemd-journal)
     Status: "Processing requests..."
      Tasks: 1 (limit: 4464)
     Memory: 3.7M
        CPU: 1.563s
     CGroup: /system.slice/systemd-journald.service
             └─590 /usr/lib/systemd/systemd-journald

Aug 08 16:15:31 rocky2 systemd-journald[590]: Journal started
Aug 08 16:15:31 rocky2 systemd-journald[590]: Runtime Journal (/run/log/journal/8b3a215cf9234757a8421b807409fcc1) is 2.4M, max 14.7M, 12.2M free.
● systemd-journald.service - Journal Service
     Loaded: loaded (/usr/lib/systemd/system/systemd-journald.service; static)
     Active: active (running) since Thu 2024-08-08 16:15:31 +03; 9h ago
```


```sh
[root@host ~]# journalctl
...output omitted...
Mar 15 04:42:16 host.lab.example.com systemd[2127]: Listening on PipeWire
 Multimedia System Socket.
Mar 15 04:42:16 host.lab.example.com systemd[2127]: Starting Create User's
 Volatile Files and Directories...
Mar 15 04:42:16 host.lab.example.com systemd[2127]: Listening on D-Bus User
 Message Bus Socket.
Mar 15 04:42:16 host.lab.example.com systemd[2127]: Reached target Sockets.
Mar 15 04:42:16 host.lab.example.com systemd[2127]: Finished Create User's
 Volatile Files and Directories.
Mar 15 04:42:16 host.lab.example.com systemd[2127]: Reached target Basic System.
Mar 15 04:42:16 host.lab.example.com systemd[1]: Started User Manager for UID 0.
Mar 15 04:42:16 host.lab.example.com systemd[2127]: Reached target Main User
 Target.
```

En son 5 log

```sh
[root@host ~]# journalctl -n 5
Mar 15 04:42:17 host.lab.example.com systemd[1]: Started Hostname Service.
Mar 15 04:42:47 host.lab.example.com systemd[1]: systemd-hostnamed.service:
 Deactivated successfully.
Mar 15 04:47:33 host.lab.example.com systemd[2127]: Created slice User Background
 Tasks Slice.
Mar 15 04:47:33 host.lab.example.com systemd[2127]: Starting Cleanup of User's
 Temporary Files and Directories...
Mar 15 04:47:33 host.lab.example.com systemd[2127]: Finished Cleanup of User's
 Temporary Files and Directories.
```

Tail komutuna benzer şekilde, Journalctl komutu -f seçeneği sistem günlüğünün son 10 satırını çıktı olarak verir ve günlük girdilerini ekledikçe yeni günlük girişlerinin çıktısını almaya devam eder. Journalctl komutu -f seçeneğinden çıkmak için Ctrl+C tuş birleşimini kullanın.

canlı izlemek için

```sh
[root@host ~]# journalctl -f
Mar 15 04:47:33 host.lab.example.com systemd[2127]: Finished Cleanup of User's
 Temporary Files and Directories.
Mar 15 05:01:01 host.lab.example.com CROND[2197]: (root) CMD (run-parts /etc/
cron.hourly)
Mar 15 05:01:01 host.lab.example.com run-parts[2200]: (/etc/cron.hourly) starting
 0anacron
Mar 15 05:01:01 host.lab.example.com anacron[2208]: Anacron started on 2022-03-15
Mar 15 05:01:01 host.lab.example.com anacron[2208]: Will run job `cron.daily' in
 29 min.
Mar 15 05:01:01 host.lab.example.com anacron[2208]: Will run job `cron.weekly' in
 49 min.
Mar 15 05:01:01 host.lab.example.com anacron[2208]: Will run job `cron.monthly' in
 69 min.
```

Priotity bazlı arama

```sh
[root@host ~]# journalctl -p err
Mar 15 04:22:00 host.lab.example.com pipewire-pulse[1640]: pw.conf: execvp error
 'pactl': No such file or direct
Mar 15 04:22:17 host.lab.example.com kernel: Detected CPU family 6 model 13
 stepping 3
Mar 15 04:22:17 host.lab.example.com kernel: Warning: Intel Processor - this
 hardware has not undergone testing by Red Hat and might not be certif>
Mar 15 04:22:20 host.lab.example.com smartd[669]: DEVICESCAN failed: glob(3)
 aborted matching pattern /dev/discs/disc*
```


specific service belirtilebilir

```sh
 [root@host ~]# journalctl -u sshd.service
May 15 04:30:18 host.lab.example.com systemd[1]: Starting OpenSSH server daemon...
May 15 04:30:18 host.lab.example.com sshd[1142]: Server listening on 0.0.0.0 port
 22.
May 15 04:30:18 host.lab.example.com sshd[1142]: Server listening on :: port 22.
May 15 04:30:18 host.lab.example.com systemd[1]: Started OpenSSH server daemon.
May 15 04:32:03 host.lab.example.com sshd[1796]: Accepted publickey for user1 from
 172.25.250.254 port 43876 ssh2: RSA SHA256:1UGy...>
May 15 04:32:03 host.lab.example.com sshd[1796]: pam_unix(sshd:session): session
 opened for user user1(uid=1000) by (uid=0)
```

zaman belirtilebilir.

```sh
[root@host ~]# journalctl --since today
...output omitted...
Mar 15 05:04:20 host.lab.example.com systemd[1]: Started Session 8 of User
 student.
Mar 15 05:04:20 host.lab.example.com sshd[2255]: pam_unix(sshd:session): session
 opened for user student(uid=1000) by (uid=0)
Mar 15 05:04:20 host.lab.example.com systemd[1]: Starting Hostname Service...
```

```sh
[root@host ~]# journalctl --since "2022-03-11 20:30" --until "2022-03-14 10:00"
...output omitted...
```

En son bir saat

```sh
[root@host ~]# journalctl --since "-1 hour"
 ```

The verbose output is useful to reduce the output of complex searches for certain events in the
journal.

```sh
[root@host ~]# journalctl -o verbose
Tue 2022-03-15 05:10:32.625470 EDT [s=e7623387430b4c14b2c71917db58e0ee;i...]
 _BOOT_ID=beaadd6e5c5448e393ce716cd76229d4
 _MACHINE_ID=4ec03abd2f7b40118b1b357f479b3112
 PRIORITY=6
 SYSLOG_FACILITY=3
 SYSLOG_IDENTIFIER=systemd
 _UID=0
 _GID=0
 _TRANSPORT=journal
 _CAP_EFFECTIVE=1ffffffffff
 TID=1
 CODE_FILE=src/core/job.c
 CODE_LINE=744
 CODE_FUNC=job_emit_done_message
 JOB_RESULT=done
 _PID=1
 _COMM=systemd
 _EXE=/usr/lib/systemd/systemd
 _SYSTEMD_CGROUP=/init.scope
 _SYSTEMD_UNIT=init.scope
 _SYSTEMD_SLICE=-.slice
 JOB_TYPE=stop
 MESSAGE_ID=9d1aaa27d60140bd96365438aad20286
 _HOSTNAME=host.lab.example.com
 _CMDLINE=/usr/lib/systemd/systemd --switched-root --system --deserialize 31
 _SELINUX_CONTEXT=system_u:system_r:init_t:s0
 UNIT=user-1000.slice
 MESSAGE=Removed slice User Slice of UID 1000.
 INVOCATION_ID=0e5efc1b4a6d41198f0cf02116ca8aa8
 JOB_ID=3220
 _SOURCE_REALTIME_TIMESTAMP=1647335432625470
lines 46560-46607/46607 (END) q
```

• _COMM is the command name.

• _EXE is the path to the executable file for the process.

• _PID is the PID of the process.

• _UID is the UID of the user that runs the process.

• _SYSTEMD_UNIT is the systemd unit that started the process.


```sh
[root@host ~]# journalctl _SYSTEMD_UNIT=sshd.service _PID=2110
Mar 15 04:42:16 host.lab.example.com sshd[2110]: Accepted
 publickey for root from 172.25.250.254 port 46224 ssh2: RSA
 SHA256:1UGybTe52L2jzEJa1HLVKn9QUCKrTv3ZzxnMJol1Fro
Mar 15 04:42:16 host.lab.example.com sshd[2110]: pam_unix(sshd:session): session
 opened for user root(uid=0) by (uid=0)
```

```sh
[root@rocky2 ~]# man systemd.journal-fields

SYSTEMD.JOURNAL-FIELDS(7)                                           systemd.journal-fields                                          SYSTEMD.JOURNAL-FIELDS(7)

NAME
       systemd.journal-fields - Special journal fields

DESCRIPTION
       Entries in the journal (as written by systemd-journald.service(8)) resemble a UNIX process environment block in syntax but with fields that may
       include binary data. Primarily, fields are formatted UTF-8 text strings, and binary encoding is used only where formatting as UTF-8 text strings makes     
       little sense. New fields may freely be defined by applications, but a few fields have special meanings. All fields with special meanings are optional.     
       In some cases, fields may appear more than once per entry.

USER JOURNAL FIELDS
       User fields are fields that are directly passed from clients and stored in the journal.

       MESSAGE=
           The human-readable message string for this entry. This is supposed to be the primary text shown to the user. It is usually not translated (but
           might be in some cases), and is not supposed to be parsed for metadata.

       MESSAGE_ID=
           A 128-bit message identifier ID for recognizing certain message types, if this is desirable. This should contain a 128-bit ID formatted as a
           lower-case hexadecimal string, without any separating dashes or suchlike. This is recommended to be a UUID-compatible ID, but this is not
           enforced, and formatted differently. Developers can generate a new ID for this purpose with systemd-id128 new.

       PRIORITY=A priority value between 0 ("emerg") and 7 ("debug") formatted as a decimal string. This field is compatible with syslog's priority concept.

       CODE_FILE=, CODE_LINE=, CODE_FUNC=
           The code location generating this message, if known. Contains the source filename, the line number and the function name.

       ERRNO=
           The low-level Unix error number causing this entry, if any. Contains the numeric value of errno(3) formatted as a decimal string.

       INVOCATION_ID=, USER_INVOCATION_ID=
           A randomized, unique 128-bit ID identifying each runtime cycle of the unit. This is different from _SYSTEMD_INVOCATION_ID in that it is only used      
           for messages coming from systemd code (e.g. logs from the system/user manager or from forked processes performing systemd-related setup).

       SYSLOG_FACILITY=, SYSLOG_IDENTIFIER=, SYSLOG_PID=, SYSLOG_TIMESTAMP=
           Syslog compatibility fields containing the facility (formatted as decimal string), the identifier string (i.e. "tag"), the client PID, and the
           timestamp as specified in the original datagram. (Note that the tag is usually derived from glibc's program_invocation_short_name variable, see        
           program_invocation_short_name(3).)

           Note that the journal service does not validate the values of any structured journal fields whose name is not prefixed with an underscore, and
           this includes any syslog related fields such as these. Hence, applications that supply a facility, PID, or log level are expected to do so
           properly formatted, i.e. as numeric integers formatted as decimal strings.

       SYSLOG_RAW=
           The original contents of the syslog line as received in the syslog datagram. This field is only included if the MESSAGE= field was modified
           compared to the original payload or the timestamp could not be located properly and is not included in SYSLOG_TIMESTAMP=. Message truncation
           occurs when the message contains leading or trailing whitespace (trailing and leading whitespace is stripped), or it contains an embedded NUL byte     
           (the NUL byte and anything after it is not included). Thus, the original syslog line is either stored as SYSLOG_RAW= or it can be recreated based      
           on the stored priority and facility, timestamp, identifier, and the message payload in MESSAGE=.

       DOCUMENTATION=
           A documentation URL with further information about the topic of the log message. Tools such as journalctl will include a hyperlink to an URL
           specified this way in their output. Should be an "http://", "https://", "file:/", "man:" or "info:" URL.

       TID=
           The numeric thread ID (TID) the log message originates from.

       UNIT=, USER_UNIT=
           The name of a unit. Used by the system and user managers when logging about specific units.

           When --unit=name or --user-unit=name are used with journalctl(1), a match pattern that includes "UNIT=name.service" or "USER_UNIT=name.service"        
           will be generated.

TRUSTED JOURNAL FIELDS
       Fields prefixed with an underscore are trusted fields, i.e. fields that are implicitly added by the journal and cannot be altered by client code.

       _PID=, _UID=, _GID=
           The process, user, and group ID of the process the journal entry originates from formatted as a decimal string. Note that entries obtained via
           "stdout" or "stderr" of forked processes will contain credentials valid for a parent process (that initiated the connection to systemd-journald).      

       _COMM=, _EXE=, _CMDLINE=
           The name, the executable path, and the command line of the process the journal entry originates from.

       _CAP_EFFECTIVE=
           The effective capabilities(7) of the process the journal entry originates from.
       _AUDIT_SESSION=, _AUDIT_LOGINUID=
           The session and login UID of the process the journal entry originates from, as maintained by the kernel audit subsystem.

       _SYSTEMD_CGROUP=, _SYSTEMD_SLICE=, _SYSTEMD_UNIT=, _SYSTEMD_USER_UNIT=, _SYSTEMD_USER_SLICE=, _SYSTEMD_SESSION=, _SYSTEMD_OWNER_UID=
           The control group path in the systemd hierarchy, the systemd slice unit name, the systemd unit name, the unit name in the systemd user manager (if
           any), the systemd session ID (if any), and the owner UID of the systemd user unit or systemd session (if any) of the process the journal entry
           originates from.

       _SELINUX_CONTEXT=
           The SELinux security context (label) of the process the journal entry originates from.

       _SOURCE_REALTIME_TIMESTAMP=
           The earliest trusted timestamp of the message, if any is known that is different from the reception time of the journal. This is the time in
           microseconds since the epoch UTC, formatted as a decimal string.

       _BOOT_ID=
           The kernel boot ID for the boot the message was generated in, formatted as a 128-bit hexadecimal string.

       _MACHINE_ID=
           The machine ID of the originating host, as available in machine-id(5).

       _SYSTEMD_INVOCATION_ID=
           The invocation ID for the runtime cycle of the unit the message was generated in, as available to processes of the unit in $INVOCATION_ID (see
           systemd.exec(5)).

       _HOSTNAME=
           The name of the originating host.

       _TRANSPORT=
           How the entry was received by the journal service. Valid transports are:

           audit
               for those read from the kernel audit subsystem

           driver
               for internally generated messages    
    .
    .
    .
```


```sh
[root@rocky2 ~]# dmesg
.
.
.
[   23.438152] SGI XFS with ACLs, security attributes, scrub, quota, no debug enabled
[   23.454301] XFS (dm-0): Mounting V5 Filesystem 59c964d2-18fa-4d5c-9c26-ffd5c4b7dba9
[   23.591434] XFS (dm-0): Ending clean mount
[   24.285731] systemd-journald[254]: Received SIGTERM from PID 1 (systemd).
[   24.527536] audit: type=1404 audit(1723122928.162:2): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295 enabled=1 old-enabled=1 lsm=selinux res=1
[   24.614082] SELinux:  policy capability network_peer_controls=1
[   24.614086] SELinux:  policy capability open_perms=1
[   24.614087] SELinux:  policy capability extended_socket_class=1
[   24.614088] SELinux:  policy capability always_check_network=0
[   24.614089] SELinux:  policy capability cgroup_seclabel=1
[   24.614089] SELinux:  policy capability nnp_nosuid_transition=1
[   24.614090] SELinux:  policy capability genfs_seclabel_symlinks=1
[   24.693814] audit: type=1403 audit(1723122928.329:3): auid=4294967295 ses=4294967295 lsm=selinux res=1
[   24.704736] systemd[1]: Successfully loaded SELinux policy in 178.461ms.
[   24.869535] systemd[1]: Relabelled /dev, /dev/shm, /run, /sys/fs/cgroup in 99.365ms
.
.
.
```

## Preserve the System Journal

System Journal Storage

You can change the configuration settings
of the systemd-journald service in the /etc/systemd/journald.conf file so that the
journals persist across a reboot.

The Storage parameter in the /etc/systemd/journald.conf file defines whether to
store system journals in a volatile manner or persistently across a reboot. Set this parameter to
persistent, volatile, auto, or none as follows:

• persistent: Stores journals in the /var/log/journal directory, which persists across
reboots. If the /var/log/journal directory does not exist, then the systemd-journald
service creates it.

• volatile: Stores journals in the volatile /run/log/journal directory. As the /run file
system is temporary and exists only in the runtime memory, the data in it, including system
journals, does not persist across a reboot.

• auto: If the /var/log/journal directory exists, then the systemd-journald service uses
persistent storage; otherwise it uses volatile storage. This action is the default if you do not set
the Storage parameter.

• none: Do not use any storage. The system drops all logs, but you can still forward the logs.


```sh
[user@host ~]$ journalctl | grep -E 'Runtime Journal|System Journal'
Mar 15 04:21:14 localhost systemd-journald[226]: Runtime Journal (/run/log/
journal/4ec03abd2f7b40118b1b357f479b3112) is 8.0M, max 113.3M, 105.3M free.
Mar 15 04:21:19 host.lab.example.com systemd-journald[719]: Runtime Journal (/run/
log/journal/4ec03abd2f7b40118b1b357f479b3112) is 8.0M, max 113.3M, 105.3M free.
Mar 15 04:21:19 host.lab.example.com systemd-journald[719]: System Journal (/run/
log/journal/4ec03abd2f7b40118b1b357f479b3112) is 8.0M, max 4.0G, 4.0G free.

```

Configure Persistent System Journals

To configure the systemd-journald service to preserve system journals persistently across
a reboot, set the Storage parameter to the persistent value in the /etc/systemd/
journald.conf file. Run your chosen text editor as the superuser to edit the /etc/systemd/
journald.conf file.

Log toplama, saklama, rotasyonlar(Otomatikleştirme için)



```sh
[root@rocky2 ~]# cat /etc/systemd/journald.conf
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it under the
#  terms of the GNU Lesser General Public License as published by the Free
#  Software Foundation; either version 2.1 of the License, or (at your option)
#  any later version.
#
# Entries in this file show the compile time defaults. Local configuration
# should be created by either modifying this file, or by creating "drop-ins" in
# the journald.conf.d/ subdirectory. The latter is generally recommended.
# Defaults can be restored by simply deleting this file and all drop-ins.
#
# Use 'systemd-analyze cat-config systemd/journald.conf' to display the full config.
#
# See journald.conf(5) for details.

[Journal]
#auto --> otomatik olarak saklanır, silinir
#none --> OS kapanıp açıldığında sıfırlanır
#persistent --> log'ları kalıcı olarak saklar log boyutları aşsa bile
#Storage=auto
#Compress=yes
#Seal=yes
#SplitMode=uid
#SyncIntervalSec=5m
#RateLimitIntervalSec=30s
#RateLimitBurst=10000
#SystemMaxUse=
#SystemKeepFree=
#SystemMaxFileSize=
#SystemMaxFiles=100
#RuntimeMaxUse=
#RuntimeKeepFree=
#RuntimeMaxFileSize=
#RuntimeMaxFiles=100
#MaxRetentionSec=
#MaxFileSec=1month
#ForwardToSyslog=no
#ForwardToKMsg=no
#ForwardToConsole=no
#ForwardToWall=yes
#TTYPath=/dev/console
#MaxLevelStore=debug
#MaxLevelSyslog=debug
#MaxLevelKMsg=notice
#MaxLevelConsole=info
#MaxLevelWall=emerg
#LineMax=48K
#ReadKMsg=yes
Audit=
```

Restart the systemd-journald service to apply the configuration changes.

```sh
[root@host ~]# systemctl restart systemd-journald
```

If the systemd-journald service successfully restarts, then the service creates the
/var/log/journal directory and it contains one or more subdirectories. These subdirectories
have hexadecimal characters in their long names and contain files with the .journal extension.
The .journal binary files store the structured and indexed journal entries.

```sh
[root@host ~]# ls /var/log/journal
4ec03abd2f7b40118b1b357f479b3112
[root@host ~]# ls /var/log/journal/4ec03abd2f7b40118b1b357f479b3112
system.journal user-1000.journal
```

To limit the output to
a specific system boot, use the journalctl command -b option. The following journalctl
command retrieves the entries from the first system boot only:

```sh
[root@host ~]# journalctl -b 1
...output omitted...

[root@host ~]# journalctl -b 2
...output omitted...
```

You can list the system boot events that the journalctl command recognizes by using the
--list-boots option.

```sh
[root@rocky2 ~]# journalctl --list-boots
IDX BOOT ID                          FIRST ENTRY                 LAST ENTRY
  0 a49ad790b90f4abc98e8133743e10c30 Thu 2024-08-08 16:15:15 +03 Fri 2024-08-09 02:56:28 +03



[root@host ~]# journalctl --list-boots
 -6 27de... Wed 2022-04-13 20:04:32 EDT—Wed 2022-04-13 21:09:36 EDT
 -5 6a18... Tue 2022-04-26 08:32:22 EDT—Thu 2022-04-28 16:02:33 EDT
 -4 e2d7... Thu 2022-04-28 16:02:46 EDT—Fri 2022-05-06 20:59:29 EDT
 -3 45c3... Sat 2022-05-07 11:19:47 EDT—Sat 2022-05-07 11:53:32 EDT
 -2 dfae... Sat 2022-05-07 13:11:13 EDT—Sat 2022-05-07 13:27:26 EDT
 -1 e754... Sat 2022-05-07 13:58:08 EDT—Sat 2022-05-07 14:10:53 EDT
 0 ee2c... Mon 2022-05-09 09:56:45 EDT—Mon 2022-05-09 12:57:21 EDT
```

The following journalctl command retrieves the entries from the current system boot only:

```sh
[root@host ~]# journalctl -b
[root@rocky2 ~]# journalctl -b
Aug 08 16:15:15 rocky1 kernel: Linux version 5.14.0-427.18.1.el9_4.x86_64 (mockbuild@iad1-prod-build001.bld.equ.rockylinux.org) (gcc (GCC) 11.4.1 20231218 (Red H>
Aug 08 16:15:15 rocky1 kernel: The list of certified hardware and cloud instances for Enterprise Linux 9 can be viewed at the Red Hat Ecosystem Catalog, https://>
Aug 08 16:15:15 rocky1 kernel: Command line: BOOT_IMAGE=(hd0,msdos1)/vmlinuz-5.14.0-427.18.1.el9_4.x86_64 root=/dev/mapper/rl-root ro crashkernel=1G-4G:192M,4G-6>
Aug 08 16:15:15 rocky1 kernel: x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
Aug 08 16:15:15 rocky1 kernel: x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
Aug 08 16:15:15 rocky1 kernel: x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
Aug 08 16:15:15 rocky1 kernel: x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
Aug 08 16:15:15 rocky1 kernel: x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'compacted' format.
Aug 08 16:15:15 rocky1 kernel: signal: max sigframe size: 1776
Aug 08 16:15:15 rocky1 kernel: BIOS-provided physical RAM map:
Aug 08 16:15:15 rocky1 kernel: BIOS-e820: [mem 0x0000000000000000-0x0000000000098bff] usable
Aug 08 16:15:15 rocky1 kernel: BIOS-e820: [mem 0x0000000000098c00-0x000000000009ffff] reserved
Aug 08 16:15:15 rocky1 kernel: BIOS-e820: [mem 0x00000000000dc000-0x00000000000fffff] reserved
Aug 08 16:15:15 rocky1 kernel: BIOS-e820: [mem 0x0000000000100000-0x000000003fedffff] usable
Aug 08 16:15:15 rocky1 kernel: BIOS-e820: [mem 0x000000003fee0000-0x000000003fefefff] ACPI data
Aug 08 16:15:15 rocky1 kernel: BIOS-e820: [mem 0x000000003feff000-0x000000003fefffff] ACPI NVS
Aug 08 16:15:15 rocky1 kernel: BIOS-e820: [mem 0x000000003ff00000-0x000000003fffffff] usable
Aug 08 16:15:15 rocky1 kernel: BIOS-e820: [mem 0x00000000f0000000-0x00000000f7ffffff] reserved
```



# Maintain Accurate Time


## Administer Local Clocks and Time Zones

The timedatectl command shows an overview of the current time-related system settings,
including the current time, time zone, and NTP synchronization settings of the system.


```sh
[user@host ~]$ timedatectl
 Local time: Wed 2022-03-16 05:53:05 EDT
 Universal time: Wed 2022-03-16 09:53:05 UTC
 RTC time: Wed 2022-03-16 09:53:05
 Time zone: America/New_York (EDT, -0400)
System clock synchronized: yes
 NTP service: active
 RTC in local TZ: no
```

You can list a database of time zones with the timedatectl command list-timezones
option.

```sh
[user@host ~]$ timedatectl list-timezones
Africa/Abidjan
Africa/Accra
Africa/Addis_Ababa
Africa/Algiers
Africa/Asmara
Africa/Bamako
```

the following timedatectl
command updates the current time zone to America/Phoenix.


```sh
[root@host ~]# timedatectl set-timezone America/Phoenix
[root@host ~]# timedatectl
 Local time: Wed 2022-03-16 03:05:55 MST
 Universal time: Wed 2022-03-16 10:05:55 UTC
 RTC time: Wed 2022-03-16 10:05:55
 Time zone: America/Phoenix (MST, -0700)
System clock synchronized: yes
 NTP service: active
 RTC in local TZ: no
```

Universal time değiştirme

```sh
[root@rocky2 ~]# timedatectl
               Local time: Fri 2024-08-09 05:47:21 +03
           Universal time: Fri 2024-08-09 02:47:21 UTC
                 RTC time: Sun 2024-08-11 02:25:46
                Time zone: Europe/Istanbul (+03, +0300)
System clock synchronized: no
              NTP service: active
          RTC in local TZ: no
```

```sh
[root@rocky2 ~]# timedatectl set-local-rtc 1

[root@rocky2 ~]# timedatectl
               Local time: Fri 2024-08-09 05:55:43 +03
           Universal time: Fri 2024-08-09 02:55:43 UTC
                 RTC time: Fri 2024-08-09 05:55:34
                Time zone: Europe/Istanbul (+03, +0300)
System clock synchronized: no
              NTP service: active
          RTC in local TZ: yes

Warning: The system is configured to read the RTC time in the local time zone.
         This mode cannot be fully supported. It will create various problems
         with time zone changes and daylight saving time adjustments. The RTC
         time is never updated, it relies on external facilities to maintain it.
         If at all possible, use RTC in UTC by calling
         'timedatectl set-local-rtc 0'.

[root@rocky2 ~]# timedatectl set-local-rtc 0
[root@rocky2 ~]# timedatectl
               Local time: Fri 2024-08-09 05:56:08 +03
           Universal time: Fri 2024-08-09 02:56:08 UTC
                 RTC time: Fri 2024-08-09 02:56:08
                Time zone: Europe/Istanbul (+03, +0300)
System clock synchronized: no
              NTP service: active
          RTC in local TZ: no

[root@rocky2 ~]# timedatectl set-local-rtc 1 --adjust-system-clock
[root@rocky2 ~]# timedatectl
               Local time: Fri 2024-08-09 02:56:51 +03
           Universal time: Thu 2024-08-08 23:56:51 UTC
                 RTC time: Fri 2024-08-09 02:56:51
                Time zone: Europe/Istanbul (+03, +0300)
System clock synchronized: no
              NTP service: active
          RTC in local TZ: yes

Warning: The system is configured to read the RTC time in the local time zone.
         This mode cannot be fully supported. It will create various problems
         with time zone changes and daylight saving time adjustments. The RTC
         time is never updated, it relies on external facilities to maintain it.
         If at all possible, use RTC in UTC by calling
         'timedatectl set-local-rtc 0'.
```


Use the timedatectl command set-time option to change the system's current time. You
might specify the time in the "YYYY-MM-DD hh:mm:ss" format, where you can omit either the
date or time. For example, the following timedatectl command changes the time to 09:00:00.

```sh
[root@host ~]# timedatectl set-time 9:00:00
[root@host ~]# timedatectl
 Local time: Fri 2019-04-05 09:00:27 MST
 Universal time: Fri 2019-04-05 16:00:27 UTC
 RTC time: Fri 2019-04-05 16:00:27
 Time zone: America/Phoenix (MST, -0700)
System clock synchronized: yes
 NTP service: active
 RTC in local TZ: no
```

The timedatectl command set-ntp option enables or disables NTP synchronization for
automatic time adjustment. The option requires either a true or false argument to turn it on or
off. For example, the following timedatectl command turns off NTP synchronization.

```sh
[root@host ~]# timedatectl set-ntp false
```

# Configure and Monitor the chronyd Service

As an example, with the following server classroom.example.com iburst
line in the /etc/chrony.conf configuration file, the chronyd service uses the
classroom.example.com server as the NTP time source.

```sh
# Use public servers from the pool.ntp.org project.
...output omitted...
server classroom.example.com iburst
...output omitted...
```

Restart the service after pointing the chronyd service to the classroom.example.com local
time source

```sh
[root@host ~]# systemctl restart chronyd
```

Birden fazla ntp pool tanımlanabilir.

```sh
[root@host ~]# chronyc sources -v
 .-- Source mode '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current best, '+' = combined, '-' = not combined,
| / 'x' = may be in error, '~' = too variable, '?' = unusable.
|| .- xxxx [ yyyy ] +/- zzzz
|| Reachability register (octal) -. | xxxx = adjusted offset,
|| Log2(Polling interval) --. | | yyyy = measured offset,
|| \ | | zzzz = estimated error.
|| | | \
MS Name/IP address Stratum Poll Reach LastRx Last sample
===============================================================================
^* 172.25.254.254 3 6 17 26 +2957ns[+2244ns] +/- 25ms


[root@rocky2 ~]# chronyc sources -v

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current best, '+' = combined, '-' = not combined,
| /             'x' = may be in error, '~' = too variable, '?' = unusable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* ntp.linuxevi.org              2  10   377   317  +1423us[+1137us] +/-   35ms
^- unn-45-136-155-37.datapa>     3  10   377   186    -18ms[  -18ms] +/-  204ms
^+ ntp2.home4u.ch                1  10   377   759  -2228us[-2509us] +/-   49ms
^+ ntp.cbu.edu.tr                2  10   377   276   +721us[ +721us] +/-   98ms
```

/etc/chrony.conf içerisinden yapılır.


LAB 358 --> 360
LAB 371 --> 374