# rroemhild/ejabberd

- [Introduction](#introduction)
    - [Version](#version)
- [Quick Start](quick-start)
- [Usage](#usage)
    - [Persistence](#persistence)
    - [SSL Certificates](#ssl-certificates)
    - [Base Image](#base-image)
    - [Run as root](#run-as-root)
    - [Cluster Example](#cluster-example)
- [Runtime Configuration](#runtime-configuration)
    - [Served Hostnames](#served-hostnames)
    - [Authentication](#authentication)
    - [Admins](#admins)
    - [Users](#users)
    - [SSL](#ssl)
    - [Erlang](#erlang)
    - [Modules](#modules)
    - [Logging](#logging)
- [Maintenance](#maintenance)
    - [Register Users](#register-users)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)
- [Debug](#debug)
    - [Erlang Shell](#erlang-shell)
    - [System Shell](#system-shell)
    - [System Commands](#system-commands)
- [Exposed Ports](#exposed-ports)

# Introduction

Dockerfile to build an [ejabberd](http://ejabberd.im) container image.

## Version

Current Version: `15.07`

Docker Tag Names are based on ejabberd versions in git [branches][branches] and [tags][tags]. The image tag ```:latest``` is based on the master branch.

[tags]: https://github.com/rroemhild/docker-ejabberd/tags
[branches]: https://github.com/rroemhild/docker-ejabberd/branches

# Quick Start

You can start of with the following container:

```bash
docker run -d \
    --name "ejabberd" \
    -p 5222:5222 \
    -p 5269:5269 \
    -p 5280:5280 \
    -h 'xmpp.example.de' \
    -e "XMPP_DOMAIN=example.de" \
    -e "ERLANG_NODE=ejabberd" \
    -e "EJABBERD_ADMINS=admin@example.de admin2@example.de" \
    -e "EJABBERD_USERS=admin@example.de:password1234 admin2@example.de" \
    -e "TZ=Europe/Berlin" \
    rroemhild/ejabberd
```

or with the [docker-compose](examples/docker-compose/docker-compose.yml) example

```bash
wget https://raw.githubusercontent.com/rroemhild/docker-ejabberd/master/examples/docker-compose/docker-compose.yml
docker-compose up
```

# Usage

## Persistence

For storage of the application data, you can mount volumes at

* `/opt/ejabberd/ssl`
* `/opt/ejabberd/backup`
* `/opt/ejabberd/database`

or use a data container

```bash
docker create --name ejabberd-data rroemhild/ejabberd-data
docker run -d --name ejabberd --volumes-from ejabberd-data rroemhild/ejabberd
```

## SSL Certificates

TLS is enabled by default and the run script will auto-generate two snake-oil certificates during boot if you don't provide your SSL certificates.

To use your own certificates, there are two options.

1. Mount the volume `/opt/ejabberd/ssl` to a local directory with the `.pem` files:

* /tmp/ssl/host.pem (SERVER_HOSTNAME)
* /tmp/ssl/xmpp_domain.pem (XMPP_DOMAIN)

Make sure that the certificate and private key are in one `.pem` file. If one file is missing it will be auto-generated. I.e. you can provide your certificate for your **XMMP_DOMAIN** and use a snake-oil certificate for the `SERVER_HOSTNAME`.

2. Specify the certificates via environment variables: **SSLCERT_HOST** and **SSLCERT_EXAMPLE_COM**. For the
domain certificates, make sure you match the domain names given in **XMPP_DOMAIN**.

## Base Image

Build your own ejabberd container image and add your config templates, certificates or [extend](#cluster-example) it for your needs.

```
FROM rroemhild/ejabberd
ADD ./ejabberd.yml.tpl /opt/ejabberd/conf/ejabberd.yml.tpl
ADD ./ejabberdctl.cfg.tpl /opt/ejabberd/conf/ejabberdctl.cfg.tpl
ADD ./example.com.pem /opt/ejabberd/ssl/example.com.pem
```

If you need root privileges switch to `USER root` and go back to `USER ejabberd` when you're done.

## Run as root

By default ejabberd runs as user ejabberd(999). To run ejabberd as root add the `-u root` argument to `docker run`.

```bash
docker run -d -u root -P rroemhild/ejabberd
```

## Cluster Example

The [docker-compose-cluster](examples/docker-compose-cluster) example demonstrates how to extend this container image to setup a multi-master cluster.

# Runtime Configuration

You can additionally provide extra runtime configuration in a downstream image by replacing the config template `ejabberd.yml.tpl` with one based on this image's template and include extra interpolation of environment variables. The template is parsed by Jinja2 with the runtime environment (equivalent to Python's `os.environ` available as `env`).

## Served Hostnames

By default the container will serve the XMPP domain `localhost`. In order to serve a different domain at runtime, provide the **XMPP_DOMAIN** variable with a domain name. You can add more domains separated with whitespace.

```
XMPP_DOMAIN=example.ninja xyz.io test.com
```

## Authentication

Authentication methods can be set with the **EJABBERD_AUTH_METHOD** environment variable. The default authentication mode is `internal`.

Supported authentication methods:

* anonymous
* internal

Internal and anonymous authentication:

```
AUTH_METHOD=internal anonymous
```

### LDAP Auth

Full documentation http://docs.ejabberd.im/admin/guide/configuration/#ldap.

Connection

- **EJABBERD_LDAP_SERVERS**: List of IP addresses or DNS names of your LDAP servers. This option is required.
- **EJABBERD_LDAP_ENCRYPT**: The value `tls` enables encryption by using LDAP over SSL. The default value is: `none`.
- **EJABBERD_LDAP_TLS_VERIFY**: `false|soft|hard` This option specifies whether to verify LDAP server certificate or not when TLS is enabled. The default is `false` which means no checks are performed.
- **EJABBERD_LDAP_TLS_CACERTFILE**: Path to file containing PEM encoded CA certificates.
- **EJABBERD_LDAP_TLS_DEPTH**: Specifies the maximum verification depth when TLS verification is enabled. The default value is 1.
- **EJABBERD_LDAP_PORT**: The default port is `389` if encryption is disabled; and `636` if encryption is enabled.
- **EJABBERD_LDAP_ROOTDN**: Bind DN. The default value is "" which means ‘anonymous connection’.
- **EJABBERD_LDAP_PASSWORD**: Bind password. The default value is "".
- **EJABBERD_LDAP_DEREF_ALIASES**: `never|always|finding|searching`
   Whether or not to dereference aliases. The default is `never`.

Authentication

- **EJABBERD_LDAP_BASE**: LDAP base directory which stores users accounts. This option is required.
u- **EJABBERD_LDAP_UIDS**: `ldap_uidattr:ldap_uidattr_format` The default attributes are `uid:%u`.
- **EJABBERD_LDAP_FILTER**: RFC 4515 LDAP filter. The default Filter value is undefined.
- **EJABBERD_LDAP_DN_FILTER**: `{ Filter: FilterAttrs }` This filter is applied on the results returned by the main filter. By default ldap_dn_filter is undefined.

## Admins

Set one or more admin user (seperated by whitespace) with the **EJABBERD_ADMINS** environment variable. You can register admin users with the **EJABBERD_USERS** environment variable during container startup, use you favorite XMPP client or the `ejabberdctl` command line utility.

```
EJABBERD_ADMINS=admin@example.ninja
```

## Users

Automatically register users during container startup. Uses random password if you don't provide a password for the user. Format is `JID:PASSWORD`. Register more users separated with whitespace.

Register the admin user from **EJABBERD_ADMINS** with a give password:

```
EJABBERD_USERS=admin@example.ninja:password1234
```

Or without a random password printed to stdout (check container logs):

```
EJABBERD_USERS=admin@example.ninja
```

Register more than one user:

```
EJABBERD_USERS=admin@example.ninja:password1234 user1@test.com user1@xyz.io
```

## SSL

- **EJABBERD_SSLCERT_HOST**: SSL Certificate for the hostname.
- **EJABBERD_SSLCERT_EXAMPLE_COM**: SSL Certificates for XMPP domains.
- **EJABBERD_STARTTLS**: Set to `false` to disable StartTLS for client to server connections. Defaults to `true`.
- **EJABBERD_S2S_SSL**: Set to `false` to disable SSL in server 2 server connections. Defaults to `true`.
- **EJABBERD_WEB_ADMIN_SSL**: If your proxy terminates SSL you may want to disable HTTPS. Defaults to `true`.

## Erlang

- **ERLANG_NODE**: Allows to explicitly specify erlang node for ejabberd. Set to `ejabberd` lets erlang add the hostname. Defaults to `ejabberd@localhost`.
- **ERLANG_COOKIE**: Set erlang cookie. Defaults to auto-generated cookie.
- **ERLANG_OPTIONS**: Overwrite additional options passed to erlang while starting ejabberd.

## Modules

- **EJABBERD_SKIP_MODULES_UPDATE**: If you do not need to update ejabberd modules specs, skip the update task and speedup start. Defaults to `false`.
- **EJABBERD_MOD_MUC_ADMIN**: Activate the mod_muc_admin module. Defaults to `false`.
- **EJABBERD_MOD_ADMIN_EXTRA**: Activate the mod_muc_admin module. Defaults to `true`.
- **EJABBERD_REGISTER_TRUSTED_NETWORK_ONLY**: Only allow user registration from the trusted_network access rule. Defaults to `true`.

## Logging

Use the **EJABBERD_LOGLEVEL** environment variable to set verbosity. Defaults to `4` (Info).

```
loglevel: Verbosity of log files generated by ejabberd.
0: No ejabberd log at all (not recommended)
1: Critical
2: Error
3: Warning
4: Info
5: Debug
```

# Maintenance

The `ejabberdctl` command is in the search path and can be run by:

```bash
docker exec CONTAINER ejabberdctl help
```

## Register Users

```bash
docker exec CONTAINER ejabberdctl register user XMPP_DOMAIN PASSWORD
```

## Creating Backups

Create a backupfile with ejabberdctl and copy the file from the container to localhost

```bash
docker exec CONTAINER ejabberdctl backup /opt/ejabberd/backup/ejabberd.backup
docker cp CONTAINER:/opt/ejabberd/backup/ejabberd.backup /tmp/ejabberd.backup
```

## Restoring Backups

Copy the backupfile from localhost to the running container and restore with ejabberdctl

```bash
docker cp /tmp/ejabberd.backup CONTAINER:/opt/ejabberd/backup/ejabberd.backup
docker exec CONTAINER ejabberdctl restore /opt/ejabberd/backup/ejabberd.backup
```

# Debug

## Erlang Shell

Set `-i` and `-t` option and append `live` to get an interactive erlang shell:

```bash
docker run -i -t -P rroemhild/ejabberd live
```

You can terminate the erlang shell with `q().`.

## System Shell

```bash
docker run -i -t rroemhild/ejabberd shell
```

## System Commands

```bash
docker run -i -t rroemhild/ejabberd env
```

# Exposed Ports

* 5222 (Client 2 Server)
* 5269 (Server 2 Server)
* 5280 (HTTP admin/websocket/http-bind)
* 4560 (XMLRPC)
