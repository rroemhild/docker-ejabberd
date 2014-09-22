# docker-ejabberd

[Ejabberd][ejabberd] server version 14.07 with internal and anonymous auth enabled and no SSL, thats all. To control the XMPP server, register an admin user 'admin@localhost' with your prefered XMPP client.

Clone this repo and modify the ejabberd.yml file for your needs and build.

[ejabberd]: http://ejabberd.im

## Usage

### Build

```
$ docker build -t <repo name> .
```

### Run in foreground

```
$ docker run -t -i -p 5222 -p 5269 -p 5280 rroemhild/ejabberd
```

### Run in background

```
$ docker run -d -i -p 5222:5222 -p 5269:5269 -p 5280:5280 rroemhild/ejabberd
```

### Run using fig

```yaml
xmpp:
  image: rroemhild/ejabberd
  environment:
    ERL_OPTIONS: "-noshell" # Avoid attaching a shell, which requires STDIN to be attached, which `fig up` does not do. See https://github.com/docker/fig/issues/480.
```

## Exposed ports

* 5222
* 5269
* 5280

## Runtime configuration

By default the container will serve the XMPP domain `localhost`. In order to serve a different domain at runtime, provide the `XMPP_DOMAIN` variable as such:

```
$ docker run -t -i -p 5222 -p 5269 -p 5280 -e "XMPP_DOMAIN=foo.com" rroemhild/ejabberd
```

You can additionally provide extra runtime configuration in a downstream image by replacing the config template with one based on this image's template

```
ADD ./ejabberd.yml.tpl /opt/ejabberd/conf/ejabberd.yml.tpl
```

and include extra interpolation of environment variables. The template is parsed by Jinja2 with the runtime environment (equivalent to Python's `os.environ` available as `env`).
