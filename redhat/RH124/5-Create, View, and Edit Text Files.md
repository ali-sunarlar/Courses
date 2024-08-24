# Create, View, and Edit Text Files

## Redirect Output to a File or Program

çıktıyı veya hata bir dosyaya yonlendirmek icin

### Standard Input, Standard Output, and Standard Error


Channels (File Descriptors)

| Number | Channel name    | Description    | Default connection    | Usage    |
|--|--|--|--|--|
| 0 | stdin | Standard input | Keyboard | read only |
| 1 | stdout| Standard output | Terminal | write only |
| 2 | stderr | Standard error | Terminal | write only |
| 3+ | filename | Other files | none | read, write, or both |


### Redirect Output to a File

Output Redirection Operators
| Usage  | Explanation    |
|--|--|
| > file | Redirect stdout to overwrite a file. |
| >> file | Redirect stdout to append to a file. |
| 2> file | Redirect stderr to overwrite a file. |
| 2> /dev/null | Discard stderr error messages by redirecting them to /dev/null. |
| > file 2>&1 | Redirect stdout and stderr to overwrite the same file. |
| &> file | Redirect stdout and stderr to overwrite the same file. |
| >> file 2>&1 | file Redirect stdout and stderr to append to the same file. |
| &>>  | file Redirect stdout and stderr to append to the same file. |



```sh
[root@rocky2 user]# cat /var/log/secure | grep 1345 > 1345.txt
[root@rocky2 ~]# date > /tmp/saved-timestamp
#Copy the last 100 lines from the /var/log/dmesg file to the /tmp/last-100-boot-messages file
[root@rocky2 ~]#  tail -n 100 /var/log/dmesg > /tmp/last-100-boot-messages
#4 dosya tek bir dosyaya
[root@rocky2 ~]# cat step1.sh step2.log step3 step4 > /tmp/all-four-steps-in-one
#List the home directory's hidden and regular file names and save the output to the my-file-names file.
[root@rocky2 ~]# ls -a > my-file-names
#Append a line to the existing /tmp/many-lines-of-information file.
[root@rocky2 ~]# echo "new line of information" >> /tmp/many-lines-of-information
#Redirect errors from the find command to the /tmp/errors file while viewing normal command output on the terminal
[root@rocky2 user]# datet 2>error.txt
[root@rocky2 ~]# find /etc -name passwd 2> /tmp/errors
/etc/passwd
/etc/pam.d/passwd
#Save process output to the /tmp/output file and error messages to the /tmp/errors file
[root@rocky2 ~]# find /etc -name passwd > /tmp/output 2> /tmp/errors
#Save process output to the /tmp/output file and discard error messages.
[root@rocky2 ~]# find /etc -name passwd > /tmp/output 2> /dev/null
#Store output and generated errors together to the /tmp/all-message-output file.
[root@rocky2 ~]# find /etc -name passwd &> /tmp/all-message-output
#Append output and generated errors to the /tmp/all-message-output file
[root@rocky2 ~]# find /etc -name passwd >> /tmp/all-message-output 2>&1

```

ssh yapıldığında hata alınıyor ciktisini output dosyasına atan bash script

```sh
#!/bin/bash
host=("host1" "host2" "host3" ... "host100")
error_output="error.txt"

>"$error_output"

for host in "$(host[@])";do
            echo "connection: $host"

            ssh "$host" "commads" 2> "$hata_ciktisi"

```

#### Pipeline Examples

çıktıyı ekranda bölümlendirerek görünlüleme ok tuşlarına basılarak sonuna doğru ilerlenebilir. q tuşuna basılarak çıkılır

```sh
[root@rocky2 ~]# ls -l /usr/bin | less

total 106836
-rwxr-xr-x. 1 root root    52856 Apr 24  2023 
-rwxr-xr-x. 1 root root    33384 May 16  2022 ac
-rwxr-xr-x. 1 root root    28416 Mar  6 06:54 addr2line
-rwxr-xr-x. 1 root root       33 Jan 24  2023 alias
lrwxrwxrwx. 1 root root       25 Feb 25 20:06 apropos -> /etc/alternatives/apropos
lrwxrwxrwx. 1 root root        6 Apr 15  2023 apropos.man-db -> whatis
-rwxr-xr-x. 1 root root    57328 Mar  6 06:54 ar
-rwxr-xr-x. 1 root root    32224 Apr 24  2023 arch
.
.
.
-rwxr-xr-x. 1 root root   461632 Apr 27  2023 checkmodule
:
```

