---
title: Connections
---

# Connections

[TOC]

For the most part, Relay can be used just like PhpRedis. There are [some exceptions](/docs/1.x/compatibility).

```php
$redis = new Relay;
$redis->connect('127.0.0.1', 6379);
$redis->auth('secret');
```

Relay additionally does connection pooling and __shares socket connections__ to Redis within the same worker process when possible.

## Authentication

Given that all of Relay’s connections are persistent, it has to store passwords in memory. To protect against side-channel attacks, all secrets are encrypted with the [XTEA block cipher](https://en.wikipedia.org/wiki/XTEA), and decoded only when needed for authentication/re-authentication.

To authenticate, use the `auth()` method:

```php
$relay = new Relay;
$relay->connect('localhost', 6379);
$relay->auth('password');

// When using Redis 6 ACLs:
$relay->auth(['username', 'password']);
```

When using Relay’s modern syntax, use the `context` parameter:

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

In some cases it may be useful to disable Relay’s in-memory cache and have it just act like a faster PhpRedis, even when Relay did [create a shared memory](/docs/1.x/configuration#disabling-the-cache-globally).

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
