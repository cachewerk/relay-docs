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

Cluster connections also support a [per-node read timeout](#cluster-read-timeouts) and [health-check backoff](#cluster-health-checks). Their timeout and delay values use seconds; the `OPT_BACKOFF_BASE` and `OPT_BACKOFF_CAP` values above use milliseconds.

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
$relay->endpointId(); // "tcp://default@localhost:6379?cache=0"
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

### Cluster read timeouts

Using `OPT_NODE_READ_TIMEOUT` can shorten the wait for a slow node during distributed or failover reads. Pair it with the [distribution and failover options](/docs/1.x/options#optdistribute) to allow another node to serve the read:

```php
use Relay\Cluster;

$cluster = new Cluster(
    name: null,
    seeds: ['127.0.0.1:7000'],
    connect_timeout: 1.0,
    command_timeout: 2.0,
);

$cluster->setOption(Cluster::OPT_FAILOVER, Cluster::FAILOVER_REPLICAS);
$cluster->setOption(Cluster::OPT_NODE_READ_TIMEOUT, 0.1);
```

With replicas available, this configuration allows a read that times out on the primary after 100 milliseconds to be retried on a replica. The per-node budget is clipped to the remaining command timeout. Several node attempts can contribute to the total time spent on a read. The connection timeout still governs establishing connections; the per-node option does not replace it.

The default per-node timeout is `0.0`, disabling the override. It applies to individual readonly commands when distribution or failover is enabled, outside pipelines and transactions. Writes retain their normal timeout behavior. You can change the option on an existing cluster object before issuing further reads.

### Cluster health checks

Relay uses configurable backoff when checking unhealthy nodes. A node that exceeds its per-node read timeout is marked unhealthy. When selecting replicas for distribution or failover, Relay skips unhealthy nodes until they are eligible for another health check.

Checks happen as part of node selection after the delay has elapsed. A failed check schedules another attempt using the configured backoff; a successful check restores the node and resets its failure history. The per-node timeout also bounds health-check work, including reconnecting during a check, so probing an unhealthy replica can be cut short before trying another candidate.

The default configuration uses exponential backoff with equal jitter:

```ini
relay.cluster.shard_health_wait_base = 1
relay.cluster.shard_health_wait_cap = 60
relay.cluster.shard_health_wait_strategy = equal-jitter
relay.cluster.shard_health_wait_time = 0
```

The base and cap are in **seconds**. With these defaults, the delay is chosen randomly between half the current exponential ceiling and that ceiling: initially 0.5–1 seconds, then 1–2 seconds, then 2–4 seconds, up to 30–60 seconds. This spreads out repeated checks while allowing recovered nodes to return to service. The delay determines when another check is eligible; it is not a sleep added to every command or the time limit for the check itself.

| Strategy | Delay behavior |
| --- | --- |
| `equal-jitter` | Random delay between half the exponential ceiling and the ceiling, bounded by the cap. This is the default setting. |
| `full-jitter` | Random delay from zero to the exponential ceiling, bounded by the cap. |
| `exponential` | Exponentially increasing delay up to the cap, without jitter. |
| `decorrelated-jitter` | Random delay between the base and three times the previous delay, with the upper bound limited to the cap. |
| `constant` | Fixed delay equal to the base. |
| `uniform` | Random delay from zero to the base on every attempt. |
| `default` | Random delay from zero to the base initially, then the base on subsequent attempts. |

Use a positive base and a cap at least as large as the base. Relay substitutes `1` for a nonpositive base and raises a smaller cap to the base.

The existing `relay.cluster.shard_health_wait_time` setting remains as a compatibility override. A positive value forces a fixed delay in seconds and takes precedence over all three backoff settings. Leave it at `0` to use the new regime; `0` does not disable health checks. Negative values also select the backoff settings.

These INI settings can be changed at runtime and are read when Relay schedules the next health check. A change does not reschedule a check that is already pending. They are separate from the connection retry options `OPT_BACKOFF_BASE`, `OPT_BACKOFF_CAP`, and `OPT_BACKOFF_ALGORITHM`.

### Cluster databases

Cluster mode traditionally supports only a single database. Valkey 9.0 lifted that restriction, and `Relay\Cluster` supports it when the server does.

```php
$cluster->select(1);
$cluster->getDbNum(); // 1
```

`select()` is broadcast to every node in the cluster, so the whole connection moves to the new database at once. If it fails on any node, Relay reverts every node back to the previously selected database, leaving the connection in a consistent state rather than partially switched.
