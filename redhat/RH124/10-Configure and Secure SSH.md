# Configure and Secure SSH


## Access the Remote Command Line with SSH

Secure Shell Examples


The following ssh command logs you in on the hosta remote server using the same user name
as the current local user. The remote system prompts you to authenticate with the developer1
user's password in this example.

```sh
[developer1@host ~]$ ssh hosta
developer1@hosta's password: redhat
...output omitted...
[developer1@hosta ~]$
```

Use the exit command to log out of the remote system.
```sh
[developer1@hosta ~]$ exit
logout
Connection to hosta closed.
[developer1@host ~]$
```
The following ssh command logs you in on the hosta remote server with the developer2 user
name. The remote system prompts you to authenticate with the developer2 user's password.
```sh
[developer1@host ~]$ ssh developer2@hosta
developer2@hosta's password: shadowman
...output omitted...
[developer2@hosta ~]$
```

The following ssh command runs the hostname command on the hosta remote system as the
developer2 user without accessing the remote interactive shell.

```sh
[developer1@host ~]$ ssh developer2@hosta hostname
developer2@hosta's password: shadowman
hosta.lab.example.com
[developer1@host ~]$
```

This command displays the output in the local system's terminal.
Identifying Remote Users
The w command displays a list of users that are currently logged in to the system. It also displays
the remote system location and commands that the user ran.

```sh
[developer1@host ~]$ ssh developer1@hosta
developer1@hosta's password: redhat
[developer1@hosta ~]$ w
 16:13:38 up 36 min, 1 user, load average: 0.00, 0.00, 0.00
USER TTY FROM LOGIN@ IDLE JCPU PCPU WHAT
developer2 pts/0 172.25.250.10 16:13 7:30 0.01s 0.01s -bash
developer1 pts/1 172.25.250.10 16:24 3.00s 0.01s 0.00s w
```


## SSH Host Keys

The ssh command asks for confirmation to log in when the client does not have a copy of
the public key in its known hosts file. The copy of the public key is saved in the ~/.ssh/
known_hosts file to confirm the server's identity for the future automatically.

```sh
[developer1@host ~]$ ssh hostb
The authenticity of host 'hosta (172.25.250.12)' can't be established.
ECDSA key fingerprint is SHA256:qaS0PToLrqlCO2XGklA0iY7CaP7aPKimerDoaUkv720.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'hostb,172.25.250.12' (ECDSA) to the list of known
 hosts.
developer1@hostb's password: redhat
...output omitted...
[developer1@hostb ~]$
```


Verify the fingerprint of the server's SSH host key by using the following command.

```sh
[developer1@hostb ~]$ ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub
256 SHA256:qaS0PToLrqlCO2XGklA0iY7CaP7aPKimerDoaUkv720 root@server (ECDSA)
```


SSH Known Hosts Key Managemen

The /etc/ssh/ssh_known_hosts file stores the public key file for each user on the SSH client.
Each key consists of one line, where the first field is the list of hostnames and IP addresses that
share the public key. The second field is the encryption algorithm that is used for the key. The last
field is the key itself.

ilk defa ssh bağlantısı yapıldığında uyarı vermesinin sebebi known_hosts dosyasında key bulunmadığında verir. Bu key oluşturulduktan secure bir şekilde bağlantı sağlanmış olur.

[developer1@host ~]$ ssh hostb
The authenticity of host 'hosta (172.25.250.12)' can't be established.
ECDSA key fingerprint is SHA256:qaS0PToLrqlCO2XGklA0iY7CaP7aPKimerDoaUkv720.
Are you sure you want to continue connecting (yes/no)? yes

```sh
[developer1@host ~]$ cat ~/.ssh/known_hosts
hosta,172.25.250.11 ecdsa-sha2-nistp256
 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOsEi0e+FlaNT6jul8Ag5Nj
+RViZl0yE2w6iYUr+1fPtOIF0EaOgFZ1LXM37VFTxdgFxHS3D5WhnIfb+68zf8+w=
```


