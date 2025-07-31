---
title: Connections
---

# Connections

[TOC]

## Overview

Relay treats all connections as persistent by default, meaning each PHP worker will open its own dedicated connection to Redis/Valkey and it will be reused between invocations.

Establishing connections with Relay can be done just like using PhpRedis:

```php
$redis = new Relay;
$redis->connect('127.0.0.1', 6379);
$redis->auth('secret');
```

## Authentication

Given that all of Relay’s connections are persistent, it has to store Redis credentials in memory. To protect against side-channel attacks, all secrets are encrypted with the [XTEA block cipher](https://en.wikipedia.org/wiki/XTEA), and decoded only when needed for authentication/re-authentication.

To authenticate, use the `auth()` method:

```php
$relay = new Relay;
$relay->connect('localhost', 6379);
$relay->auth('password');

// When using Redis 6 ACLs:
$relay->auth(['username', 'password']);
```

When using Relay’s constructor syntax, use the `context` parameter:

```php
$relay = new Relay(
    host: 'localhost',
    port: 6379,
    context: [
        'auth' => ['username', 'password']
    ],
);
```

## Timeouts, retries and backoff

When establishing a new connection, the timeouts work just like PhpRedis.

- The `timeout` option is used when establishing a connection to Redis
- The `read_timeout` option is used when Relay is reading from Redis Server

However, the `retry_interval` option will be ignored. We suggest using a backoff algorithm and retries:

```php
$relay = new Relay;

$relay->setOption(Relay::OPT_MAX_RETRIES, 5);
$relay->setOption(Relay::OPT_BACKOFF_BASE, 25); // 25ms, similar to `retry_interval`
$relay->setOption(Relay::OPT_BACKOFF_CAP, 1000); // 1s, like the `timeout`
$relay->setOption(Relay::OPT_BACKOFF_ALGORITHM, Relay::BACKOFF_ALGORITHM_DECORRELATED_JITTER);

$relay->connect(host: '127.0.0.1', timeout: 1.0, read_timeout: 1.0);
```

## Client-only connections

In some cases it may be useful to disable Relay’s in-memory cache and have it just act like a faster PhpRedis, even when Relay did [create a shared memory](/docs/1.x/configuration#disabling-the-cache).

Use the `$context` parameter on `connect()` or when constructing a new instance:

```php
$relay = new Relay(
    host: 'localhost',
    port: 6379,
    context: ['use-cache' => false]
);
```

The `endpointId()` will tell you whether a connection uses the in-memory cache:

```php
$relay->endpointId(); // "tcp://default@127.0.0.1:6379?cache=1"
```

## Secure connections

When using secure sockets, ensure that the socket timeout is set to at least one second. Setting the timeout too low can lead to numerous timeouts when the server load is high. Setting it too high can result in your application taking a long time to detect connection issues.

```php
$relay = new Relay(
    host: 'tls://...cache.amazonaws.com',
    port: 19139,
    timeout: 2.5,
    context: [
        'stream' => [
            'verify_peer' => false,
            'verify_peer_name' => false,
        ]
    ],
);
```

## Sentinel

Relay provides the [`Relay\Sentinel`](https://docs.relay.so/api/develop/Relay/Sentinel.html) class to establish connections to [Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) nodes.

```php
$sentinel = new Relay\Sentinel(
    host: 'tls://...compute-1.amazonaws.com',
    auth: 'p4ssw0rd',
);
```

## Cluster

Relay provides the [`Relay\Cluster`](https://docs.relay.so/api/develop/Relay/Cluster.html) class to establish connections to clusters.

In this dynamic topology, where the number of nodes can change over time and data may migrate between nodes, `Relay\Cluster` uses the provided configuration as an initial state. It retrieves the actual configuration from the cluster itself using the `CLUSTER SLOTS` command. To minimize the number of requests to the cluster and enhance performance, Relay stores the cluster topology in an in-memory cache. This cache is updated based on events from the cluster.

```php
$cluster = new Relay\Cluster(
    seeds: [
        'tls://...cache.amazonaws.com',
    ],
);
```

Alternatively clusters can be configured using the [`relay.cluster.*`](/docs/1.x/configuration) ini directives and passing the configured name to the class.

```php
$cluster1 = new Relay\Cluster('pleiades');
```
