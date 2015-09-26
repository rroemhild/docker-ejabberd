# rroemhild/ejabberd

- [Introduction](#introduction)
    - [Version](#version)
- [Quick Start](#quick-start)
- [Usage](#usage)
    - [Persistence](#persistence)
    - [SSL Certificates](#ssl-certificates)
    - [Base Image](#base-image)
    - [Run as root](#run-as-root)
    - [Cluster Example](#cluster-example)
- [Runtime Configuration](#runtime-configuration)
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

Dockerfile to build an [ejabberd](https://www.ejabberd.im/) container image.

## Version

Current Version: `15.07`

Docker Tag Names are based on ejabberd versions in git [branches][] and [tags][]. The image tag `:latest` is based on the master branch.

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
    -e "EJABBERD_ADMIN=admin@example.de admin2@example.de" \
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

Make sure that the certificate and private key are in one `.pem` file. If one file is missing it will be auto-generated. I.e. you can provide your certificate for your `XMMP_DOMAIN` and use a snake-oil certificate for the `SERVER_HOSTNAME`.

2. Specify the certificates via environment variables: `SSLCERT_HOST` and `SSLCERT_EXAMPLE_COM`. For the
domain certificates, make sure you match the domain names given in `XMPP_DOMAIN`.

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

## XMPP_DOMAIN

By default the container will serve the XMPP domain `localhost`. In order to serve a different domain at runtime, provide the `XMPP_DOMAIN` variable with a domain name. You can add more domains separated with whitespace.

```
XMPP_DOMAIN=example.ninja xyz.io test.com
```

## EJABBERD_ADMIN

Set one or more admin user (seperated by whitespace) with the `EJABBERD_ADMIN` environment variable. You can register admin users with the `EJABBERD_USERS` environment variable during container startup, use you favorite XMPP client or the `ejabberdctl` command line utility.

```
EJABBERD_ADMIN=admin@example.ninja
```

## EJABBERD_USERS

Automatically register users during container startup. Uses random password if you don't provide a password for the user. Format is `JID:PASSWORD`. Register more users separated with whitespace.

Register the admin user from `EJABBERD_ADMIN` with a give password:

```
EJABBED_USERS=admin@example.ninja:password1234
```

Or without a random password printed to stdout (check container logs):

```
EJABBERD_USERS=admin@example.ninja
```

Register more than one user:

```
EJABBED_USERS=admin@example.ninja:password1234 user1@test.com user1@xyz.io
```

## LOGLEVEL

By default the loglevel is set to INFO (4).

```
loglevel: Verbosity of log files generated by ejabberd.
0: No ejabberd log at all (not recommended)
1: Critical
2: Error
3: Warning
4: Info
5: Debug
```

## ERLANG_NODE

By default the erlang node name is set to `ejabberd@localhost`. If you want to set the erlang node name to hostname provide the `ERLANG_NODE` variable such as:

```
ERLANG_NODE=ejabberd
```

## ERLANG_COOKIE

By default the erlang cookie is generated when ejabberd starts and can't find the `.erlang.cookie` file in $HOME. To set your own cookie provide the `ERLANG_COOKIE` variable with your cookie such as:

```
ERLANG_COOKIE=YOURERLANGCOOKIE
```

## ERL_OPTIONS

With `ERL_OPTIONS` you can overwrite additional options passed to erlang while starting ejabberd.

## AUTH_METHOD

Set the `AUTH_METHOD` variable to enable `anonymous`:

```
AUTH_METHOD=anonymous
```

## EJABBERD_STARTTLS

Set to false to disable StartTLS for client to server connections:

```
EJABBERD_STARTLS=false
```

## EJABBERD_S2S_SSL

Set to false to disable SSL in server 2 server connections:

```
EJABBERD_S2S_SSL=false
```

## EJABBERD_WEB_ADMIN_SSL

If your proxy terminates SSL you may want to disable HTTPS:

```
EJABBERD_WEB_ADMIN_SSL=false
```

## EJABBERD_MOD_MUC_ADMIN

Activate the mod_muc_admin module:

```
EJABBERD_MOD_MUC_ADMIN=true
```

## EJABBERD_REGISTER_TRUSTED_NETWORK_ONLY

Only allow user registration from the trusted_network access rule (loopback):

```
EJABBERD_REGISTER_TRUSTED_NETWORK_ONLY=true
```

## SKIP_MODULES_UPDATE

If you do not need to update ejabberd modules specs, skip the update task and speedup start.

```
SKIP_MODULES_UPDATE=true
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
