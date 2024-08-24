# Schedule a Deferred User Job



## Describe Deferred User Tasks

1-kullanıcının kendi yapacagi islemler

2-zamanlama planlama

3-arka planda aksiyonlar

4-kullanici hemen hemen butun islemi yapilabilir


OS kapanıp açıldığından bütün job'lar silinir


Uer job

```sh
[user@host ~]$ date
Wed May 18 21:01:18 CDT 2022
[user@host ~]$ at 21:03 < myscript
job 3 at Wed May 18 21:03:00 2022
[user@host ~]$ at 21:00 < myscript
job 4 at Thu May 19 21:00:00 2022

[user@host ~]$ atq
28 Mon May 16 05:13:00 2022 a user
29 Tue May 17 16:00:00 2022 h user
30 Wed May 18 12:00:00 2022 a user
```

The man pages for the at command and other documentation sources use lowercase to write
the natural time specifications, but you can use lowercase, sentence case, or uppercase. Here are
examples of time specifications you can use

• now +5min

• teatime tomorrow (teatime is 16:00)

• noon +4 days

• 5pm august 3 2021


```sh
[root@rocky2 ~]# at teatime tomorrow < myscript
warning: commands will be executed using /bin/sh
job 3 at Thu Aug 15 16:00:00 2024
[root@rocky2 ~]# atq
1       Wed Aug 14 21:03:00 2024 a root
3       Thu Aug 15 16:00:00 2024 a root
```

```sh
[root@rocky2 ~]# at noon +4 days < myscript
warning: commands will be executed using /bin/sh
job 4 at Sun Aug 18 12:00:00 2024
[root@rocky2 ~]# atq
1       Wed Aug 14 21:03:00 2024 a root
3       Thu Aug 15 16:00:00 2024 a root
4       Sun Aug 18 12:00:00 2024 a root
```

## Inspect and Manage Deferred User Jobs

For an overview of the pending jobs for the current user, use the atq or the at -l command

```sh
[user@host ~]$ atq
28 Mon May 16 05:13:00 2022 a user
29 Tue May 17 16:00:00 2022 h user
30 Wed May 18 12:00:00 2022 a user
```

In the preceding output, every line represents a different scheduled future job. The following
description applies to the first line of the output

• 28 is the unique job number.

• Mon May 16 05:13:00 2022 is the execution date and time for the scheduled job.

• a indicates that the job is scheduled with the default queue a.

• user is the owner of the job (and the user that the job runs as).


Use the at -c JOBNUMBER command to inspect the commands that run when the atd
daemon executes a job. This command shows the job's environment, which is set from the user's
environment when they created the job, and the command syntax to be run

job'ın ne işlem yapacağını ve config görüntülemek icin

