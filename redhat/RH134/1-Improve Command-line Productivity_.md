# Improve Command-line  Productivity

## Write Simple Bash Scripts


Specify the Command Interpreter

For normal Bash syntax script files, the
first line is this directive

```sh
#!/usr/bin/bash
```

Execute a Bash Shell Script

Alternatively, run a script in your current working directory using the . directory prefix, such as
./scriptname

```sh
[user@host ~]$ which hello
~/bin/hello
[user@host ~]$ echo $PATH
/home/user/.local/bin:/home/user/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/
sbin:/usr/local/bin
```

Quote Special Characters


The following example shows the backslash character (\) modifying the hash character so it is not
interpreted as a comment

```sh
[user@host ~]$ echo # not a comment
ü
[user@host ~]$ echo \# not a comment
# not a comment
```


To escape more than one character in a text string, either use the backslash character multiple
times or enclose the whole string in single quotes ('') to interpret literally. Single quotes preserve
the literal meaning of all characters that they enclose. Observe the backslash character and single
quotes in these examples

```sh
[user@host ~]$ echo # not a comment #

[user@host ~]$ echo \# not a comment #
# not a comment
[user@host ~]$ echo \# not a comment \#
# not a comment #
[user@host ~]$ echo '# not a comment #'
# not a comment #

```


Use single quotation marks to interpret all enclosed text literally. Besides suppressing globbing
and shell expansion, single quotations also direct the shell to suppress command and variable
substitution. The question mark (?) is included inside the quotations, because it is a metacharacter
that also needs escaping from expansion

```sh
[user@host ~]$ var=$(hostname -s); echo $var
host
[user@host ~]$ echo "***** hostname is ${var} *****"
***** hostname is host *****

[user@host ~]$ echo Your username variable is \$USER.
Your username variable is $USER.
[user@host ~]$ echo "Will variable $var evaluate to $(hostname -s)?"
Will variable host evaluate to host?
[user@host ~]$ echo 'Will variable $var evaluate to $(hostname -s)?'
Will variable $var evaluate to $(hostname -s)?
[user@host ~]$ echo "\"Hello, world\""
"Hello, world"
[user@host ~]$ echo '"Hello, world"'
"Hello, world"

```

Provide Output from a Shell Script



The echo command displays arbitrary text by passing the text as an argument to the command.
By default, the text is sent to standard output (STDOUT), but you can send text elsewhere by
using output redirection. In the following simple Bash script, the echo command displays the
"Hello, world" message to STDOUT, which defaults to the screen device

```sh
[user@host ~]$ cat ~/bin/hello
#!/usr/bin/bash
echo "Hello, world"

[user@host ~]$ hello
Hello, world

```



The echo command is widely used in shell scripts to display informational or error messages.
Messages are a helpful indicator of a script's progress, and can be directed to standard output,
standard error, or be redirected to a log file for archiving. When displaying error messages, good
programming practice is to redirect error messages to STDERR to segregate them from normal
program output


```sh
[user@host ~]$ cat ~/bin/hello
#!/usr/bin/bash
echo "Hello, world"
echo "ERROR: Houston, we have a problem." >&2
[user@host ~]$ hello 2> hello.log
Hello, world
[user@host ~]$ cat hello.log
ERROR: Houston, we have a problem.
```


example

```sh
[student@servera ~]$ vim firstscript.sh
```

```sh
#!/usr/bin/bash
#
echo "This is my first bash script" > ~/output.txt
echo "" >> ~/output.txt
echo "#####################################################" >> ~/output.txt
echo "LIST BLOCK DEVICES" >> ~/output.txt
echo "" >> ~/output.txt
lsblk >> ~/output.txt
echo "" >> ~/output.txt
echo "#####################################################" >> ~/output.txt
echo "FILESYSTEM FREE SPACE STATUS" >> ~/output.txt
echo "" >> ~/output.txt
df -h >> ~/output.txt
echo "#####################################################" >> ~/output.txt
```

