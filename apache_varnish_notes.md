# Apache notes

# prerequisites
## clients
3 clients needed

dependencies: sudo apt install apache2-utils

## server

1. ensure client1 & 2 & 3 are in known_hosts

2. config ~/.ssh/config

Example:

```
Host client1
  HostName c220g5-110906.wisc.cloudlab.us
  User gongxini

Host client2
  HostName c220g5-110904.wisc.cloudlab.us
  User gongxini

Host client3
  HostName c220g5-110917.wisc.cloudlab.us
  User gongxini
```

3. set envvar SERVER_NODE

Example:

```
echo 'export SERVER_NODE=c220g5-110989.wisc.cloudlab.us >> ~/.bashrc'
```

# Varnish notes

1. Need to compile both varnish and httpd

```
cd varnish
./compile.sh

cd httpd # inside varnish/
./compile.sh
```
