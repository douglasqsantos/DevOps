# **Rundeck System Architecture**

Rundeck is a server application you host on a system you designate a central administrative control point. Internally, Rundeck stores job definitions and execution history in a relational database. Output from command and job executions is saved on disk but can be forwarded to remote stores like S3 or Logstash.

Rundeck distributed command execution is performed using a pluggable node execution layer that defaults to SSH but plugins allow you to use other means like MCollective, Salt, WinRM, or your custom method. Rundeck server configuration includes settings to define the outbound user allowed by the remote hosts. Remote machines are not required to make connections back to the server.

![Rundeck System Arch](./imgs/rundeck-system-arch.png)

The Rundeck application itself is a Java-based webapp. The application provides both graphical interface and network interfaces used by the Rundeck shell tools.

Access to the Rundeck application requires a login and password. The default Rundeck installation uses a flat file user directory containing a set of default logins. Logins are defined in terms of a username and password as well as one or more user groups. An alternative configuration to the flat file user directory, is LDAP (e.g., ActiveDirectory) but Rundeck authentication and authorization is customizable via [JAAS](https://en.wikipedia.org/wiki/Java_Authentication_and_Authorization_Service). Users must also be authorized to perform actions like define a job or execute one. This is controlled by an access control facility that reads policy files defined by the Rundeck administrator. Privilege is granted if a user's group membership meets the requirements of the policy.

Two installation methods are supported:
  * System package: RPM and Debian packaging is intended for managed installation and provides robust tools that integrate with your environment, man pages, shell tool set in your path, init.d startup and shutdown.
  * Launcher: The launcher is intended for quick setup, to get you running right away. Perfect for bootstrapping a project or trying a new feature.

Rundeck can also install as a WAR file into an external container like Tomcat.

Assuming the system requirements are met, Rundeck can be installed either from source, system package or via the launcher.

## **Install with apt-get**

Let's add the Rundeck repo to get the deb packages from the official repo.
```bash
echo "deb https://rundeck.bintray.com/rundeck-deb /" | sudo tee -a /etc/apt/sources.list.d/rundeck.list
```

Now we need to import the repository public key
```bash
curl 'https://bintray.com/user/downloadSubjectPublicKey?username=bintray' | sudo apt-key add -
```

Now we are able to update the repository without any gpg issue
```bash
sudo apt-get update
```

As we update the repository now we can install the packages property
```bash
sudo apt-get install rundeck
```

Now we need to start the service just to make sure that everything is working
```bash
sudo systemctl restart rundeckd
```

The rundeck logs by default are located at /var/log/rundeck
```bash
tail -f /var/log/rundeck/service.log
[2020-08-16T18:58:26,011] INFO  rundeckapp.Application - The following profiles are active: production

Configuring Spring Security Core ...
... finished configuring Spring Security Core

[2020-08-16T18:59:08,265] WARN  beans.GenericTypeAwarePropertyDescriptor - Invalid JavaBean property 'exceptionMappings' being accessed! Ambiguous write methods found next to actually used [public void grails.plugin.springsecurity.web.authentication.AjaxAwareAuthenticationFailureHandler.setExceptionMappings(java.util.List)]: [public void org.springframework.security.web.authentication.ExceptionMappingAuthenticationFailureHandler.setExceptionMappings(java.util.Map)]
[2020-08-16T18:59:26,318] INFO  rundeckapp.BootStrap - Starting Rundeck 3.3.1-20200727 (2020-07-27) ...
[2020-08-16T18:59:26,319] INFO  rundeckapp.BootStrap - using rdeck.base config property: /var/lib/rundeck
[2020-08-16T18:59:26,342] INFO  rundeckapp.BootStrap - loaded configuration: /etc/rundeck/framework.properties
[2020-08-16T18:59:26,500] INFO  rundeckapp.BootStrap - RSS feeds disabled
[2020-08-16T18:59:26,511] INFO  rundeckapp.BootStrap - Using jaas authentication
[2020-08-16T18:59:26,527] INFO  rundeckapp.BootStrap - Preauthentication is disabled
[2020-08-16T18:59:26,786] INFO  rundeckapp.BootStrap - Rundeck is ACTIVE: executions can be run.
[2020-08-16T18:59:27,132] WARN  rundeckapp.BootStrap - [Development Mode] Usage of H2 database is recommended only for development and testing
[2020-08-16T18:59:27,657] INFO  rundeckapp.BootStrap - workflowConfigFix973: applying...
[2020-08-16T18:59:27,723] INFO  rundeckapp.BootStrap - workflowConfigFix973: No fix was needed. Storing fix application state.
[2020-08-16T18:59:28,381] INFO  rundeckapp.BootStrap - Rundeck startup finished in 2273ms
[2020-08-16T18:59:28,590] INFO  rundeckapp.Application - Started Application in 68.079 seconds (JVM running for 74.453)
Grails application running at http://localhost:4440 in environment: production
```

## **Nginx Proxy for Rundeck**

We shall configure the Nginx proxy for Rundeck so we control better than access the Rundeck server directly.

Installing the Nginx
```bash
apt update && apt install curl vim git-core nginx -y
```

Let's configure the Nginx with some basic configuration to work without any problem

Now let's create a backup of the nginx configuration file.
```bash
cp -Rfa /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bkp
```

Now let's create our configuration as follows.
```bash
vim /etc/nginx/nginx.conf
#/etc/nginx/nginx.conf
## User that the server runs as
user www-data;
## how many nginx instances actually run
worker_processes auto;
## Where it stores the process ID of the master process.
pid /run/nginx.pid;
 
## defines how the daemon incoming requests at the system level
events {
        ## how many connections a sinble worker thread is allowed to process
        worker_connections 768;
        ## keep accepting connections even though the server hasn't finished handeling incoming connections.
        # multi_accept on;
}
 
## This is where most of your tuning will take place
http {
        ## GLOBAL
        ## Enabling this will increase the speed that nginx can cache, and retreive from cache
        sendfile on;
        ## This option causes nginx to attempt to send it's HTTP response headers in one packet.
        tcp_nopush on;
        ## This disables a buffer that when used with keep-alive connections, can slow things down
        tcp_nodelay on;
        ## Defines the maximum time between keepalive requests from client browsers.
        keepalive_timeout 65;
        ## Defines the maximum size of hash tables. This directly influences cache performance. Higher numbers use more memory, and offer potentially higher performance.
        types_hash_max_size 2048;
        ## Sets the maximum allowed size of the client request body, specified in the “Content-Length” request header field.
        client_max_body_size 60M;
        ## Sets buffer size for reading client request body.
        client_body_buffer_size 128k;
        ## Enables or disables emitting nginx version in error messages and in the “Server” response header field.
        server_tokens off;
        ## Sets the bucket size for the server names hash tables.
        # server_names_hash_bucket_size 64;
        ## Enables or disables the use of the primary server name, specified by the server_name directive, in redirects issued by nginx.
        # server_name_in_redirect off;
        ## Includes mime.types configuration file
        include /etc/nginx/mime.types;
        ## Defines the default MIME type of a response. Mapping of file name extensions to MIME types can be set with the types directive.
        default_type application/octet-stream;
 
        ## Logging Settings
        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

        ## Logging file path
        access_log /var/log/nginx/access.log combined;
        error_log /var/log/nginx/error.log;
 
        ## Gzip Settings
        ## Enables or disables gzipping of responses. 
        gzip on;
        ## Disables gzipping of responses for requests with “User-Agent” header fields matching any of the specified regular expressions.
        gzip_disable "msie6";
        ## Enables or disables inserting the “Vary: Accept-Encoding” response header field if the directives gzip, gzip_static, or gunzip are active
        gzip_vary on;
        ## Enables or disables gzipping of responses for proxied requests depending on the request and response.
        gzip_proxied any;
        ## Sets a gzip compression level of a response. Acceptable values are in the range from 1 to 9. 
        gzip_comp_level 6;
        ## Sets the number and size of buffers used to compress a response. By default, the buffer size is equal to one memory page.
        gzip_buffers 16 8k;
        ## Sets the minimum HTTP version of a request required to compress a response.
        gzip_http_version 1.1;
        ##  Enables gzipping of responses for the specified MIME types in addition to “text/html”.
        gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
 
 
        ## Virtual Host Configs
        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
```

Now we need to disable the default virtual Host
```bash
unlink /etc/nginx/sites-enabled/default
```

Now let's create the proxy for Rundeck
```bash
vim /etc/nginx/sites-available/rundeck.conf
# /etc/nginx/sites-available/rundeck.conf

# Default server configuration
server {

  ## Sets the address and port for IP, or the path for a UNIX-domain socket on which the server will accept requests.
  listen 80;

  ## Sets names of a virtual server
  server_name rundeck.dqs.local;

  # Document Root
  #root /usr/share/nginx/html;

  # Index Page
  #index index.html index.htm;

  # Disable favicon
  location = /favicon.ico {
    log_not_found   off;
  }

  # Disable robots
  location = /robots.txt {
    log_not_found   off;
  }

  # Use a higher keepalive timeout to reduce the need for repeated handshakes
  keepalive_timeout 300; # up from 75 secs default

  ## Redirect all the request to the upstream define in the begin of the file
  location / {
    proxy_pass http://localhost:4440;
    proxy_read_timeout  90;

    proxy_set_header Connection "";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Mitigate httpoxy attack (see README for details)
    proxy_set_header Proxy "";

    }
    
    ## Logging file path
    access_log /var/log/nginx/rundeck-access.log combined;
    error_log /var/log/nginx/rundeck-error.log;
}
```

Now we need to enable the new virtualhost
```bash
ln -s /etc/nginx/sites-available/rundeck.conf /etc/nginx/sites-enabled/rundeck.conf
```

Now let's restart the nginx service to reload the new configuration
```bash
systemctl restart nginx
```

Now let's check if the service is working
```bash
systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2020-08-16 19:01:35 UTC; 3s ago
     Docs: man:nginx(8)
  Process: 7857 ExecStop=/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid (code=exited, status=0/SUCCES
  Process: 7871 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
  Process: 7858 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
 Main PID: 7872 (nginx)
    Tasks: 3 (limit: 2317)
   CGroup: /system.slice/nginx.service
           ├─7872 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
           ├─7873 nginx: worker process
           └─7874 nginx: worker process

Aug 16 19:01:35 chef01 systemd[1]: Starting A high performance web server and a reverse proxy server...
Aug 16 19:01:35 chef01 systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pid: Invalid argument
Aug 16 19:01:35 chef01 systemd[1]: Started A high performance web server and a reverse proxy server.
```

Now we can double check the logs from the rundeck as follows
```bash
tail -f /var/log/nginx/rundeck-*
==> /var/log/nginx/rundeck-access.log <==

==> /var/log/nginx/rundeck-error.log <==
```

Now we need to configure the Rundeck to be able to talk with the Nginx
```bash
vim /etc/rundeck/framework.properties
[...]
framework.server.name = rundeck.dqs.local
framework.server.hostname = rundeck.dqs.local
framework.server.port = 4440
framework.server.url = http://rundeck.dqs.local
```

Now we need to configure the subdomain for grails
```bash
vim /etc/rundeck/rundeck-config.properties
[...]
grails.serverURL=http://rundeck.dqs.local
```

Now we need to restart the rundeck
```bash
systemctl restart rundeckd
```

We can double check the logs until the server is get running
```bash
tail -f /var/log/rundeck/service.log
[2020-08-16T20:43:19,021] INFO  rundeckapp.BootStrap - loaded configuration: /etc/rundeck/framework.properties
[2020-08-16T20:43:19,144] INFO  rundeckapp.BootStrap - RSS feeds disabled
[2020-08-16T20:43:19,144] INFO  rundeckapp.BootStrap - Using jaas authentication
[2020-08-16T20:43:19,155] INFO  rundeckapp.BootStrap - Preauthentication is disabled
[2020-08-16T20:43:19,464] INFO  rundeckapp.BootStrap - Rundeck is ACTIVE: executions can be run.
[2020-08-16T20:43:20,832] INFO  rundeckapp.BootStrap - Rundeck startup finished in 2106ms
[2020-08-16T20:43:21,013] INFO  rundeckapp.Application - Started Application in 77.364 seconds (JVM running for 82.871)
Grails application running at http://localhost:4440 in environment: production
```

We can access the Rundeck GUI at: http://rundeck.dqs.local or by it's ip: http://server_ip


## **Change the Rundeck Login password**

The default login/password for Rundeck is admin/admin and we should change this
```bash
vim /etc/rundeck/realm.properties
[...]
admin:7xpnNXsSVfMUkzvC,user,admin,architect,deploy,build
```

Now we have the username as **admin** and the password as **7xpnNXsSVfMUkzvC**

Now we need to restart the rundeck
```bash
systemctl restart rundeckd.service
```

We can access the Rundeck GUI at: https://rundeck.dqs.local or by it's ip: https://server_ip with username as **admin** and the password as **7xpnNXsSVfMUkzvC**

## **Database Configuration**

**Default database:** When you install the vanilla standalone rundeck configuration, it will use H2, an embedded database. It is convenient to have an embedded database when you are just trying Rundeck or using it for a non-critical purpose. Be aware though that using the H2 database is not considered safe for production because it not reslilient if Rundeck is not shutdown gracefully. When shutdown gracefully, Rundeck can write the data (kept in memory) to disk. If Rundeck is forcefully shutdown, the data can not be guaranteed to be written to file on disk and cause truncation and corruption.

Don't use the H2 embedded database for anything except testing and non-production.

Use an external database service like Mariadb, Mysql, Postgres or Oracle.

## **Using MySQL as a database backend**

Let's install the MySQL server
```bash
apt install mysql-server-5.7 -y
```

After install, run the  **mysql_secure_installation script**. This will let prompt you to set the root password for mysql, as well as disable anonymous access.

Set an appropriate [innodb_buffer_pool_size](https://dev.mysql.com/doc/refman/5.7/en/innodb-buffer-pool-resize.html). MySQL, like many databases, manages its own page cache and the buffer pool size determines how much RAM it can use! Setting this to 80% of the system memory is the common wisdom for dedicated servers, however you may want go higher if your server has more than 32G of RAM.

Now you want to create a database and user access for the Rundeck server.

if it is not running, start mysql with "systemctl start mysql"

Use the 'mysql'commandline tool to access the db as the root user
```bash
mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 6
Server version: 5.7.31-0ubuntu0.18.04.1 (Ubuntu)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

Enter the following command to create the rundeck database
```bash
mysql> create database rundeck;
Query OK, 1 row affected (0.01 sec)
```

Now "grant" access for a new user/password, and specify the hostname the Rundeck server will connect from. If it is the same server, you can use "localhost", if you don't have any ideia how to create a good password please take a look at: [Password Generator](https://passwordsgenerator.net/) to generate a good one.

```bash
mysql> grant ALL on rundeck.* to 'rundeckuser'@'localhost' identified by '.Pd]yH)yA@nHL`7Q';
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

You can then exit from the mysql prompt

Test the access by running
```bash
mysql -u rundeckuser -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 7
Server version: 5.7.31-0ubuntu0.18.04.1 (Ubuntu)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

Now check if you can see the rundeck database
```bash
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| rundeck            |
+--------------------+
2 rows in set (0.00 sec)
```

## **Configure Rundeck to Use MySQL**

Now we need to configure Rundeck to connect to this DB.

Update your **rundeck-config.properties** and configure the datasource:
  * RPM/Debian location: **/etc/rundeck/rundeck-config.properties**
  * Launcher location: **$RDECK_BASE/server/config/rundeck-config.properties**

Let's backup the configuration file
```bash
cp -Rfa /etc/rundeck/rundeck-config.properties /etc/rundeck/rundeck-config.properties.bkp
```

Now let's configure the Database connection as follow
```bash
vim /etc/rundeck/rundeck-config.properties
[...]
dataSource.url = jdbc:mysql://localhost/rundeck?autoReconnect=true&useSSL=false
dataSource.username=rundeckuser
dataSource.password=.Pd]yH)yA@nHL`7Q
dataSource.driverClassName=com.mysql.cj.jdbc.Driver
```

