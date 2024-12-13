---
title: Options
---

# Options

Relay supports all of PhpRedis' `setOption()` options and comes with its own:

- `OPT_USE_CACHE`
- `OPT_PHPREDIS_COMPATIBILITY`
- `OPT_CLIENT_INVALIDATIONS`
- `OPT_ALLOW_PATTERNS`
- `OPT_IGNORE_PATTERNS`
- `OPT_THROW_ON_ERROR`

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

$redis->set('name', 'Picard');

$relay->hgetall('name'); // false
$relay->setOption(Relay::OPT_THROW_ON_ERROR, true);
$redis->hgetall('name'); // throws `Relay\Exception`
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
- `OPT_PREFIX`
- `OPT_READ_TIMEOUT`
- `OPT_REPLY_LITERAL`
- `OPT_SCAN`
- `OPT_TCP_KEEPALIVE`