```sh
[student@servera ~]$ chmod a+x firstscript.sh
```

```sh
[student@servera ~]$ ./firstscript.sh
```


```sh
[student@servera ~]$ cat output.txt
This is my first bash script
#####################################################
LIST BLOCK DEVICES
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
sr0 11:0 1 558K 0 rom
vda 252:0 0 10G 0 disk
├─vda1 252:1 0 1M 0 part
├─vda2 252:2 0 200M 0 part /boot/efi
├─vda3 252:3 0 500M 0 part /boot
└─vda4 252:4 0 9.3G 0 part /
vdb 252:16 0 5G 0 disk
vdc 252:32 0 5G 0 disk
vdd 252:48 0 5G 0 disk
#####################################################
FILESYSTEM FREE SPACE STATUS
Filesystem Size Used Avail Use% Mounted on
devtmpfs 844M 0 844M 0% /dev
tmpfs 888M 0 888M 0% /dev/shm
tmpfs 355M 9.4M 346M 3% /run
/dev/vda4 9.4G 1.7G 7.7G 18% /
/dev/vda3 495M 161M 335M 33% /boot
/dev/vda2 200M 7.6M 193M 4% /boot/efi
tmpfs 178M 0 178M 0% /run/user/1000
#####################################################
```


# Loops and Conditional Constructs in Scripts

## Use Loops to Iterate Commands


Process Items from the Command Line

```sh
for VARIABLE in LIST; do
COMMAND VARIABLE
done
```


These examples demonstrate different ways to provide strings to for loops

```sh
[user@host ~]$ for HOST in host1 host2 host3; do echo $HOST; done
host1
host2
host3
[user@host ~]$ for HOST in host{1,2,3}; do echo $HOST; done
host1
host2
host3
[user@host ~]$ for HOST in host{1..3}; do echo $HOST; done
host1
host2
host3
[user@host ~]$ for FILE in file{a..c}; do ls $FILE; done
filea
fileb
filec
```


```sh
[user@host ~]$ for PACKAGE in $(rpm -qa | grep kernel); \
do echo "$PACKAGE was installed on \
$(date -d @$(rpm -q --qf "%{INSTALLTIME}\n" $PACKAGE))"; done
kernel-tools-libs-5.14.0-70.2.1.el9_0.x86_64 was installed on Thu Mar 24 10:52:40
 PM EDT 2022
kernel-tools-5.14.0-70.2.1.el9_0.x86_64 was installed on Thu Mar 24 10:52:40 PM
 EDT 2022
kernel-core-5.14.0-70.2.1.el9_0.x86_64 was installed on Thu Mar 24 10:52:46 PM EDT
 2022
kernel-modules-5.14.0-70.2.1.el9_0.x86_64 was installed on Thu Mar 24 10:52:47 PM
 EDT 2022
kernel-5.14.0-70.2.1.el9_0.x86_64 was installed on Thu Mar 24 10:53:04 PM EDT 2022
[user@host ~]$ for EVEN in $(seq 2 2 10); do echo "$EVEN"; done
2
4
6
8
10
```


```sh
[root@rocky2 ~]# for PACKAGE in $(rpm -qa | grep kernel); \
do echo "$PACKAGE was installed on \
$(date -d @$(rpm -q --qf "%{INSTALLTIME}\n" $PACKAGE))"; done
kernel-modules-core-5.14.0-362.8.1.el9_3.x86_64 was installed on Wed May 29 05:29:30 PM +03 2024
kernel-core-5.14.0-362.8.1.el9_3.x86_64 was installed on Wed May 29 05:29:33 PM +03 2024
kernel-modules-5.14.0-362.8.1.el9_3.x86_64 was installed on Wed May 29 05:29:40 PM +03 2024
kernel-5.14.0-362.8.1.el9_3.x86_64 was installed on Wed May 29 05:30:33 PM +03 2024
kernel-tools-libs-5.14.0-427.18.1.el9_4.x86_64 was installed on Wed May 29 06:26:24 PM +03 2024
kernel-modules-core-5.14.0-427.18.1.el9_4.x86_64 was installed on Wed May 29 06:27:08 PM +03 2024
kernel-core-5.14.0-427.18.1.el9_4.x86_64 was installed on Wed May 29 06:27:11 PM +03 2024
kernel-modules-5.14.0-427.18.1.el9_4.x86_64 was installed on Wed May 29 06:27:30 PM +03 2024
kernel-tools-5.14.0-427.18.1.el9_4.x86_64 was installed on Wed May 29 06:28:42 PM +03 2024
kernel-5.14.0-427.18.1.el9_4.x86_64 was installed on Wed May 29 06:28:43 PM +03 2024
```