Finally you can restart rundeck. If you see a startup error about database access, make sure that the hostname that the Mysql server sees from the client is the same one you granted access to.
```bash
systemctl restart rundeckd.service
```

NB: autoReconnect=true will fix a common problem where the Rundeck server's connection to Mysql is dropped after a period of inactivity, resulting in an error message: "Message: Can not read response from server. Expected to read 4 bytes, read 0 bytes before connection was unexpectedly lost."

We can double check the tables in the database
```bash
mysql> use rundeck;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------------------+
| Tables_in_rundeck          |
+----------------------------+
| auth_token                 |
| base_report                |
| execution                  |
| job_file_record            |
| log_file_storage_request   |
| node_filter                |
| notification               |
| orchestrator               |
| plugin_meta                |
| project                    |
| rdoption                   |
| rdoption_values            |
| rduser                     |
| referenced_execution       |
| report_filter              |
| scheduled_execution        |
| scheduled_execution_filter |
| scheduled_execution_stats  |
| storage                    |
| webhook                    |
| workflow                   |
| workflow_step              |
| workflow_workflow_step     |
+----------------------------+
23 rows in set (0.01 sec)

mysql>
```

## **Adding Rundeck Nodes**

Lets create the ssh key that will be used by the rundeck to authenticate, on the Rundeck server
```bash
ssh-keygen -t rsa -b 4096 -m PEM -f /var/lib/rundeck/.ssh/id_rsa
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /var/lib/rundeck/.ssh/id_rsa.
Your public key has been saved in /var/lib/rundeck/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:FbAqAeuf8vUJIAGKoBORV2rhvp9v7td7zZ/cAFR2eCg root@chef01
The key's randomart image is:
+---[RSA 4096]----+
|=oo..   ...   oo.|
|*+.=     . .Eoo..|
|=.* .   . . .. . |
| = . . . . .     |
|  + o . S   .    |
|   + +       .   |
|  o o o  .   o.  |
|   + o.o... . +.o|
|    +=+.o .o   +o|
+----[SHA256]-----+
```

