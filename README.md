# docker-sensu

CentOS 7 and sensu.
It runs redis, rabbitmq-server, uchiwa, sensu-api, sensu-server and ssh processes.

## Installation

Install from docker index or build from Dockerfile

```
docker pull venood12/docker-sensu
```

or

```
git clone https://github.com/venoodkhatuva12/Docker-sensu.git
cd Docker-sensu
docker build -t imagename/docker-sensu .
```

## Run

```
docker run -d -p 10022:22 -p 3000:3000 -p 4567:4567 -p 5671:5671 -p 15672:15672 venood12/docker-sensu
```

## How to access via browser and sensu-client

### rabbitmq console

* http://serverip:15672/
* id/pwd : sensu/sensu

### uchiwa

* http://serverip:3000/

### sensu-client

How to configure Sensu client follow as below...

To run sensu-client, create client.json (see example below), then just run sensu-client process.

These are examples of sensu-client configuration.

* /etc/sensu/config.json

```
{
  "rabbitmq": {
    "host": "sensu-server-ip",
    "port": 5671,
    "vhost": "/sensu",
    "user": "sensu",
    "password": "sensu",
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    }
  }
}
```

* /etc/sensu/conf.d/client.json

```
{
  "client": {
    "name": "sensu-client-hostname",
    "address": "sensu-client-ip",
    "subscriptions": [
      "common",
      "web"
    ]
  },
  "keepalive": {
    "thresholds": {
      "critical": 60
    },
    "refresh": 300
  }
}
```

## ssh login

```
ssh sensu@localhost -p 10022
password: sensu
```

## License
FOSS (Free Operation software and source)