## Bash Script Exit Codes


Use the exit command with an optional integer argument between 0 and 255, which represents
an exit code. An exit code is returned to a parent process to indicate the status at exit. An exit
code value of 0 represents a successful script completion with no errors. All other nonzero values
indicate an error exit code. The script programmer defines these codes. Use unique values to
represent the different error conditions that are encountered. Retrieve the exit code of the last
completed command from the built-in $? variable, as in the following examples


```sh
[user@host bin]$ cat hello
#!/usr/bin/bash
echo "Hello, world"
exit 0
[user@host bin]$ ./hello
Hello, world
[user@host bin]$ echo $?
0
```


## Test Logic for Strings and Directories, and to Compare Values


The following examples demonstrate the test command with Bash numeric comparison
operators

```sh
[user@host ~]$ test 1 -gt 0 ; echo $?
0
[user@host ~]$ test 0 -gt 1 ; echo $?
1
```

Perform tests by using the Bash test command syntax, [ <TESTEXPRESSION> ] or the
newer extended test command syntax, [[ <TESTEXPRESSION> ]], which provides features
such as file name globbing and regex pattern matching. In most cases you should use the
[[ <TESTEXPRESSION> ]] syntax.
The following examples demonstrate the Bash test command syntax and numeric comparison
operators


```sh
[user@host ~]$ [[ 1 -eq 1 ]]; echo $?
0
[user@host ~]$ [[ 1 -ne 1 ]]; echo $?
1
[user@host ~]$ [[ 8 -gt 2 ]]; echo $?
0
[user@host ~]$ [[ 2 -ge 2 ]]; echo $?
0
[user@host ~]$ [[ 2 -lt 2 ]]; echo $?
1
[user@host ~]$ [[ 1 -lt 2 ]]; echo $?
0
```

The following examples demonstrate the Bash string comparison operators

```sh
[user@host ~]$ [[ abc = abc ]]; echo $?
0
[user@host ~]$ [[ abc == def ]]; echo $?
1
[user@host ~]$ [[ abc != def ]]; echo $?
0
```


The following examples demonstrate the use of Bash string unary (one argument) operators


```sh
[user@host ~]$ STRING=''; [[ -z "$STRING" ]]; echo $?
0
[user@host ~]$ STRING='abc'; [[ -n "$STRING" ]]; echo $?
0

```

## Conditional Structures



Use the If/Then Construct

The simplest of the conditional structures is the if/then construct, with the following syntax

```sh
if <CONDITION>; then
 <STATEMENT>
 ...
 <STATEMENT>
fi
```

The following code section demonstrates the
use of an if/then construct to start the psacct service if it is not active

```sh
[user@host ~]$ systemctl is-active psacct > /dev/null 2>&1
[user@host ~]$ if [[ $? -ne 0 ]]; then sudo systemctl start psacct; fi

```


Use the If/Then/Else Construct

You can further expand the if/then construct so that it takes different sets of actions depending
on whether a condition is met. Use the if/then/else construct to accomplish this behavior, as
in this example

```sh
if <CONDITION>; then
 <STATEMENT>
 ...
 <STATEMENT>
else
 <STATEMENT>
 ...
 <STATEMENT>
fi
```


The following code section demonstrates an if/then/else statement to start the psacct
service if it is not active, and to stop it if it is active

