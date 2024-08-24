# Improve Command-line Productivity

## Write Simple Bash Scripts

```sh
#!/usr/bin/bash
echo "Hello, world"
```
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


##The grep Command 
```sh
ps aux | grep chrony
cat /etc/passwd | grep ogun
less /var/log/messages








LAB 6 --> 8







