# Analyze and Manage Remote Servers

Activate the web console management interface to remotely manage and monitor the
performance of a Red Hat Enterprise Linux server.

## Describe the Web Console
The web console is a web-based management interface for Red Hat Enterprise Linux, which is
designed for managing and monitoring your servers, and is based on the open-source Cockpit
service.
You can use the web console to monitor system logs and to view graphs of system performance.
Additionally, you can use your web browser to change settings by using graphical tools in the web
console interface, including a fully-functional interactive terminal session.


## Enable the Web Console

Starting from Red Hat Enterprise Linux 7, the web console is installed by default in all installation
variants except a minimal installation. You can use the following command to install the web
console:

```sh
[root@host ~]# dnf install cockpit
```

Then, enable and start the cockpit.socket service, which runs a web server. This step is
necessary if you need to connect to the system through the web interface.

```sh
[root@host ~]# systemctl enable --now cockpit.socket
Created symlink /etc/systemd/system/sockets.target.wants/cockpit.socket -> /usr/
lib/systemd/system/cockpit.socket.
```

If you are using a custom firewall profile, then you must add the cockpit service to firewalld
to open port 9090 in the firewall:

```sh
[root@host ~]# firewall-cmd --add-service=cockpit --permanent
success
[root@host ~]# firewall-cmd --reload
success

```
## Log in to the Web Console


The web console provides its own web server. Launch your web browser to log in to the web
console. You can log in with the username and password of any local account on the system,
including the root user.
Open https://servername:9090 in your web browser, where servername is the hostname or
IP address of your server. The web console protects the connection by a Transport Layer Security
(TLS) session. By default, the cockpit service installs the web console with a self-signed TLS