Now we need to change the owner and group owner
```bash
chown -R rundeck:rundeck /var/lib/rundeck/.ssh/
```

Now we need to create a directory to store the nodes configuration
```bash
mkdir /var/lib/rundeck/nodes && chown -R rundeck:rundeck
```

Now we need to create the file that will store the information about the node, we can add as many node tags as needed.
```xml
vim /var/lib/rundeck/nodes/debian10.xml
<?xml version="1.0" encoding="UTF-8"?>
<project>
   <node name="debian10" hostname="10.0.0.40" osArch="amd64" osFamily="unix" osName="Linux" osVersion="4.19.0-9-amd64" username="rundeck" sudo-command-enabled="true"/>
</project>
```

Now Fix the permission of the file
```bash
chown rundeck:rundeck /var/lib/rundeck/nodes/debian10.xml
```

Now on the **Node Server** let's create the rundeck user
```bash
useradd -m -s /bin/bash rundeck
```

Now we need to create the directory to store the authorized key
```bash
mkdir  -p /home/rundeck/.ssh
touch /home/rundeck/.ssh/authorized_keys
```

Now we need to configure the permissions
```bash
chown -R rundeck:rundeck /home/rundeck/
chmod 0600 /home/rundeck/.ssh/authorized_keys
```

Now we need to enable the sudo configuration
```bash
vim /etc/sudoers
[...]
# Rundeck
rundeck ALL=(ALL) NOPASSWD: ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d
```

