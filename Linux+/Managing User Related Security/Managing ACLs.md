

# Managing ACLs




Use getfacl to see current ACL settings
Use setfacl to manage ACLs
A regular ACL will take care of all currently existing files
A default ACL will take care of all new files
Use ACLs as an infrastructural solution: they should be configured on directories before you start to work with files in these directories 

```sh
setfacl -R -m g:account:rX /data/sales
setfacl -m d:g:account:rx /data/sales
setfacl -x g:account /data/sales

[root@rocky9 data]# ls -l
total 0
drwxr-xr-x. 2 root root 6 Jul  3 21:21 account
drwxr-xr-x+ 2 root root 6 Jul  3 21:16 sales
[root@rocky9 data]# 
[root@rocky9 data]# setfacl -R -m g:account:rx /data/sales
[root@rocky9 data]# getfacl sales/
# file: sales/
# owner: root
# group: root
user::rwx
group::r-x
group:account:r-x
mask::r-x
other::r-x
[root@rocky9 data]# getfacl account/
# file: account/
# owner: root
# group: root
user::rwx
group::r-x
other::r-x

[root@rocky9 data]# setfacl -R -m u:account:rx /data/account
[root@rocky9 data]# getfacl account/
# file: account/
# owner: root
# group: root
user::rwx
user:account:r-x
group::r-x
mask::r-x
other::r-x




```