```sh
[developer1@host ~]$ cat ~/.ssh/known_hosts
hosta,172.25.250.11 ecdsa-sha2-nistp256
 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOsEi0e+FlaNT6jul8Ag5Nj
+RViZl0yE2w6iYUr+1fPtOIF0EaOgFZ1LXM37VFTxdgFxHS3D5WhnIfb+68zf8+w=
```

Each remote SSH server that you connect to stores its public key in a file with the .pub extension
in the /etc/ssh directory.

```sh
[developer1@hosta ~]$ ls /etc/ssh/*key.pub
/etc/ssh/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/
ssh_host_rsa_key.pub
```

# Configure SSH Key-based Authentication

## SSH Key-based Authentication

SSH keygen ile sunuculara şifresiz bağlanma

Use the ssh-keygen command to create a key pair. By default, the ssh-keygen command saves
your private and public keys in the ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub files, but you can
specify a different name.



```sh
#Server A
[operator1@serverb ~]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/operator1/.ssh/id_rsa): Enter
Created directory '/home/operator1/.ssh'.
Enter passphrase (empty for no passphrase): Enter
Enter same passphrase again: Enter
Your identification has been saved in /home/operator1/.ssh/id_rsa.
Your public key has been saved in /home/operator1/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:JainiQdnRosC+xXh operator1@serverb.lab.example.com
The key's randomart image is:
+---[RSA 3072]----+
|E+*+ooo . |
|.= o.o o . |
|o.. = . . o |
|+. + * . o . |
|+ = X . S + |
| + @ + = . |
|. + = o |
|.o . . . . |
|o o.. |
+----[SHA256]-----+
```

```sh
#SERVER B
[operator1@serverb ~]$ ssh-copy-id operator1@servera
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/
operator1/.ssh/id_rsa.pub"
The authenticity of host 'servera (172.25.250.10)' can't be established.
ED25519 key fingerprint is SHA256:h/hEJa/anxp6AP7BmB5azIPVbPNqieh0oKi4KWOTK80.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter
 out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted
 now it is to install the new keys
operator1@servera's password: redhat
Number of key(s) added: 1
Now try logging into the machine, with: "ssh 'operator1@servera'"
and check to make sure that only the key(s) you wanted were added.
```
```sh
[operator1@serverb ~]$ ssh operator1@servera hostname
servera.lab.example.com
```

## Customize OpenSSH Service Configuration

```sh
[root@host ~]# vi /etc/ssh/sshd_config

PermitRootLogin yes

[root@host ~]# systemctl reload sshd

PasswordAuthentication yes

``` 
LAB 325 --> 327


## Share the Public Key

You can specify a specific public key with the ssh-copy-id command, or use the default ~/.ssh/id_rsa.pub file.

```sh
[user@host ~]$ ssh-copy-id -i .ssh/key-with-pass.pub user@remotehost
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/user/.ssh/
id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter
 out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted
 now it is to install the new keys
user@remotehost's password: redhat
Number of key(s) added: 1
Now try logging into the machine, with: "ssh 'user@remotehost'"
and check to make sure that only the key(s) you wanted were added.

```


Test the remote access, after placing the public key, with the corresponding private key. If the
configuration is correct, you will gain access to your account on the remote system without being
asked for your account password. If you do not specify a private key file, then the ssh command
uses the default ~/.ssh/id_rsa file if it exists.

```sh
[user@host ~]$ ssh -i .ssh/key-with-pass user@remotehost
Enter passphrase for key '.ssh/key-with-pass': your_passphrase
...output omitted...
[user@remotehost ~]$
```

## Non-interactive Authentication with the Key Manager


The GNOME graphical desktop environment can automatically start and configure the ssh-agent key
manager. If you log in to a text environment, you must start the ssh-agent program manually for
each session. Start the ssh-agent program with the following command:

```sh
[user@host ~]$ eval $(ssh-agent)
Agent pid 10155
```

The following example ssh-add commands add the private keys from the default ~/.ssh/
id_rsa file and then from a ~/.ssh/key-with-pass file.