satır sayısını verir
```sh
[root@rocky2 ~]#  ls | wc -l
13
```

ilk 10 
```sh
[root@rocky2 ~]# ls -t | head -n 10 > /tmp/first-ten-changed-files
```


#### Pipelines, Redirection, and Appending to a File

```sh
[root@rocky2 ~]# ls > /tmp/saved-output | less
[root@rocky2 ~]# ls -t | head -n 10 | tee /tmp/ten-last-changed-files
Documents
dosya1.txt
dosya2.txt
dosya3.txt
dosya4.txt
dosya5.txt
Videos
files
folders
parentfolder
[root@rocky2 ~]# ls -l | tee -a /tmp/append-files
total 16
-rw-------.  1 root root 1425 Feb 25 20:09 anaconda-ks.cfg
drwxr-xr-x. 10 root root 4096 Mar  9 01:37 Documents
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya1.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya2.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya3.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya4.txt
-rw-r--r--.  1 root root    0 Mar  8 23:17 dosya5.txt
drwxr-xr-x.  2 root root 4096 Mar  8 23:12 files
drwxr-xr-x.  2 root root    6 Mar  8 23:11 folders
-rw-r--r--.  1 root root   60 Mar  8 23:07 output.txt
drwxr-xr-x.  4 root root   34 Mar  8 23:07 parentfolder
drwxr-xr-x.  2 root root    6 Mar  6 21:27 serverbackup
drwxr-xr-x.  2 root root   54 Mar  8 23:15 Videos
```


## Edit Text Files from the Shell Prompt



### Edit Files with Vim

Insert Modu

Command Line Modu

Visual Modu bulunur



• The u key undoes the most recent edit.

• The x key deletes a single character.

• The :w command writes (saves) the file and remains in command mode for more editing.

• The :wq command writes (saves) the file and quits Vim.

• The :q! command quits Vim, and discards all file changes since the last write.




• Character mode : v

• Line mode : Shift+v

• Block mode : Ctrl+v


vim konfigurasyon dosyası

cat ~/.vimrc


```
Insert modu için klavyeden "i" tuşuna basilir çıkmak için ESC tuşuna basilir ve command line moduna geçilir. 
klavyeden V tuşuna basılırsa Visual mode'a geçilir ve imlecin hareketine göre seçim imkanı sunar
vi editor'den çıkmak :q! kaydetmeden kaydeterek çıkmak için :wq!
:x ayrıca kaydederek kapatmak için de kullanilir
ctrl + v kısayolu ile bulunduğu satırı seçer
j ile satır değiştirebilirsiniz
b ile kelimenin ilk harfine gidebilirsiniz
:zz kaydet kapat anlamına gelir
/'aramak istediğiniz kelime' yi yazarak dosya içerisinde arama yapabilirsiniz.
arama içerisinde n tuşu ile bir sonraki bulunan kelimeye gidebilirsiniz.
Dosyanın sonundan başına doğru bir arama yapmak istiyorsak
?'aramak istenilen kelime' yi yazarak dosya içerisinde sondan başa doğru arama yapabilirsiniz
Command mode'unda j tuşu imleç satırlar arası geçiş yapar
klavyeden yy yaptığınız takdirde satırı kopyalayacaktır
klavyeden dd yaptığınız takdirde satırı silecektir.
klavyeden pp yaptığınız takdirde satırı yapıştıracaktır
klavyeden gg yaptığınız takdirde satır dosyanın başına gider
set number ile satırlara numara verecektir
set nonumber ile satır numaralarını silebilrsiniz
:split seçeneği ile alt kısımda başka bir txt dosyasını açacaktır
:visplit seçeneği ile yan kısımda başka bir txt dosyasını açacaktır
ayrıştırılmış vi pencerelerinde geçiş yapmak için ctrl+w tuş kombinasyonu kullanılır.
:%s/değiştirmek istediğiniz kelime/yeni kelime tüm kelimeleri değiştirir
:s/degistirilecek_kelime/yeni_kelime bulunduğu satırdaki kelimeleri degistirir
:%s/degistilecek_kelime/yeni_kelime/10 ilk satirdaki kelimeleri degistirir
:%s/degistilecek_kelime/yeni_kelime/g dosyanin icerisindeki butun kelimeleri degistirir
:s/değiştirmek istediğiniz kelime/yeni kelime/g sadece imlecin bulunduğu satırdaki kelimeyi değiştirir.
:set number command line modunda satır numaralarını gösterir
:set nonumber command line modunda satır numaralarını kapatır
:set syntax=on syntax hatalarınu vurgular
:e gecilecek_dosya_path yeni dosyaya geçiş yapmak için
:set list satir sonundaki boşlukları görüntüler
:set nolist satir sonundaki boşlukları görüntülemeyi kapatir
```



