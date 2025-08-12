

# Managing File System Attributes

Posix defines a number of attributes that can be used to add security to files

Use chattr to set them and Isattr to get an overview of currently applied attributes

Of all attributes, the immutable (i) attribute is common 

```sh
[root@rocky9 ~]# touch test1.txt
[root@rocky9 ~]# chattr +i test1.txt 
[root@rocky9 ~]# rm -f test1.txt 
rm: cannot remove 'test1.txt': Operation not permitted
[root@rocky9 ~]#
[root@rocky9 ~]# lsattr
---------------------- ./anaconda-ks.cfg
----i----------------- ./test1.txt

[root@rocky9 ~]# chattr -i test1.txt 
[root@rocky9 ~]# lsattr
---------------------- ./anaconda-ks.cfg
---------------------- ./test1.txt


```




