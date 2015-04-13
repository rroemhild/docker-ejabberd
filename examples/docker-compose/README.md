# Docker compose

This example use [Docker Compose][docker_compose] to define a multi-node ejabberd cluster setup with [SkyDNS][skydns] and [etcd][etcd].

[etcd]: https://github.com/coreos/etcd
[skydns]: https://github.com/skynetservices/skydns
[docker_compose]: https://docs.docker.com/compose/

### Build the ejabberd cluster image

```
$ docker-compose build
```

### Start initial containers

```
$ docker-compose up
```

### Add ejabberd nodes to the cluster

Only one node can join the cluster at the same time. Other nodes wait until the join_cluster process is unlocked by the other node.


```
$ docker-compose scale ejabberd=4
```