```sh
[root@rocky2 ~]# at -c 3
#!/bin/sh
# atrun uid=0 gid=0
# mail root 0
umask 22
SHELL=/bin/bash; export SHELL
HISTCONTROL=ignoredups; export HISTCONTROL
HISTSIZE=1000; export HISTSIZE
HOSTNAME=rocky2; export HOSTNAME
PWD=/root; export PWD
LOGNAME=root; export LOGNAME
XDG_SESSION_TYPE=tty; export XDG_SESSION_TYPE
MOTD_SHOWN=pam; export MOTD_SHOWN
HOME=/root; export HOME
LANG=en_US.UTF-8; export LANG
LS_COLORS=rs=0:di=01\;34:ln=01\;36:mh=00:pi=40\;33:so=01\;35:do=01\;35:bd=40\;33\;01:cd=40\;33\;01:or=40\;31\;01:mi=01\;37\;41:su=37\;41:sg=30\;43:ca=30\;41:tw=30\;42:ow=34\;42:st=37\;44:ex=01\;32:\*.tar=01\;31:\*.tgz=01\;31:\*.arc=01\;31:\*.arj=01\;31:\*.taz=01\;31:\*.lha=01\;31:\*.lz4=01\;31:\*.lzh=01\;31:\*.lzma=01\;31:\*.tlz=01\;31:\*.txz=01\;31:\*.tzo=01\;31:\*.t7z=01\;31:\*.zip=01\;31:\*.z=01\;31:\*.dz=01\;31:\*.gz=01\;31:\*.lrz=01\;31:\*.lz=01\;31:\*.lzo=01\;31:\*.xz=01\;31:\*.zst=01\;31:\*.tzst=01\;31:\*.bz2=01\;31:\*.bz=01\;31:\*.tbz=01\;31:\*.tbz2=01\;31:\*.tz=01\;31:\*.deb=01\;31:\*.rpm=01\;31:\*.jar=01\;31:\*.war=01\;31:\*.ear=01\;31:\*.sar=01\;31:\*.rar=01\;31:\*.alz=01\;31:\*.ace=01\;31:\*.zoo=01\;31:\*.cpio=01\;31:\*.7z=01\;31:\*.rz=01\;31:\*.cab=01\;31:\*.wim=01\;31:\*.swm=01\;31:\*.dwm=01\;31:\*.esd=01\;31:\*.jpg=01\;35:\*.jpeg=01\;35:\*.mjpg=01\;35:\*.mjpeg=01\;35:\*.gif=01\;35:\*.bmp=01\;35:\*.pbm=01\;35:\*.pgm=01\;35:\*.ppm=01\;35:\*.tga=01\;35:\*.xbm=01\;35:\*.xpm=01\;35:\*.tif=01\;35:\*.tiff=01\;35:\*.png=01\;35:\*.svg=01\;35:\*.svgz=01\;35:\*.mng=01\;35:\*.pcx=01\;35:\*.mov=01\;35:\*.mpg=01\;35:\*.mpeg=01\;35:\*.m2v=01\;35:\*.mkv=01\;35:\*.webm=01\;35:\*.webp=01\;35:\*.ogm=01\;35:\*.mp4=01\;35:\*.m4v=01\;35:\*.mp4v=01\;35:\*.vob=01\;35:\*.qt=01\;35:\*.nuv=01\;35:\*.wmv=01\;35:\*.asf=01\;35:\*.rm=01\;35:\*.rmvb=01\;35:\*.flc=01\;35:\*.avi=01\;35:\*.fli=01\;35:\*.flv=01\;35:\*.gl=01\;35:\*.dl=01\;35:\*.xcf=01\;35:\*.xwd=01\;35:\*.yuv=01\;35:\*.cgm=01\;35:\*.emf=01\;35:\*.ogv=01\;35:\*.ogx=01\;35:\*.aac=01\;36:\*.au=01\;36:\*.flac=01\;36:\*.m4a=01\;36:\*.mid=01\;36:\*.midi=01\;36:\*.mka=01\;36:\*.mp3=01\;36:\*.mpc=01\;36:\*.ogg=01\;36:\*.ra=01\;36:\*.wav=01\;36:\*.oga=01\;36:\*.opus=01\;36:\*.spx=01\;36:\*.xspf=01\;36:; export LS_COLORS
SSH_CONNECTION=192.168.100.1\ 58056\ 192.168.100.132\ 22; export SSH_CONNECTION
XDG_SESSION_CLASS=user; export XDG_SESSION_CLASS
SELINUX_ROLE_REQUESTED=; export SELINUX_ROLE_REQUESTED
LESSOPEN=\|\|/usr/bin/lesspipe.sh\ %s; export LESSOPEN
USER=root; export USER
SELINUX_USE_CURRENT_RANGE=; export SELINUX_USE_CURRENT_RANGE
SHLVL=1; export SHLVL
XDG_SESSION_ID=3; export XDG_SESSION_ID
XDG_RUNTIME_DIR=/run/user/0; export XDG_RUNTIME_DIR
SSH_CLIENT=192.168.100.1\ 58056\ 22; export SSH_CLIENT
DEBUGINFOD_URLS=https://debuginfod.centos.org/\ ; export DEBUGINFOD_URLS
which_declare=declare\ -f; export which_declare
PATH=/root/.local/bin:/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin; export PATH
SELINUX_LEVEL_REQUESTED=; export SELINUX_LEVEL_REQUESTED
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/0/bus; export DBUS_SESSION_BUS_ADDRESS
MAIL=/var/spool/mail/root; export MAIL
SSH_TTY=/dev/pts/1; export SSH_TTY
cd /root || {
         echo 'Execution directory inaccessible' >&2
         exit 1
}
${SHELL:-/bin/sh} << 'marcinDELIMITER638f1ec5'
#!/usr/bin/bash
#
USR='student'
OUT='/home/student/output'
#
for SRV in servera serverb
 do
ssh ${USR}@${SRV} "hostname -f" > ${OUT}-${SRV}
echo "#####" >> ${OUT}-${SRV}
ssh ${USR}@${SRV} "lscpu | grep '^CPU'" >> ${OUT}-${SRV}
echo "#####" >> ${OUT}-${SRV}
ssh ${USR}@${SRV} "grep -v '^$' /etc/selinux/config|grep -v '^#'" >> ${OUT}-${SRV}
echo "#####" >> ${OUT}-${SRV}
ssh ${USR}@${SRV} "sudo grep 'Failed password' /var/log/secure" >> ${OUT}-${SRV}
echo "#####" >> ${OUT}-${SRV}
done

marcinDELIMITER638f1ec5
```