Now we can copy from the Rundeck server /var/lib/rundeck/.ssh/id_rsa.pub to /home/rundeck/.ssh/authorized_keys on the node
```bash
cat /var/lib/rundeck/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC82yocZ97zhcxG6UjSKrJWOhicxPdKU1STYyeaHrZ5L6TJrbJB9bNwJIePDt1RB8NkUSiOHScftpowpxRS9VMeG0Ubby8vrQwFatWRVYIxb8P3SWyGxmNpGpZVC6hK050ZNfD4XfCnp0lv9Gy/rSsdx2bUSE3ciMXo1w20ueTgnabjLlVpyTSp5e1p/leePIm8a1bm/JM7ISs6n3/MR/KYvywwC045b5XDAqip6MpQjpAOAgP/P3jrOkbSrcjBzCAkcdKfB4Cxq3qUb23v8V1c1AFC1MRndFCQbUplLAHfx5OosAPjKqlUu9zy/pE5ZJvYn3gov0heHSulUoKZVv1LZMd47WnRAJ7qNrMd2w+T9ZEcWcFqx/gZOo3kKnlLlMXe6hDQaWze+wqL8nQqlLyKa83XMy/AptUNAJUaur+0599Ht45rgIllqF4gd5YwHj18gppNveYt17HJqKlogfdP54Eds0qXVPGIuCszu/R/mL4soRyHRdq1dHvm67yEZC/is5+LCEdQeEUwe7R9iWMBC1CO74/+oTtkZhlE2A59OlaMJSEnAbn6nBKuE5jvteHHatfDAFWKXB/v6UkxWiXZZR5SBGcomO4I6/EvHcOCgWCAQpwKF+MoTgVg3eGYb/EeiRsviMmp4xW/srT+W5a+fcTTj12USYOHUBtQen5Z+w==
``` 

