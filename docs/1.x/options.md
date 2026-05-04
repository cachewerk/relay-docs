---
title: Options
---

# Options

Relay supports all of PhpRedis' `setOption()` constants and comes with its own:

- `OPT_USE_CACHE`
- `OPT_PHPREDIS_COMPATIBILITY`
- `OPT_CLIENT_INVALIDATIONS`
- `OPT_CLIENT_TRACKING`
- `OPT_ALLOW_PATTERNS`
- `OPT_IGNORE_PATTERNS`
- `OPT_THROW_ON_ERROR`
- `OPT_ADAPTIVE_CACHE`
- `OPT_CAPA_REDIRECT`
- `OPT_RESTORE_PUBSUB`

As well as some `Relay\Cluster` specific ones:

- `OPT_DISTRIBUTE`
- `OPT_FAILOVER`
- `OPT_AVAILABILITY_ZONE`


## `OPT_USE_CACHE`

By default Relay will cache keys, however sometimes you may want to instantiate an object that is just a Redis client and faster alternative to PhpRedis, without caching any keys.

```php
$relay = new Relay;
$relay->setOption(Relay::OPT_USE_CACHE, false); // must be set before connecting
$relay->connect();
```

## `OPT_PHPREDIS_COMPATIBILITY`

By default Relay will act exactly like PhpRedis. If desired, Relay can return more precise values and throw exceptions when errors occur. [Read more...](/docs/1.x/compatibility).

## `OPT_CLIENT_INVALIDATIONS`

Applications that can't tolerate duplicate event callbacks can disable client-side invalidation events. [Read more...](/docs/1.x/events).

## `OPT_CLIENT_TRACKING`

Controls whether Redis' client tracking is enabled for the connection. When disabled, Relay writes to its in-memory cache only and won't receive `INVALIDATE` messages from the server, so cached entries will not be invalidated by changes made through other clients.

```php
$relay->setOption(Relay::OPT_CLIENT_TRACKING, false);
```

## `OPT_ALLOW_PATTERNS`

When `OPT_ALLOW_PATTERNS` is set only keys matching the patterns will be stored in Relay’s in-memory cache and trigger invalidation events.
The `OPT_IGNORE_PATTERNS` option may be used in combination with `OPT_ALLOW_PATTERNS` to exclude additional keys from being cached.

```php
$relay->setOption(Relay::OPT_ALLOW_PATTERNS, [
    'sessions:*',
    // ...
]);
```

## `OPT_IGNORE_PATTERNS`

Keys matching these patterns will not be stored in Relay’s in-memory cache and not trigger invalidation events.

```php
$relay->setOption(Relay::OPT_IGNORE_PATTERNS, [
    'analytics:*',
    // ...
]);
```

## `OPT_THROW_ON_ERROR`

You may configure Relay to throw exceptions when read-errors occur, instead of returning `false` like PhpRedis.

```php
$relay = new Relay;

$relay->set('name', 'Picard');

$relay->hgetall('name'); // false
$relay->setOption(Relay::OPT_THROW_ON_ERROR, true);
$relay->hgetall('name'); // throws `Relay\Exception`
```

## `OPT_ADAPTIVE_CACHE`

Configures Relay's adaptive caching mechanism, which only caches keys that meet a configurable read-write ratio. [Read more...](/docs/1.x/adaptive).

## `OPT_CAPA_REDIRECT`

Whether the client is capable of handling [`CLIENT CAPA redirect`](https://valkey.io/commands/client-capa/) messages from the server during failovers and topology changes.

## `OPT_RESTORE_PUBSUB`

Whether Relay should automatically restore active Pub/Sub subscriptions after reconnecting.

## `OPT_DISTRIBUTE`

Controls how readonly commands are distributed across cluster nodes. Defaults to `DISTRIBUTE_NONE`.

Instead of using PhpRedis' legacy `OPT_SLAVE_FAILOVER`, consider using `OPT_DISTRIBUTE` and `OPT_FAILOVER`.

| Value | Description |
| --- | --- |
| `DISTRIBUTE_NONE` | Send readonly commands to the primary node only. |
| `DISTRIBUTE_RANDOM` | Distribute randomly between the primary and its replicas. Stops trying replicas after the first failed attempt. |
| `DISTRIBUTE_RANDOM_REPLICA` | Distribute randomly among replicas only, never the primary. Stops trying replicas after the first failed attempt. |
| `DISTRIBUTE_REPLICAS` | Distribute randomly among replicas only. Iterates through all replicas until it finds a working one. |
| `DISTRIBUTE_ALL` | Distribute between the primary and its replicas. Iterates through all nodes until it finds a working one. |

```php
$cluster->setOption(Cluster::OPT_DISTRIBUTE, Cluster::DISTRIBUTE_REPLICAS);
```

## `OPT_FAILOVER`

Controls the retry strategy when a command fails on a node. Defaults to `FAILOVER_NONE`.

Instead of using PhpRedis' legacy `OPT_SLAVE_FAILOVER`, consider using `OPT_DISTRIBUTE` and `OPT_FAILOVER`.

| Value | Description |
| --- | --- |
| `FAILOVER_NONE` | Don't retry. |
| `FAILOVER_RANDOM_REPLICA` | Retry the readonly command on a randomly selected replica. |
| `FAILOVER_PRIMARY` | Retry the readonly command on the primary node. Only applicable when the failed node is a replica. |
| `FAILOVER_REPLICAS` | Retry the readonly command on all replicas, excluding the failed node. |
| `FAILOVER_ALL` | Retry the readonly command on all other nodes (replicas and primary), excluding the failed node. |

```php
$cluster->setOption(Cluster::OPT_FAILOVER, Cluster::FAILOVER_REPLICAS);
```

## `OPT_AVAILABILITY_ZONE`

Sets a preferred availability zone so cluster reads can be routed to nodes in the same zone, reducing cross-AZ traffic.

```php
$cluster->setOption(Cluster::OPT_AVAILABILITY_ZONE, 'us-east-1a');
```

## PhpRedis options

Relay supports all of PhpRedis' options:

- `OPT_BACKOFF_ALGORITHM`
- `OPT_BACKOFF_BASE`
- `OPT_BACKOFF_CAP`
- `OPT_COMPRESSION_LEVEL`
- `OPT_COMPRESSION`
- `OPT_MAX_RETRIES`
- `OPT_NULL_MULTIBULK_AS_NULL`
- `OPT_PACK_IGNORE_NUMBERS`
- `OPT_PREFIX`
- `OPT_READ_TIMEOUT`
- `OPT_REPLY_LITERAL`
- `OPT_SCAN`
- `OPT_SERIALIZER`
- `OPT_TCP_KEEPALIVE`