```sh
[user@host ~]$ systemctl is-active psacct > /dev/null 2>&1
[user@host ~]$ if [[ $? -ne 0 ]]; then \
sudo systemctl start psacct; \
else \
sudo systemctl stop psacct; \
fi
```

Use the If/Then/Elif/Then/Else Construct


Expand an if/then/else construct to test more than one condition and execute a different set
of actions when it meets a specific condition. The next example shows the construct for an added
condition

```sh
if <CONDITION>; then
 <STATEMENT>
 ...
 <STATEMENT>
elif <CONDITION>; then
 <STATEMENT>
 ...
 <STATEMENT>
else
 <STATEMENT>
 ...
 <STATEMENT>
fi
```

The following example demonstrates the use of an if/then/elif/then/else statement to
run the mysql client if the mariadb service is active, or run the psql client if the postgresql service is active, or run the sqlite3 client if both the mariadb and the postgresql service are inactive

```sh
[user@host ~]$ systemctl is-active mariadb > /dev/null 2>&1
[user@host ~]$ MARIADB_ACTIVE=$?
[user@host ~]$ sudo systemctl is-active postgresql > /dev/null 2>&1
[user@host ~]$ POSTGRESQL_ACTIVE=$?
[user@host ~]$ if [[ "$MARIADB_ACTIVE" -eq 0 ]]; then \
mysql; \
elif [[ "$POSTGRESQL_ACTIVE" -eq 0 ]]; then \
psql; \
else \
sqlite3; \
fi
```

# Match Text in Command Output with Regular Expressions


## Write Regular Expressions


Describe a Simple Regular Expression


Imagine that a user is looking through the following file to look for all occurrences of the pattern
cat

```sh
cat
dog
concatenate
dogma
category
educated
boondoggle
vindication
chilidog
```


The cat string is an exact match of the c character, followed by the a and t characters with no
other characters in between. Searching the file with the cat string as the regular expression
returns the following matches

```sh
cat
concatenate
category
educated
vindication
```

Match the Start and End of a Line

To match only at the beginning of a line, use the caret character (^). To match only at the end of a
line, use the dollar sign ($).

Using the same file as for the previous example, the ^cat regular expression would match two
lines

```sh
cat
category
```


The cat$ regular expression would not find only one match, where the cat characters are at the
end of a line


```sh
cat
```


Locate lines in the file that end with dog by using an end-of-line anchor to create the dog$ regular
expression, which will match two lines

```sh
dog
chilidog
```

To locate a line that contains only the search expression exactly, use both the beginning and endof-line anchors. For example, to locate the word cat when it is both at the beginning and the end
of a line simultaneously, use ^cat$

```sh
cat
```

Wildcard and Multiplier Usage in Regular Expressions


Another type of multiplier indicates a more precise number of characters desired in the pattern. An
example of an explicit multiplier is the 'c.\{2\}t' regular expression, which matches any word
that begins with a c, followed by exactly any two characters, and ends with a t. The 'c.\{2\}t'
expression would match two words in the following example

```sh
cat
coat
convert
cart
covert
cypher
```