Now add this content into the Node
```bash
vim /home/rundeck/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC82yocZ97zhcxG6UjSKrJWOhicxPdKU1STYyeaHrZ5L6TJrbJB9bNwJIePDt1RB8NkUSiOHScftpowpxRS9VMeG0Ubby8vrQwFatWRVYIxb8P3SWyGxmNpGpZVC6hK050ZNfD4XfCnp0lv9Gy/rSsdx2bUSE3ciMXo1w20ueTgnabjLlVpyTSp5e1p/leePIm8a1bm/JM7ISs6n3/MR/KYvywwC045b5XDAqip6MpQjpAOAgP/P3jrOkbSrcjBzCAkcdKfB4Cxq3qUb23v8V1c1AFC1MRndFCQbUplLAHfx5OosAPjKqlUu9zy/pE5ZJvYn3gov0heHSulUoKZVv1LZMd47WnRAJ7qNrMd2w+T9ZEcWcFqx/gZOo3kKnlLlMXe6hDQaWze+wqL8nQqlLyKa83XMy/AptUNAJUaur+0599Ht45rgIllqF4gd5YwHj18gppNveYt17HJqKlogfdP54Eds0qXVPGIuCszu/R/mL4soRyHRdq1dHvm67yEZC/is5+LCEdQeEUwe7R9iWMBC1CO74/+oTtkZhlE2A59OlaMJSEnAbn6nBKuE5jvteHHatfDAFWKXB/v6UkxWiXZZR5SBGcomO4I6/EvHcOCgWCAQpwKF+MoTgVg3eGYb/EeiRsviMmp4xW/srT+W5a+fcTTj12USYOHUBtQen5Z+w==
```

