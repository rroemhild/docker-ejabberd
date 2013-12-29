# docker-ejabberd

[Ejabberd][ejabberd] server version 13.12 with internal and anonymous auth enabled and no SSL. To control the XMPP server, register an admin user 'admin@localhost' with your prefered XMPP client.

Clone this repo and modify the ejabberd.yml file for your needs and build.

[ejabberd]: http://ejabberd.im

## Usage

### Build

```
$ docker build -t <repo name> .
```

### Run

```
$ docker run -t -i -p 5222 -p 5269 -p 5280 <repo name>
```

## Versions

* Erlang 16B3
* Ejabberd 13.10

## Exposed ports

* 5222
* 5269
* 5280