```sh
Option Description
.       The period (.) matches any single character.
?       The preceding item is optional and is matched at most once.
*       The preceding item is matched zero or more times.
+       The preceding item is matched one or more times.
{n}     The preceding item is matched exactly n times.
{n,}    The preceding item is matched n or more times.
{,m}    The preceding item is matched at most m times.
{n,m}   The preceding item is matched at least n times, but not more than m times.
[:alnum:]   Alphanumeric characters: [:alpha:] and [:digit:]; in the 'C' locale and ASCII character encoding, this expression is the same as [0-9A-Zaz].
[:alpha:]   Alphabetic characters: [:lower:] and [:upper:]; in the 'C' locale and ASCII character encoding, this expression is the same as [A-Za-z].
[:blank:]   Blank characters: space and tab.
[:cntrl:]   Control characters. In ASCII, these characters have octal codes 000 through 037, and 177 (DEL).
[:digit:]   Digits: 0 1 2 3 4 5 6 7 8 9.
[:graph:]   Graphical characters: [:alnum:] and [:punct:].
[:lower:]   Lowercase letters; in the 'C' locale and ASCII character encoding: a b c d e f g h i j k l m n o p q r s t u v w x y z.
[:print:]   Printable characters: [:alnum:], [:punct:], and space.
[:punct:]   Punctuation characters; in the 'C' locale and ASCII character encoding: ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ' { | } ~.
[:space:]   Space characters: in the 'C' locale, this is tab, newline, vertical tab, form feed, carriage return, and space.
[:upper:]   Uppercase letters: in the 'C' locale and ASCII character encoding: A B C D E F G H I J K L M N O P Q R S T U V W X Y Z.
[:xdigit:]  Hexadecimal digits: 0 1 2 3 4 5 6 7 8 9 A B C D E F a b c d e f.
\b      Match the empty string at the edge of a word.
\B      Match the empty string provided that it is not at the edge of a word.
\<      Match the empty string at the beginning of a word.
\>      Match the empty string at the end of a word.
\w      Match word constituent. Synonym for [_[:alnum:]].
\W      Match non-word constituent. Synonym for [^_[:alnum:]].
\s      Match white space. Synonym for '[[:space:]`].
\S      Match non-white space. Synonym for [^[:space:]].
```

## Match Regular Expressions in the Command Line


Isolating Data with the grep Command

```sh
[user@host ~]$ grep '^computer' /usr/share/dict/words
computer
computerese
computerise
computerite
computerizable
computerization
computerize
computerized
computerizes
computerizing
computerlike
computernik
computers
```


The grep command can process output from other commands by using a pipe operator character
(|). The following example shows the grep command parsing lines from the output of another
command

```sh
[root@host ~]# ps aux | grep chrony
chrony 662 0.0 0.1 29440 2468 ? S 10:56 0:00 /usr/sbin/chronyd

```


The grep Command Options

|   Option  | Function  |
|-----------|-----------|
| -i | Use the provided regular expression but do not enforce case sensitivity (run case-insensitive). |
| -v | Display only lines that do not contain matches to the regular expression. |
| -r | Search for data that matches the regular expression recursively in a group of files or directories. |
| -A | NUMBER Display NUMBER of lines after the regular expression match. |
| -B | NUMBER Display NUMBER of lines before the regular expression match. |
| -e | If multiple -e options are used, then multiple regular expressions can be supplied and are used with a logical OR. |


Examples of the grep Command

Regular expressions are case-sensitive by default. Use the grep command -i option to run a
case-insensitive search. The following example shows an excerpt of the /etc/httpd/conf/
httpd.conf configuration file

```sh
[user@host ~]$ cat /etc/httpd/conf/httpd.conf
...output omitted...
ServerRoot "/etc/httpd"
#
# Listen: Allows you to bind Apache to specific IP addresses and/or
# ports, instead of the default. See also the <VirtualHost>
# directive.
#
# Change this to Listen on a specific IP address, but note that if
# httpd.service is enabled to run at boot time, the address may not be
# available when the service starts. See the httpd.service(8) man
# page for more information.
#
#Listen 12.34.56.78:80
Listen 80
...output omitted...

```


The following example searches for the serverroot regular expression in the /etc/httpd/
conf/httpd.conf configuration file

```sh
[user@host ~]$ grep -i serverroot /etc/httpd/conf/httpd.conf
# with "/", the value of ServerRoot is prepended -- so 'log/access_log'
# with ServerRoot set to '/www' will be interpreted by the
# ServerRoot: The top of the directory tree under which the server's
# ServerRoot at a non-local disk, be sure to specify a local disk on the
# same ServerRoot for multiple httpd daemons, you will need to change at
ServerRoot "/etc/httpd"