## Change the Shell Environment

### Shell Variable Usage

#### Assign Values to Variables

Assign a value to a shell variable with the following syntax:
```sh
[root@rocky2 user]# VARIABLENAME=value
```


Variable names can contain uppercase or lowercase letters, digits, and the underscore character
(_).

```sh
[root@rocky2 user]# COUNT=40
[root@rocky2 user]# first_name=John
[root@rocky2 user]# file1=/tmp/abc
[root@rocky2 user]# _ID=RH123
```

You can use the set command to list all shell variables that are currently set.

```sh
[root@rocky2 user]#  set | less

BASH=/bin/bash
BASHOPTS=checkwinsize:cmdhist:complete_fullquote:expand_aliases:extquote:force_fignore:globasciiranges:histappend:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath
BASHRCSOURCED=Y
BASH_ALIASES=()
BASH_ARGC=([0]="0")
BASH_ARGV=()
BASH_CMDS=()
BASH_LINENO=()
.
.
.
TERM=xterm-256color
UID=0
USER=root
VARIABLENAME=value
_=
_ID=RH123
colors=/root/.dircolors
file1=/tmp/abc
first_name=John
which_declare='declare -f'
which_opt=-f
gawklibpath_append ()

```

#### Retrieve Values with Variable Expansion

```sh
#the following command sets the variable COUNT to 40.
[root@rocky2 user]# COUNT=40
#If you enter the echo COUNT command, then it prints the COUNT string.
[root@rocky2 user]# echo COUNT
COUNT
#If you enter instead the echo $COUNT command, then it prints the value of the COUNT variable.
[root@rocky2 user]# echo $COUNT
40


#You can also use a variable to refer to a long file name for multiple commands.
[root@rocky2 user]# touch /tmp/tmp.z9pXW0HqcC
[root@rocky2 user]# file1=/tmp/tmp.z9pXW0HqcC
[root@rocky2 user]#  rm $file1
rm: remove regular empty file '/tmp/tmp.z9pXW0HqcC'? y
[root@rocky2 user]# ls -l $file1
ls: cannot access '/tmp/tmp.z9pXW0HqcC': No such file or directory


[root@rocky2 user]# echo Repeat $COUNTx
Repeat
[root@rocky2 user]# echo Repeat ${COUNT}x
Repeat 40x
```

#### Configure Bash with Shell Variables

The HISTFILESIZE variable
specifies how many commands to save in that file from the history.

The HISTTIMEFORMAT variable 
defines the time stamp format for every command in the history.

```sh
[root@rocky2 user]# history
    1  ip a
    2  exit
    3  id
    4  pwd
    5  echo $HOME
    6  echo $PATH
    .
    .
    .
  579  touch /tmp/tmp.z9pXW0HqcC
  580  ls -l $file1
  581   rm $file1
  582  ls -l $file1
  583  echo Repeat $COUNTx
  584  echo Repeat ${COUNT}x
  585  history
[root@rocky2 user]# HISTTIMEFORMAT="%F %T "
[root@rocky2 user]# history
    1  2024-03-09 07:43:27 ip a
    2  2024-03-09 07:43:27 exit
    3  2024-03-09 07:43:27 id
    4  2024-03-09 07:43:27 pwd
    5  2024-03-09 07:43:27 echo $HOME
    6  2024-03-09 07:43:27 echo $PATH
    7  2024-03-09 07:43:27 exit
    8  2024-03-09 07:43:27 id
    9  2024-03-09 07:43:27 pwd
    .
    .
    .
  579  2024-03-09 09:13:19 touch /tmp/tmp.z9pXW0HqcC
  580  2024-03-09 09:13:21 ls -l $file1
  581  2024-03-09 09:14:04  rm $file1
  582  2024-03-09 09:14:13 ls -l $file1
  583  2024-03-09 09:15:02 echo Repeat $COUNTx
  584  2024-03-09 09:15:09 echo Repeat ${COUNT}x
  585  2024-03-09 09:17:42 history
  586  2024-03-09 09:17:52 HISTTIMEFORMAT="%F %T "
  587  2024-03-09 09:17:55 history
```













