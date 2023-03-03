---
title: Events
---

# Events

[TOC]

## Overview

Relay’s in-memory cache is exceptionally fast and reliable, however some scenarios such as long-running processes or highly concurrent applications, event listeners can be used to avoid race conditions and stale caches.

On distributed infrastructures Relay will execute event callbacks roughly `0.1ms` after the key changed in Redis. If a key is deleted or altered using Relay itself, it will perform [client-side invalidation](#client-side-invalidation) and __additionally__ execute event listeners instantaneously on all workers in the same PHP process pool.

Event listeners are executed, after Relay invalidated keys in its in-memory cache.

## Event types

| Event                      | Description                                                        |
| -------------------------- | ------------------------------------------------------------------ |
| `Relay\Event::Flushed`     | Dispatched when the connection’s database was flushed, right after Relay wiped it’s in-memory cache |
| `Relay\Event::Invalidated` | Dispatched when a key that the current instance previously interacted with was deleted or altered in any way, right after Relay removed the key from it’s in-memory cache |

Event listeners can be any PHP `callable` type and are registered using the `listen()`, `onFlushed()` and `onInvalidated()` methods.

```php
use Relay\Event;

$relay->listen(function (Event $event) {
    match ($event->type) {
        Event::Flushed => flushCache(),
        Event::Invalidated => deleteKeyFromCache($event->key),
    };
});
```

It’s worth noting that event listeners are connection specific, which means:

- a connection must be opened before registering any event listeners
- switching databases with `select()` will detach all event listeners
- opening a divergent connection with `connect()` on the same object will detach all event listeners

## Listening for flushes

Application might want to register a distinct callback for `FLUSHDB` and `FLUSHALL` events. This can be accomplished using the `onFlushed()` method:

```php
$relay->onFlushed(fn () => flushCache());
```

## Listening for invalidations

Application may want to register one or more distinct invalidation listeners. This also be accomplished using the `onInvalidated()` method:

```php
$relay->onInvalidated($callback);
```

However, note that **database flushes will not dispatch individual invalidation events** and must be handled separately using `onFlushed()`.

Invalidation event listeners can be restricted to a wildcard match:

```php
$relay->onInvalidated($userCallback, 'users:*');
$relay->onInvalidated($sessionCallback, 'sessions:*');

$relay->onInvalidated(
    match: 'api:*',
    callback: fn ($event) => deleteApiCacheKey($event->key)
);
```

## Multitenancy limitations

Redis' invalidation system is not designed for use with multiple databases and will cause unnecessary flushing of Relay’s memory when more than one database is used.

To bypass most of these limitations, it is important to set a unique prefix for each database. We suggest using the format `db0:`, `db1:` and so on.

```php
$relay = new Relay(
    host: '127.0.0.1',
    database: 4,
    prefix: 'db4:',
);
```

The reason for this is due to Redis' design. Relay isn't aware of the database index when `FLUSHDB` is called and will flush it’s entire memory. If you're curious, read about [the technical details](https://redis.io/docs/manual/client-side-caching/).

## Client-side invalidation

By default, when Relay has a key in its in-memory cache, and the key is deleted or written using Relay, it's instantaneously invalidated for all PHP workers in the same process pool. This is called "client-side invalidation".

This means all PHP workers in the same process pool, will receive __duplicate__ event callbacks. One instantaneous and second one shortly after, once when Relay receives the `INVALIDATE` message from Redis. Workers in other process pools will only receives a single event callback.

If you want to disable this behavior and wait for network round trips, you can disable client-side invalidation callbacks:

```php
$relay->setOption(Relay::OPT_CLIENT_INVALIDATIONS, false);
```

## Manual event dispatching

Despite of PHP’s synchronous nature, Relay will dispatch event callbacks at regular checkpoints during any code execution. In rare scenarios where nanosecond consistency is needed, event callbacks can be triggered manually using the `dispatchEvents()` method, which is extremely fast and memory efficient.

```php
$relay->dispatchEvents();
$relay->get('users:count');
```