```

In the following example, all lines, regardless of case, that do not contain the server regular
expression are returned

```sh
[user@host ~]$ grep -v -i server /etc/hosts
127.0.0.1 localhost.localdomain localhost
172.25.254.254 classroom.example.com classroom
172.25.254.254 content.example.com content
172.25.254.254 materials.example.com materials
### rht-vm-hosts file listing the entries to be appended to /etc/hosts
172.25.250.9 workstation.lab.example.com workstation
172.25.250.254 bastion.lab.example.com bastion
172.25.250.220 utility.lab.example.com utility
172.25.250.220 registry.lab.example.com registry
```


To look at a file without being distracted by comment lines, use the grep command -v option. In
the following example, the regular expression matches all lines that begin with a hash character (#)
or the semicolon (;) character. Either of these two characters at the beginning of a line indicates a
comment that is omitted from the output

```sh
[user@host ~]$ grep -v '^[#;]' /etc/ethertypes
IPv4 0800 ip ip4 # Internet IP (IPv4)
X25 0805
ARP 0806 ether-arp #
FR_ARP 0808 # Frame Relay ARP [RFC1701]

```


The grep command -e option allows you to search for more than one regular expression at a time.
The following example, which uses a combination of the less and grep commands, locates all
occurrences of pam_unix, user root, and Accepted publickey in the /var/log/secure
log file


```sh
[root@host ~]# cat /var/log/secure | grep -e 'pam_unix' \
-e 'user root' -e 'Accepted publickey' | less
Mar 4 03:31:41 localhost passwd[6639]: pam_unix(passwd:chauthtok): password
 changed for root
Mar 4 03:32:34 localhost sshd[15556]: Accepted publickey for devops from
 10.30.0.167 port 56472 ssh2: RSA SHA256:M8ikhcEDm2tQ95Z0o7ZvufqEixCFCt
+wowZLNzNlBT0
Mar 4 03:32:34 localhost systemd[15560]: pam_unix(systemd-user:session): session
 opened for user devops(uid=1001) by (uid=0)

