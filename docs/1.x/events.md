---
title: Events
---

# Events

[TOC]

## Overview

Relay’s in-memory cache is exceptionally fast and reliable, however some scenarios such as long-running processes or highly concurrent applications can use Relay’s event listeners to avoid race conditions and stale caches.

After invalidating its in-memory cache, Relay will call any registered event listeners. There is a delay of `100μs` (or `0.1ms`) for Redis to inform Relay about invalidations, plus whatever the network latency is.

Relay has two event types:

- The `flushed` event is dispatched when the connection’s database was flushed, right after Relay wiped it’s in-memory cache
- The `invalidated` event is dispatched when a key that the current process previously interacted with was altered in any way, right after Relay removed the key from it’s in-memory cache

Event listeners can be any PHP `callable` type and are registered using the `listen()` method:

```php
$relay->listen(function (\Relay\Event $event) {
    match ($event->type) {
        $event::Flushed => flushCache(),
        $event::Invalidated => deleteFromCache($event->key),
    };
});
```

It’s worth noting that event listeners are connection specific, which means:

- a connection must be opened before registering any event listeners
- switching databases with `select()` will detach all event listeners
- opening a divergent connection with `connect()` on the same object will detach all event listeners

## Listening for flushes

In some cases the application might want to register a distinct flush listener. This can also be accomplished using the `onFlushed()` method:

```php
$relay->onFlushed(callable $callback);
```

## Listening for invalidations

In some cases the application might want to register one or more distinct invalidation listeners. This can also be accomplished using the `onInvalidated()` method:

```php
$relay->onInvalidated(callable $callback);
```

However, note that **database flushes will not dispatch individual invalidation events** and must be handled separately using `onFlushed()`.

Furthermore, invalidation event listeners can be restricted to a wildcard match:

```php
$relay->onInvalidated($callback, 'api:*');

// named arguments for readability
$relay->onInvalidated(
    match: 'api:*',
    callback: fn ($event) => deleteApiCacheKey($event->key)
);
```

## Multitenancy limitations

Redis' invalidation system is not designed for use with multiple databases and will cause unnecessary flushing of Relay’s memory when more than one database is used.

To bypass most of these limitations, it is vital to set a unique prefix for each database connection. We suggest using the format `db0:`, `db1:` and so on.

```php
$relay = new Relay(host: '127.0.0.1', database: 4);
$relay->setOption(Relay::OPT_PREFIX, 'db4:');
```

Unfortunately, due to Redis' design, Relay isn't aware of the database index when `FLUSHDB` is called and will flush it’s entire memory. If you're curious, read about [the technical details](https://redis.io/docs/manual/client-side-caching/).


## Client-side invalidation

By default Relay will perform instantaneous client-side invalidation when a key is changed without waiting for Redis to send us an `INVALIDATE` message. The invalidation occurs only in the same FPM pool.

If you want to disable this behavior and wait for TCP round trips, you can disable this behavior:

```php
$relay->setOption(Relay::OPT_CLIENT_INVALIDATIONS, false);
```

## Manual event dispatching

Despite of PHP’s synchronous nature, Relay will dispatch registered event listeners at regular checkpoints during the execution of userland code.

In some cases you may wish to trigger event callbacks manually, this can be done by calling the `dispatchEvents()` method and is extremely fast and memory efficient.

```php
$relay->dispatchEvents();
$relay->get('users:count');
```
