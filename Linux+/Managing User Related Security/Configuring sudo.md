


# Configuring sudo


Easy sudo access is configured by adding users to the wheel group (Red Hat family) or the sudo group (Ubuntu family)

More advanced options can be configured using visudo

visudo writes to the /etc/sudoers file 


## Managing sudo Token Validity

Sometimes, NOPASSWD is added to the line that enables sudo to allow using it with entering a password - which is insecure

After entering the sudo password, a token is generated

This token enables the same user to run additional sudo commands without having to enter a password every time 

By default, this token expires after a few minutes and the user needs to enter the password again

Use Defaults timestamp_type=global,timestamp_timeout=60 to extend the token validity 


## Configuring sudo Drop-in Files

Instead of writing directly to /etc/sudoers, drop-in files can be added to /etc/sudoers.d/ In these drop-in files, sudo configuration for individual users and/or groups can be added

. linda ALL=/usr/bin/passwd, ! /usr/bin/passwd root

. lisa ALL=(ALL) NOPASSWD: ALL  



## Using sudoedit

From a regular editor like vim, the :shell command can be used to open a shell

While doing this from a sudo vim session, this shell is a child to the sudo vim session and for that reason opens a root shell 

To prevent users from having unlimited shell access in this way, better use sudoedit instead of a regular editor 

To activate sudoedit, include it in the sudo configuration:

. linda ALL=sudoedit, ! sudoedit sudoers 

Next, the user can just run sudoedit (without sudo in front of it) 