Now from the Rundeck server let's try the connection
```bash
ssh -i /var/lib/rundeck/.ssh/id_rsa rundeck@10.0.0.40
The authenticity of host '10.0.0.40 (10.0.0.40)' can't be established.
ECDSA key fingerprint is SHA256:yPMN15GBfrqIzQmnWMuTGeiOPiouMHrGpJhrnhfeW50.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.0.0.40' (ECDSA) to the list of known hosts.
Linux debian10 4.19.0-9-amd64 #1 SMP Debian 4.19.118-2+deb10u1 (2020-06-07) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
rundeck@debian10:~$
```

As we can see the connection is working.

**Now on the Web Interface:**
  * Access Projects
    * Your Project Name
      * Project settings
        * Edit Nodes
          * Select Add a new Node Source +
            * Select Directory
              * In Directory Path: **/var/lib/rundeck/nodes**
              * Click in Save and Save Again

**Now on the Web Interface:**
  * Nodes
    * in Nodes: select All Nodes

**Now on the Web Interface:**
  * Commands
    * in Nodes: debian.*
    * In recent: uname -a
    * select: run on 1 Node

## **Rundeck API**

As I was working with the API searching for documentation about how to solve some problems I found the following [Postman collection](https://documenter.getpostman.com/view/95797/rundeck/7TNfX9k?version=latest#a4238ef3-5d09-6bcd-dca4-0df2adc13d72) it is a great resource to get start with the Rundeck API


## **References**
  * https://docs.rundeck.com/docs/administration/install/system-requirements.html
  * https://docs.rundeck.com/docs/administration/install/linux-deb.html
  * https://docs.rundeck.com/docs/administration/overview/system-architecture.html
  * https://docs.rundeck.com/docs/administration/configuration/database/mysql.html
  * https://docs.rundeck.com/docs/manual/job-workflows.html
  * https://docs.rundeck.com/docs/manual/job-workflows.html#context-variables
  * https://rundeck.github.io/rundeck-cli/
  * https://rundeck.github.io/rundeck-cli/commands/
  * https://rundeck.github.io/rundeck-cli/configuration/
  * https://docs.rundeck.com/docs/api/rundeck-api.html
  * https://docs.rundeck.com/docs/manual/document-format-reference/
  * https://github.com/rundeck/docker-zoo/tree/master/postgres
  * https://nginx.org/en/docs/http/ngx_http_core_module.html
  * https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate
  * https://nginx.org/en/docs/
  * https://yallalabs.com/automation-tool/how-to-configure-nginx-with-ssl-as-a-reverse-proxy-for-rundeck/
  * https://www.freeformatter.com/cron-expression-generator-quartz.html
  * https://tech.davidfield.co.uk/rundeck-3-install-setup-and-an-example-project/
  * https://documenter.getpostman.com/view/95797/rundeck/7TNfX9k?version=latest#a4238ef3-5d09-6bcd-dca4-0df2adc13d72
  * https://tech.davidfield.co.uk/rundeck-3-install-setup-and-an-example-project/
  * https://www.decodingdevops.com/add-node-in-rundeck/