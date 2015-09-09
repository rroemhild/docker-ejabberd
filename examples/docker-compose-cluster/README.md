# Ejabberd cluster with docker compose

This example uses [dnsdocker](https://github.com/tonistiigi/dnsdock) to discover other nodes and setup a multi-master cluster.

1. Start dnsdocker and the first ejabberd node

```
docker-compose up -d
```

2. Add ejabberd nodes to the cluster

```
docker-compose scale ejabberd 4
```
