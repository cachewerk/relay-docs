---
title: Options
---

# Options

Relay supports all of PhpRedis' `setOption()` options and comes with its own:

- `OPT_USE_CACHE`
- `OPT_CLIENT_INVALIDATIONS`
- `OPT_IGNORE_PATTERNS`
- `OPT_ALLOW_PATTERNS`
- `OPT_PHPREDIS_COMPATIBILITY`

## `OPT_USE_CACHE`

By default Relay will cache keys, however sometimes you may want to instantiate an object that is just a Redis client and faster alternative to PhpRedis, without caching any keys.

```php
$relay = new Relay;
$relay->setOption(Relay::USE_CACHE, false); // set before connecting
$relay->connect(host: '127.0.0.1');
```

## `OPT_ALLOW_PATTERNS`

When `OPT_ALLOW_PATTERNS` is set only keys matching these patterns will be cached, unless they also match a pattern of the `OPT_IGNORE_PATTERNS` option.

```php
$relay->setOption(Relay::OPT_ALLOW_PATTERNS, [
    'sessions:*',
    // ...
]);
```

## `OPT_IGNORE_PATTERNS`

Keys matching these patterns will not be stored in Relay’s in-memory cache.

```php
$relay->setOption(Relay::OPT_IGNORE_PATTERNS, [
    'analytics:*',
    // ...
]);
```

## `OPT_CLIENT_INVALIDATIONS`

By default Relay will perform instantaneous client-side invalidation when a key is changed without waiting for Redis to send us an `INVALIDATE` message. The invalidation occurs only in the same FPM pool.

If you want to disable this behavior and wait for TCP round trips, you can disable this behavior:

```php
$relay->setOption(Relay::OPT_CLIENT_INVALIDATIONS, false);
```

## `OPT_PHPREDIS_COMPATIBILITY`

Relay is [fully compatible](/docs/1.x/compatibility) with PhpRedis. By default however, Relay will return `null` when a key doesn't exist, whereas PhpRedis returns `false`.

```php
$relay = new Relay;
$relay->get('i-do-not-exist'); // `null`
$relay->setOption(Relay::OPT_PHPREDIS_COMPATIBILITY, true);
$relay->get('i-do-not-exist'); // `false`
```

## PhpRedis' options

Relay supports all of PhpRedis' `setOption()` options.

- `OPT_READ_TIMEOUT`
- `OPT_COMPRESSION`
- `OPT_COMPRESSION_LEVEL`
- `OPT_MAX_RETRIES`
- `OPT_BACKOFF_ALGORITHM`
- `OPT_BACKOFF_BASE`
- `OPT_BACKOFF_CAP`
- `OPT_SCAN`
- `OPT_REPLY_LITERAL`
- `OPT_NULL_MULTIBULK_AS_NULL`