```

To search for text in a file that is you have open with the vim or less commands, first enter the
slash character (/) and then type the pattern to find. Press Enter to start the search. Press N to
find the next match

```sh
[root@host ~]# vim /var/log/boot.log
...output omitted...
[^[[0;32m OK ^[[0m] Finished ^[[0;1;39mdracut pre-pivot and cleanup hook^[[0m.^M
 Starting ^[[0;1;39mCleaning Up and Shutting Down Daemons^[[0m...^M
[^[[0;32m OK ^[[0m] Stopped target ^[[0;1;39mRemote Encrypted Volumes^[[0m.^M
[^[[0;32m OK ^[[0m] Stopped target ^[[0;1;39mTimer Units^[[0m.^M
[^[[0;32m OK ^[[0m] Closed ^[[0;1;39mD-Bus System Message Bus Socket^[[0m.^M
/Daemons
```

```sh
[root@host ~]# less /var/log/messages
...output omitted...
Mar 4 03:31:19 localhost kernel: pci 0000:00:02.0: vgaarb: setting as boot VGA
 device
Mar 4 03:31:19 localhost kernel: pci 0000:00:02.0: vgaarb: VGA device added:
 decodes=io+mem,owns=io+mem,locks=none
Mar 4 03:31:19 localhost kernel: pci 0000:00:02.0: vgaarb: bridge control
 possible
Mar 4 03:31:19 localhost kernel: vgaarb: loaded
Mar 4 03:31:19 localhost kernel: SCSI subsystem initialized
Mar 4 03:31:19 localhost kernel: ACPI: bus type USB registered
Mar 4 03:31:19 localhost kernel: usbcore: registered new interface driver usbfs
Mar 4 03:31:19 localhost kernel: usbcore: registered new interface driver hub
Mar 4 03:31:19 localhost kernel: usbcore: registered new device driver usb
/device

```

Use the grep command to find the GID and UID for the postfix and postdrop groups
and users. To do so, use the rpm -q --scripts command which queries the information
for a specific package and shows the scripts that are used as part of the installation
process


```sh
[student@servera ~]$ rpm -q --scripts postfix | grep -e 'user' -e 'group'
# Add user and groups if necessary
/usr/sbin/groupadd -g 90 -r postdrop 2>/dev/null
/usr/sbin/groupadd -g 89 -r postfix 2>/dev/null
/usr/sbin/groupadd -g 12 -r mail 2>/dev/null
/usr/sbin/useradd -d /var/spool/postfix -s /sbin/nologin -g postfix -G mail -M -r
 -u 89 postfix 2>/dev/null
 setgid_group=postdrop \
```


Modify the previous regular expression to display the first two messages in the /var/log/
maillog file. In this search, you do not need to use the caret character (^), because you
are not searching for the first character in a line.


```sh
[root@servera ~]# grep 'postfix' /var/log/maillog | head -n 2
Apr 1 15:27:16 servera postfix/postfix-script[3121]: starting the Postfix mail
 system
Apr 1 15:27:16 servera postfix/master[3123]: daemon started -- version 3.5.9,
 configuration /etc/postfix
```


Find the name of the queue directory for the Postfix server. Search the /etc/
postfix/main.cf configuration file for all information about queues. Use the grep
command -i option to ignore case distinctions


```sh
[root@servera ~]# grep -i 'queue' /etc/postfix/main.cf
# testing. When soft_bounce is enabled, mail will remain queued that
# The queue_directory specifies the location of the Postfix queue.
queue_directory = /var/spool/postfix
# QUEUE AND PROCESS OWNERSHIP
# The mail_owner parameter specifies the owner of the Postfix queue
# is the Sendmail-compatible mail queue listing command.
# setgid_group: The group for mail submission and queue management
```

Confirm that the postfix service writes messages to the /var/log/messages file. Use
the less command and then the slash character (/) to search the file. Press n to move to
the next entry that matches the search. Press q to quit the less command

```sh
[root@servera ~]# less /var/log/messages
...output omitted...
Apr 1 15:27:15 servera systemd[1]: Starting Postfix Mail Transport Agent...
...output omitted...
Apr 1 15:27:16 servera systemd[1]: Started Postfix Mail Transport Agent.
...output omitted...
/Postfix
```


Use the ps aux command to confirm that the postfix server is currently running. Use
the grep command to limit the output to the necessary lines


```sh
[root@servera ~]# ps aux | grep postfix
root 3123 0.0 0.2 38172 4384 ? Ss 15:27 0:00 /usr/
libexec/postfix/master -w
postfix 3124 0.0 0.4 45208 8236 ? S 15:27 0:00 pickup -l -t
 unix -u
postfix 3125 0.0 0.4 45252 8400 ? S 15:27 0:00 qmgr -l -t unix
 -u
root 3228 0.0 0.1 221668 2288 pts/0 S+ 15:55 0:00 grep --
color=auto postfix
```

Confirm that the qmgr, cleanup, and pickup queues are correctly configured. Use the
grep command -e option to match multiple entries in the same file. The /etc/postfix/
master.cf file is the configuration file


```sh
[root@servera ~]# grep -e qmgr -e pickup -e cleanup /etc/postfix/master.cf
pickup unix n - n 60 1 pickup
cleanup unix n - n - 0 cleanup
qmgr unix n - n 300 1 qmgr
#qmgr unix n - n 300 1 oqmgr
```


example


|   Command or file | Content requested |
|-------------------|-------------------|
| hostname -f | Get all the output. |
| echo "#####" | Get all the output. |
| lscpu | Get only the lines that start with the string CPU. |
| echo "#####" | Get all the output. |
| /etc/selinux/config | Ignore empty lines. Ignore lines starting with #. |
| echo "#####" | Get all the output. |
| /var/log/secure | Get all "Failed password" entries. |
| echo "#####" | Get all the output. |


```sh
[student@workstation ~]$ vim ~/bin/bash-lab
```

```sh
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
```

```sh
[student@workstation ~]$ bash-lab
```


```sh
[student@workstation ~]$ cat /home/student/output-servera
servera.lab.example.com
#####
CPU op-mode(s): 32-bit, 64-bit
CPU(s): 2
CPU family: 6
#####
SELINUX=enforcing
SELINUXTYPE=targeted
#####
Apr 1 05:42:07 servera sshd[1275]: Failed password for invalid user operator1
 from 172.25.250.9 port 42460 ssh2
Apr 1 05:42:09 servera sshd[1277]: Failed password for invalid user sysadmin1
 from 172.25.250.9 port 42462 ssh2
Apr 1 05:42:11 servera sshd[1279]: Failed password for invalid user manager1 from
 172.25.250.9 port 42464 ssh2
#####
[student@workstation ~]$ cat /home/student/output-serverb
serverb.lab.example.com
#####
CPU op-mode(s): 32-bit, 64-bit
CPU(s): 2
CPU family: 6
#####
SELINUX=enforcing
SELINUXTYPE=targeted
#####
Apr 1 05:42:14 serverb sshd[1252]: Failed password for invalid user operator1
 from 172.25.250.9 port 53494 ssh2
Apr 1 05:42:17 serverb sshd[1257]: Failed password for invalid user sysadmin1
 from 172.25.250.9 port 53496 ssh2
Apr 1 05:42:19 serverb sshd[1259]: Failed password for invalid user manager1 from
 172.25.250.9 port 53498 ssh2
#####
```


## Kullanıcı var mı Yok mu Bakan yoksa oluşturan script


-eq=esittir

-ne=esit degildir

-lt=kucukluk kontrolu

-le=kucukluk veya esitlik

-gt=buyukluk

-ge=buyukluk veya esitlik




```sh
#!/bin/bash
echo -n "eklemek istenen kullanici"
read yeni_kullanici
check_user yeni_kullanici
    if [$? -eq 0]; then
            echo "kullanici zaten mevcut"
        else
            add_user $yeni_kullanici
        fi
check_user(){
    username=$yeni_kullanici
    grep -p "^$yeni_kullanici:" /etc/passwd
    retun $?
}

add_user(){
    username=$yeni_kullanici
    useradd $username
    if [$? -eq 0]; then
        echo "kullanici $username basarili bir sekilde eklendi"
    else
        echo "Kullanici zaten var"
}
```



## Paket yoksa yükleme yapan script


```sh
#!/bin/bash

#kontrol edilecek paket adi

package_name="paket-adi"

#paketin yuklu olup olmadigini kontrol et

rpm -q $package_name > /dev/null

#cikis kodunu kontrol et

if [$? -eq 0]; then
    echo "Paket zaten yuklu"
else
    #paketi yukle
    echo "Paket yukleniyor..."
    yum install $package_name -y
    if [$? -eq 0]; then
        echo "Paket basariyla yuklendi"
    else
        echo "Paket yuklenirken bir hata olustu"
    fi
fi
``` 



## Kullaniciya sudo yetkisi verme veya alma

```sh
#!/bin/bash
username="kullanici"
if grep -q "^$username" /etc/sudoers; then
    echo "kullanicinin zaten sudo yetkisine sahip"
else
    echo "$username ALL=(ALL:ALL) ALL" >> /etc/sudoers
if [$? -eq 0]; then
        echo "kullaniciya sudo yetkisi basariyla verildi"
    else
        echo "Kullaniciya sudo yetkisi verilirken bir hata olustu"
    fi
fi
```













### Provide Output from a Shell Script

çıkış kodları

işlemin doğru mu yanlış olduğunu kontrol için çıkış kodları kullanılır

```sh
#!/bin/bash
directory="/root/test"

if[-z "$(ls -A "$directory")"]; then
    echo "Dizin Bos"

else
    echo "Dizin Dolu"
fi


directory="/etc/test"

if [-d "$directory"]; then
    echo "Dizin Mevcut"
else
    echo "Dizin Mevcut Değil"
```



```sh
if [[ $? -ne 0 ]]; then
```



















