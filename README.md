# squid-docker

Docker image of squid based on a bookworm debian-slim image.

This repository is intended for configuring a proxy using squid.

## Build 

```
make 
```

## Configuration

It's recommended to use docker compose to run this application

Use the provided docker-compose.yml or create `docker-compose.yml` file:
```
version: '3.7'
services:
    squid:
        image: jinwoo/squid
        container_name: squid-proxy
        network_mode: host
        ports:
            - "3128:3128"  
        volumes:
            - ./conf:/conf/
            - ./logs:/var/log/squid
            - ./certs:/certs
        restart: unless-stopped
        ulimits:
            nofile:
                soft: 20480
                hard: 20480
```

Run the application
```
docker-compose up -d
```

Alternatively, you can simply execute it using the following command. 

```
docker run  --network host -d -it jinwoo/squid:6.9
```

## Apply changes on squid.conf

change the default configuration in `./conf/squid.conf`

### Check the configuration
```
docker exec squid bash -c "/usr/sbin/squid -f /conf/squid.conf -k parse"
```
### Apply the configuration
```
docker exec squid bash -c "/usr/sbin/squid -f /conf/squid.conf -k reconfigure"
```

or 

```
kill -HUP $(pgrep squid)
```

### How to test

With the forward proxy settings, you can verify that the outgoing IP has changed.


```
$ curl https://ifconfig.co
222.222.222.222

$ HTTPS_PROXY=http://10.10.1.23:3128 curl https://ifconfig.co
10.10.1.23
```