Remove Jobs from Schedule

The atrm JOBNUMBER command removes a scheduled job. Remove the scheduled job when you
no longer need it, for example, when a remote firewall configuration succeeded, and you do not
need to reset it

```sh
[root@rocky2 ~]# atq
1       Wed Aug 14 21:03:00 2024 a root
2       Wed Aug 14 21:15:00 2024 a root

[root@rocky2 ~]# atrm 2
[root@rocky2 ~]# atq
1       Wed Aug 14 21:03:00 2024 a root
```

```sh
[student@servera ~]$ echo "date >> /home/student/myjob.txt" | at now +3min
warning: commands will be executed using /bin/sh
job 1 at Mon Apr 4 05:00:00 2022

[root@rocky2 ~]# echo "date >> /home/student/myjob.txt" | at now +3min
warning: commands will be executed using /bin/sh
job 5 at Wed Aug 14 01:53:00 2024
[root@rocky2 ~]# atq
1       Wed Aug 14 21:03:00 2024 a root
3       Thu Aug 15 16:00:00 2024 a root
4       Sun Aug 18 12:00:00 2024 a root
5       Wed Aug 14 01:53:00 2024 a root
```


Interactively schedule a job in the g queue that runs at teatime (16:00). The job should
print the It's teatime message to the /home/student/tea.txt file. Append the new
messages to the /home/student/tea.txt file

```sh
[student@servera ~]$ at -q g teatime
warning: commands will be executed using /bin/sh
at> echo "It's teatime" >> /home/student/tea.txt
at> Ctrl+d
job 2 at Mon Apr 4 16:00:00 2022
```


# Schedule Recurring User Jobs

tekrar eden, düzenlenmesi gereken aksiyonlarda otomatikleştirme ve belli bir plana göre zamanlanmış görev


## Describe Recurring User Jobs

Use the crontab command to manage scheduled jobs. The following list shows the commands
that a local user can use to manage their jobs

Examples of the crontab command

Temelde 4 flag mevcuttur.

| Command | Intended use |
|---------|--------------|
| crontab -l | List the jobs for the current user. |
| crontab -r | Remove all jobs for the current user. |
| crontab -e | Edit jobs for the current user. |
| crontab filename | Remove all jobs, and replace them with those read from filename. This command uses stdin input when no file is specified. |


A privileged user might use the crontab command -u option to manage jobs for another user.
The crontab command is never used to manage system jobs, and using the crontab commands
as the root user is not recommended due to the ability to exploit personal jobs configured to run
as root. Such privileged jobs should be configured as described in the later section describing
recurring system jobs





## Describe User Job Format


The crontab -e command invokes the vim editor by default unless the EDITOR environment
variable is set for another editor. Each job must use a unique line in the crontab file. Follow these
recommendations for valid entries when writing recurring jobs

• Empty lines for ease of reading.

