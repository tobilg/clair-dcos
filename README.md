# clair-dcos
A Docker image for running Clair on DC/OS.

## Running on DC/OS

### Prerequisites

Clair needs a running Postgres instance to persist the vulnerability data. Please start a Postgres instance, and note the database name/schema and the credentials.

If you want to expose the Clair service outside of the DC/OS cluster, make sure you have a running instance of marathon-lb.

### Via Marathon application definition

Please replace all the values in `<...>` with the real values. If you don't want to expose the Clair service externally, please omit the `HAPROXY_*` labels.

```javascript
{
  "id": "clair",
  "cpus": 0.5,
  "mem": 1024.0,
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "tobilg/clair-dcos:v1.2.6",
      "network": "HOST"
    }
  },
  "env": {
    "POSTGRES_USER": "<username>",
    "POSTGRES_PASSWORD": "<password>",
    "POSTGRES_DATABASE": "<database>",
    "POSTGRES_HOST": "<databaseHost>",
    "POSTGRES_PORT": "<databasePort>",
    "POSTGRES_TIMEOUT_SECONDS": "30"
  },
  "labels": {
    "HAPROXY_GROUP": "external",
    "HAPROXY_0_VHOST": "<publicSlaveELBHostname>",
    "HAPROXY_0_PORT": "6060"
  },
  "portDefinitions": [
    {
      "port": 0,
      "protocol": "tcp",
      "name": "http",
      "labels": {
        "VIP_0": "clair:6060"
      }
    },
    {
      "port": 0,
      "protocol": "tcp",
      "name": "health-check"
    }
  ],
  "requirePorts": false,
  "healthChecks": [
    {
      "protocol": "HTTP",
      "portIndex": 1,
      "path": "/health",
      "gracePeriodSeconds": 5,
      "intervalSeconds": 20,
      "maxConsecutiveFailures": 3
    }
  ]
}
```

Your service will then be availably internally via the VIP `clair.marathon.l4lb.thisdcos.directory:6060`, or externally on `<externalPublicSlaveHostname>:6060`.

### Via Universe package

You can prepare a `clair.json` file with the installation options. Please replace all the values in `<...>` with the real values.

```javascript
{
  "service": {
    "name": "clair",
    "cpus": 1,
    "mem": 2048
  },
  "basic": {
    "update_interval": 1,
    "api_timeout": 900,
    "cache_size": 16384
  },
  "networking": {
    "enable_external": true,
    "virtual_host": "<publicSlaveELBHostname>",
    "port": 6060
  },
  "postgres": {
    "user": "<username>",
    "password": "<password>",
    "database": "<database>",
    "host": "<databaseHost>",
    "port": <databasePort>,
    "timeout_seconds": 30
  },
  "notifier": {
    "attempts": 3,
    "renotify_interval": 3
  }
}
```

Run the installation with the dcos CLI like this:

```bash
$ dcos package install clair --options=clair.json
```