```sh
[user@host ~]$ ssh-add
Identity added: /home/user/.ssh/id_rsa (user@host.lab.example.com)
[user@host ~]$ ssh-add .ssh/key-with-pass
Enter passphrase for .ssh/key-with-pass: your_passphrase
Identity added: .ssh/key-with-pass (user@host.lab.example.com)
```

The following ssh command uses the default private key file to access your account on a remote SSH server.

```sh
[user@host ~]$ ssh user@remotehost
Last login: Mon Mar 14 06:51:36 2022 from host.example.com
[user@remotehost ~]$
```

The following ssh command uses the ~/.ssh/key-with-pass private key access your account
on the remote server. The private key in this example was previously decrypted and added to the
ssh-agent key manager, therefore the ssh command does not prompt you for the passphrase to
decrypt the private key.

```sh
[user@host ~]$ ssh -i .ssh/key-with-pass user@remotehost
Last login: Mon Mar 14 06:58:43 2022 from host.example.com
[user@remotehost ~]$
```

## Basic SSH Connection Troubleshooting

SSH can appear complex when remote access using key pair authentication is not succeeding. The
ssh command provides three verbosity levels with the -v, -vv, and -vvv options, that provide
increasingly greater amounts of debugging information during ssh command use.

```sh
[user@host ~]$ ssh -v user@remotehost
#OpenSSH and OpenSSL versions
OpenSSH_8.7p1, OpenSSL 3.0.1 14 Dec 2021 
#OpenSSH configuration files.
debug1: Reading configuration data /etc/ssh/ssh_config 
debug1: Reading configuration data /etc/ssh/ssh_config.d/01-training.conf
debug1: /etc/ssh/ssh_config.d/01-training.conf line 1: Applying options for *
debug1: Reading configuration data /etc/ssh/ssh_config.d/50-redhat.conf
...output omitted...
#Connection to the remote host.
debug1: Connecting to remotehost [192.168.1.10] port 22. 
debug1: Connection established.
...output omitted...
#Authentication methods that the remote host allows.
debug1: Authenticating to remotehost:22 as 'user' 
...output omitted...
#Trying to authenticate the user on the remote host
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-withmic,password 
...output omitted...
#Trying to authenticate the user by using the SSH key.
debug1: Next authentication method: publickey 
debug1: Offering public key: /home/user/.ssh/id_rsa RSA
#Using the /home/user/.ssh/id_rsa key file to authenticate.
 SHA256:hDVJjD7xrUjXGZVRJQixxFV6NF/ssMjS6AuQ1+VqUc4 
debug1: Server accepts key: /home/user/.ssh/id_rsa RSA
#The remote hosts accepts the SSH key.
 SHA256:hDVJjD7xrUjXGZVRJQixxFV6NF/ssMjS6AuQ1+VqUc4 
Authenticated to remotehost ([192.168.1.10]:22) using "publickey".
...output omitted...
[user@remotehost ~]$
```

The next example demonstrates a
remote access with an SSH key that fails, but then the SSH server offers password authentication
that succeeds.

```sh
[user@host ~]$ ssh -v user@remotehost
...output omitted...
debug1: Next authentication method: publickey
debug1: Offering public key: /home/user/.ssh/id_rsa RSA
 SHA256:bsB6l5R184zvxNlrcRMmYd32oBkU1LgQj09dUBZ+Z/k
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-withmic,password
...output omitted...
debug1: Next authentication method: password
user@remotehost's password: password
Authenticated to remotehost ([172.25.250.10]:22) using "password".
...output omitted...
[user@remotehost ~]$
```

## SSH Client Configuration

Consider the following ~/.ssh/config file, which preconfigures two host connections with different users and keys:

```sh
[user@host ~]$ cat ~/.ssh/config
host servera
 HostName servera.example.com
 User usera
 IdentityFile ~/.ssh/id_rsa_servera
host serverb
 HostName serverb.example.com
 User userb
 IdentityFile ~/.ssh/id_rsa_serverb

```

Use the ProxyHost parameter within the ~/.ssh/config file to
connect to the internal host via the external host:

```sh
[user@host ~]$ cat ~/.ssh/config
host internal
 HostName internal.example.com
 ProxyHost external
host external
 HostName external.example.com
```