• Comments on lines that start with the number sign (#).

• Environment variables with a NAME=value format, which affects all lines after the line where they are declared.


Standard variable settings include the SHELL variable to declare the shell that is used for
interpreting the remaining lines of the crontab file. The MAILTO variable determines who should
receive the emailed output

The fields in the crontab file appear in the following order:

• Minutes

• Hours

• Day of month

• Month

• Day of week

• Command


The command executes when the Day of the month or Day of the week fields use the same value
other than the * character. For example, to run a command on the 11th day of every month, and
every Friday at 12:15 (24-hour format), use the following job format

```sh
15 12 11 * Fri command
```

The first five fields all use the same syntax rules:

• Use the * character to execute in every possible instance of the field.

• A number to specify the number of minutes or hours, a date, or a day of the week. For days of
the week, 0 equals Sunday, 1 equals Monday, 2 equals Tuesday, and so on. 7 also equals Sunday.

• Use x-y for a range, which includes the x and y values.

• Use x,y for lists. Lists might include ranges as well, for example, 5,10-13,17 in the Minutes
column, for a job to run at 5, 10, 11, 12, 13, and 17 minutes past the hour.

• The */x indicates an interval of x; for example, */7 in the Minutes column runs a job every
seven minutes.



Examples of Recurring User Jobs


```sh
0 9 3 2 * /usr/local/bin/yearly_backup
```

The following job sends an email containing the Chime word to the owner of this job every five
minutes in between and including 9 a.m. and 16 p.m., but only on each Friday in July

```sh
*/5 9-16 * Jul 5 echo "Chime"
```

The following job runs the /usr/local/bin/daily_report command every working day
(Monday to Friday) two minutes before midnight

```sh
58 23 * * 1-5 /usr/local/bin/daily_report
```



The following job executes the mutt command to send the Checking in mail message to the
developer@example.com recipient every working day (Monday to Friday), at 9 AM


```sh
0 9 * * 1-5 mutt -s "Checking in" developer@example.com % Hi there, just checking in.
```

```sh
[student@servera ~]$ crontab -e

# Insert the following line
*/2 * * * Mon-Fri /usr/bin/date >> /home/student/my_first_cron_job.txt



...output omitted...
crontab: installing new crontab
[student@servera ~]$
```


```sh
[student@servera ~]$ crontab -l
*/2 * * * Mon-Fri /usr/bin/date >> /home/student/my_first_cron_job.txt
```


Remove all the scheduled recurring jobs for the student user

```sh
[student@servera ~]$ crontab -r
```

 Verify that no recurring jobs exist for the student user

```sh
[student@servera ~]$ crontab -l
no crontab for student
```


##Crontab

![alt text](image.png)



https://crontab.guru/
![alt text](image-1.png)


Lab 44 --> 45



# Schedule Recurring System Jobs

Sistem tarafında günlük yedekleme, raporlama, son kullanıcılarda aksiyonlar. Düzenli olmak için

## Recurring System Jobs

The /etc/crontab file has a helpful syntax diagram in the comments

```sh
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# For details see man 4 crontabs
# Example of job definition:
# .---------------- minute (0 - 59)
# | .------------- hour (0 - 23)
# | | .---------- day of month (1 - 31)
# | | | .------- month (1 - 12) OR jan,feb,mar,apr ...
# | | | | .---- day of week (0 - 6) (Sunday=0 or 7) OR
 sun,mon,tue,wed,thu,fri,sat
# | | | | |
# * * * * * user-name command to be executed
```

The /etc/crontab file and other files in the /etc/cron.d/ directory define the recurring
system jobs. Always create custom crontab files in the /etc/cron.d/ directory to schedule
recurring system jobs. Place the custom crontab file in the /etc/cron.d directory to prevent a
package update from overwriting the /etc/crontab file. Packages that require recurring system
jobs place their crontab files in the /etc/cron.d/ directory with the job entries. Administrators
also use this location to group related jobs into a single file


The crontab system also includes repositories for scripts to run every hour, day, week, and month.
These repositories are placed under the /etc/cron.hourly/, /etc/cron.daily/, /etc/
cron.weekly/, and /etc/cron.monthly/ directories. These directories contain executable
shell scripts, not crontab files

```sh
[root@rocky2 ~]# cd /etc/
[root@rocky2 etc]# ls cron*
cron.deny  crontab

cron.d:
0hourly

cron.daily:

cron.hourly:
0anacron

cron.monthly:

cron.weekly:
```


## Run Periodic Commands with Anacron


The run-parts command also runs the daily, weekly, and monthly jobs from the /etc/
anacrontab configuration file

yapılandırma dosyasi. taskın calistirilma bicimini belirler. Burdaki zamana gore belirlenir.


```sh
[root@rocky2 ~]# cat /etc/anacrontab 
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22

#period in days   delay in minutes   job-identifier   command
1       5       cron.daily              nice run-parts /etc/cron.daily
7       25      cron.weekly             nice run-parts /etc/cron.weekly
@monthly 45     cron.monthly            nice run-parts /etc/cron.monthly
```



Period in days
Defines the interval in days for the job to run on a recurring schedule. This field accepts an
integer or a macro value. For example, the macro @daily is equivalent to the 1 integer, which
executes the job daily. Similarly, the macro @weekly is equivalent to the 7 integer, which
executes the job weekly.

Delay in minutes
Defines the time that the crond daemon must wait before it starts the job.

Job identifier
This field identifies the unique name of the job in the log messages.

Command
The command to be executed.

The /etc/anacrontab file also contains environment variable declarations with the
NAME=value syntax. The START_HOURS_RANGE variable specifies the time interval for the jobs
to run. Jobs do not start outside this range. When a job does not run within this time interval on a
particular day, then the job must wait until the next day for execution


## Systemd Timer

The systemd timer unit activates another unit of a different type (such as a service) whose unit
name matches the timer unit name. The timer unit allows timer-based activation of other units.
The systemd timer unit logs timer events in system journals for easier debugging


Sample Timer Unit

The sysstat package provides the systemd timer unit, called the sysstat-collect.timer
service, to collect system statistics every 10 minutes. The following output shows the contents of
the /usr/lib/systemd/system/sysstat-collect.timer configuration file


```SH
...output omitted...
[Unit]
Description=Run system activity accounting tool every 10 minutes
[Timer]
OnCalendar=*:00/10
[Install]
WantedBy=sysstat.service
```

The OnCalendar=\*:00/10 option signifies that this timer unit activates the corresponding
sysstat-collect.service unit every 10 minutes. You might specify more complex time
intervals


Example

Script dosyasını zamanlanmış görev olarak değil bir service olarak çalıştırabiliriz.


```sh
[root@rocky2 ~]# vi my_script.service


[Unit]
Description=my_example

[Service]
Type=oneshot
ExecStart=/bin/bash /root/scripts/script1.sh
```


```sh
[root@rocky2 ~]# vi my_script.timer


[Unit]
Description= Run My Script Daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Bu dosyalar olusturulduktan sonra kopyalanması gereken dizin 

/etc/systemd/system

Hem service ve timer dosyasının buraya kopyalanması gerekir


```sh
[root@rocky2 ~]# cd /etc/systemd/system
[root@rocky2 system]# ls -l
total 8
drwxr-xr-x. 2 root root   31 May 29 17:30 basic.target.wants
lrwxrwxrwx. 1 root root   37 May 29 17:29 ctrl-alt-del.target -> /usr/lib/systemd/system/reboot.target
lrwxrwxrwx. 1 root root   41 May 29 17:30 dbus-org.fedoraproject.FirewallD1.service -> /usr/lib/systemd/system/firewalld.service
lrwxrwxrwx. 1 root root   57 May 29 17:29 dbus-org.freedesktop.nm-dispatcher.service -> /usr/lib/systemd/system/NetworkManager-dispatcher.service
lrwxrwxrwx. 1 root root   43 May 29 17:29 dbus.service -> /usr/lib/systemd/system/dbus-broker.service
lrwxrwxrwx. 1 root root   41 May 29 17:37 default.target -> /usr/lib/systemd/system/multi-user.target
drwxr-xr-x. 2 root root   45 May 29 17:30 default.target.wants
drwxr-xr-x. 2 root root   32 May 29 17:29 getty.target.wants
drwxr-xr-x. 2 root root 4096 Aug 14 01:37 multi-user.target.wants
drwxr-xr-x. 2 root root   48 May 29 17:29 network-online.target.wants
drwxr-xr-x. 2 root root   71 May 29 17:30 sockets.target.wants
drwxr-xr-x. 2 root root 4096 May 29 17:30 sysinit.target.wants
drwxr-xr-x. 2 root root   56 May 29 17:30 timers.target.wants



[root@rocky2 system]# cp /root/my_script.service .
[root@rocky2 system]# cp /root/my_script.timer .
[root@rocky2 system]# ls -l
total 16
drwxr-xr-x. 2 root root   31 May 29 17:30 basic.target.wants
lrwxrwxrwx. 1 root root   37 May 29 17:29 ctrl-alt-del.target -> /usr/lib/systemd/system/reboot.target
lrwxrwxrwx. 1 root root   41 May 29 17:30 dbus-org.fedoraproject.FirewallD1.service -> /usr/lib/systemd/system/firewalld.service
lrwxrwxrwx. 1 root root   57 May 29 17:29 dbus-org.freedesktop.nm-dispatcher.service -> /usr/lib/systemd/system/NetworkManager-dispatcher.service
lrwxrwxrwx. 1 root root   43 May 29 17:29 dbus.service -> /usr/lib/systemd/system/dbus-broker.service
lrwxrwxrwx. 1 root root   41 May 29 17:37 default.target -> /usr/lib/systemd/system/multi-user.target
drwxr-xr-x. 2 root root   45 May 29 17:30 default.target.wants
drwxr-xr-x. 2 root root   32 May 29 17:29 getty.target.wants
drwxr-xr-x. 2 root root 4096 Aug 14 01:37 multi-user.target.wants
-rw-r--r--. 1 root root   99 Aug 17 10:54 my_script.service
-rw-r--r--. 1 root root  116 Aug 17 10:54 my_script.timer
drwxr-xr-x. 2 root root   48 May 29 17:29 network-online.target.wants
drwxr-xr-x. 2 root root   71 May 29 17:30 sockets.target.wants
drwxr-xr-x. 2 root root 4096 May 29 17:30 sysinit.target.wants
drwxr-xr-x. 2 root root   56 May 29 17:30 timers.target.wants


[root@rocky2 system]# systemctl daemon-reload
[root@rocky2 system]# systemctl start my_script.timer 
[root@rocky2 system]# systemctl enable my_script.timer
Created symlink /etc/systemd/system/timers.target.wants/my_script.timer → /etc/systemd/system/my_script.timer.


[root@rocky2 system]# systemctl status my_script.timer 
● my_script.timer - Run My Script Daily
     Loaded: loaded (/etc/systemd/system/my_script.timer; enabled; preset: disabled)
     Active: active (waiting) since Sat 2024-08-17 10:55:43 +03; 4min 19s ago
      Until: Sat 2024-08-17 10:55:43 +03; 4min 19s ago
    Trigger: Sun 2024-08-18 00:00:00 +03; 12h left
   Triggers: ● my_script.service

Aug 17 10:55:43 rocky2 systemd[1]: Started Run My Script Daily.

[root@rocky2 system]# systemctl status my_script.service 
○ my_script.service - my_example
     Loaded: loaded (/etc/systemd/system/my_script.service; static)
     Active: inactive (dead)
TriggeredBy: ● my_script.timer
```





# Manage Temporary Files


## Manage Temporary Files


Most critical applications and services use temporary files and directories. Some applications and
users use the /tmp directory to hold transient working data, while other applications use taskspecific locations such as daemon- and user-specific volatile directories under /run, which exist
only in memory. When the system reboots or loses power, memory-based file systems are selfcleaning

Red Hat Enterprise Linux includes the systemd-tmpfiles tool, which provides a structured and
configurable method to manage temporary directories and files.
At system boot, one of the first systemd service units launched is the systemd-tmpfilessetup service. This service runs the systemd-tmpfiles command --create --remove
options, which reads instructions from the /usr/lib/tmpfiles.d/*.conf, /run/
tmpfiles.d/*.conf, and /etc/tmpfiles.d/*.conf configuration files. These configuration
files list files and directories that the systemd-tmpfiles-setup service is instructed to create,
delete, or secure with permissions


Clean Temporary Files with a Systemd Timer



```sh
[root@rocky2 system]# systemd-tmpfiles --clean

[root@rocky2 system]# systemctl status systemd-tmpfiles-clean.timer
● systemd-tmpfiles-clean.timer - Daily Cleanup of Temporary Directories
     Loaded: loaded (/usr/lib/systemd/system/systemd-tmpfiles-clean.timer; static)
     Active: active (waiting) since Sat 2024-08-17 10:44:20 +03; 46min ago
      Until: Sat 2024-08-17 10:44:20 +03; 46min ago
    Trigger: Sun 2024-08-18 10:59:23 +03; 23h left
   Triggers: ● systemd-tmpfiles-clean.service
       Docs: man:tmpfiles.d(5)
             man:systemd-tmpfiles(8)

Aug 17 10:44:20 rocky2 systemd[1]: Started Daily Cleanup of Temporary Directories.
```


To prevent long-running systems from filling up their disks with stale data, a systemd timer unit
called systemd-tmpfiles-clean.timer at a regular interval triggers systemd-tmpfilesclean.service, which executes the systemd-tmpfiles --clean command.
A systemd timer unit configuration has a [Timer] section for indicating how to start the service
with the same name as the timer.
Use the following systemctl command to view the contents of the systemd-tmpfilesclean.timer unit configuration file.

```sh
[user@host ~]$ systemctl cat systemd-tmpfiles-clean.timer
# /usr/lib/systemd/system/systemd-tmpfiles-clean.timer
# SPDX-License-Identifier: LGPL-2.1-or-later
#
# This file is part of systemd.
#
# systemd is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
[Unit]
Description=Daily Cleanup of Temporary Directories
Documentation=man:tmpfiles.d(5) man:systemd-tmpfiles(8)
ConditionPathExists=!/etc/initrd-release
[Timer]
OnBootSec=15min
OnUnitActiveSec=1d
```

In the preceding configuration, the OnBootSec=15min parameter indicates that the systemdtmpfiles-clean.service unit gets triggered 15 minutes after the system boots up.
The OnUnitActiveSec=1d parameter indicates that any further trigger to the systemdtmpfiles-clean.service unit happens 24 hours after the service unit was last activated

Change the parameters in the systemd-tmpfiles-clean.timer timer unit configuration file
to meet your requirements. For example, a 30min value for the OnUnitActiveSec parameter
triggers the systemd-tmpfiles-clean.service service unit 30 minutes after the service
unit is last activated. As a result, systemd-tmpfiles-clean.service gets triggered every 30
minutes after the changes are recognized



After changing the timer unit configuration file, use the systemctl daemon-reload command
to ensure that systemd loads the new configuration

```sh
[root@host ~]# systemctl daemon-reload
```

After reloading the systemd manager configuration, use the following systemctl command to
activate the systemd-tmpfiles-clean.timer unit.


```sh
[root@host ~]# systemctl enable --now systemd-tmpfiles-clean.timer
```

Clean Temporary Files Manually

The systemd-tmpfiles --clean command parses the same configuration files as the
systemd-tmpfiles --create command, but instead of creating files and directories, it purges
all files that were not accessed, changed, or modified more recently than the maximum age as
defined in the configuration file.

Find detailed information about the format of the configuration files for the systemd-tmpfiles
service in the tmpfiles.d(5) man page. The basic syntax consists of the following columns:
Type, Path, Mode, UID, GID, Age, and Argument. Type refers to the action that the systemdtmpfiles service should take; for example, d to create a directory if it does not exist, or Z to
recursively restore SELinux contexts, file permissions, and ownership.

The following are examples of purge configuration with explanations:





```sh
d /run/systemd/seats 0755 root root -
```


When you create files and directories, create the /run/systemd/seats directory if it does not
exist, with the root user and the root group as owners, and with permissions of rwxr-xr-x. If
this directory does exist, then take no action. The systemd-tmpfiles service does not purge
this directory automatically.


```sh
D /home/student 0700 student student 1d
```


Create the /home/student directory if it does not exist. If it does exist, then empty it of all
contents. When the system runs the systemd-tmpfiles --clean command, it removes all files
in the directory that you did not access, change, or modify for more than one day.


```sh
L /run/fstablink - root root - /etc/fstab
```

Create the /run/fstablink symbolic link, to point to the /etc/fstab folder. Never
automatically purge this line.



Configuration File Precedence

The systemd-tmpfiles-clean service configuration files can exist in three places:




```sh
• /etc/tmpfiles.d/*.conf
• /run/tmpfiles.d/*.conf
• /usr/lib/tmpfiles.d/*.conf
```

Use the files in the /etc/tmpfiles.d/ directory to configure custom temporary locations, and
to override vendor-provided defaults. The files in the /run/tmpfiles.d/ directory are volatile
files, which normally daemons use to manage their own runtime temporary files. Relevant RPM
packages provide the files in the /usr/lib/tmpfiles.d/ directory; therefore do not edit these
files.


If a file in the /run/tmpfiles.d/ directory has the same file name as a file in the
/usr/lib/tmpfiles.d/ directory, then the service uses the file in the /run/tmpfiles.d/
directory. If a file in the /etc/tmpfiles.d/ directory has the same file name as a file in either
the /run/tmpfiles.d/ or the /usr/lib/tmpfiles.d/ directories, then the service uses the
file in the /etc/tmpfiles.d/ directory.


Given these precedence rules, you can easily override vendor-provided settings by copying
the relevant file to the /etc/tmpfiles.d/ directory and then editing it. By using these
configuration locations properly, you can manage administrator-configured settings from a central
configuration management system, and package updates will not overwrite your configured
settings

belli aralıklarla kontrol edilip aşağıdaki config dosyalarına göre set edilmesi sağlanır

```sh
[root@rocky2 system]# cd /usr/lib/tmpfiles.d/
[root@rocky2 tmpfiles.d]# ls -l
total 96
-rw-r--r--. 1 root root   35 Nov  1  2023 cryptsetup.conf
-rw-r--r--. 1 root root  188 Sep  9  2022 dnf.conf
-rw-r--r--. 1 root root  516 Apr  8 01:28 etc.conf
-rw-r--r--. 1 root root  362 Oct 31  2022 home.conf
-rw-r--r--. 1 root root 1096 Oct 31  2022 journal-nocow.conf
-rw-r--r--. 1 root root  907 Apr  8 01:28 legacy.conf
-rw-r--r--. 1 root root   30 Apr  7 21:56 libselinux.conf
-r--r--r--. 1 root root   61 Apr 20 21:34 lvm2.conf
-rw-r--r--. 1 root root   35 Apr 15  2023 man-db.conf
-rw-r--r--. 1 root root  166 Apr 16 06:22 pam.conf
-rw-r--r--. 1 root root  851 Apr  8 01:27 provision.conf
-rw-r--r--. 1 root root  400 Oct 31  2022 README
-rw-r--r--. 1 root root  137 May 18 00:23 selinux-policy.conf
-rw-r--r--. 1 root root   60 Apr  7 23:15 setup.conf
-rw-r--r--. 1 root root  763 Apr  8 01:28 static-nodes-permissions.conf
-rw-r--r--. 1 root root  305 Feb 14  2024 sudo.conf
-rw-r--r--. 1 root root 2001 Apr  8 01:28 systemd.conf
-rw-r--r--. 1 root root  597 Oct 31  2022 systemd-nologin.conf
-rw-r--r--. 1 root root 1512 Oct 31  2022 systemd-pstore.conf
-rw-r--r--. 1 root root  823 Oct 31  2022 systemd-tmp.conf
-rw-r--r--. 1 root root  449 Oct 31  2022 tmp.conf
-rw-r--r--. 1 root root  432 Nov  1  2023 tpm2-tss-fapi.conf
-rw-r--r--. 1 root root  568 Apr  8 01:28 var.conf
-rw-r--r--. 1 root root  617 Oct 31  2022 x11.conf


[root@rocky2 tmpfiles.d]# cat pam.conf 
d /run/console 0755 root root -
d /run/faillock 0755 root root -
d /run/sepermit 0755 root root -
d /run/motd.d 0755 root root -
f /var/log/tallylog 0600 root root -
```


