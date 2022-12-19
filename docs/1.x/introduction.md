---
title: Introduction
---

# Introduction

Relay is a PHP extension, that is a drop-in replacement for [PhpRedis](https://github.com/phpredis/phpredis) as well as a shared in-memory cache like APCu.

It allows PHP to interact with Redis just like PhpRedis does, however all retrieved keys are also held in PHP’s memory, which is shared across all FPM workers.

That means if Worker 1 fetches the `users:count` key from Redis, Worker 2, 3, ... __can instantaneously retrieve that key from Relay, without having to communicate with Redis__.

```php
$redis = new Relay;
$redis->connect('127.0.0.1', 6379);

// Only retrieve key from Redis, if it isn’t in Relay’s memory
$users = $redis->get('users:count');
```

To prevent its cache from going stale, Relay uses *server-assisted client side caching* to actively invalidate its in-memory cache. Meaning, __Relay will instantaneously know when the dataset on Redis changes__ and invalidate its local cache.

```php
$redis = new Relay('127.0.0.1', 6379);

// Retrieve key from Relay’s memory
$users = $redis->get('users:count'); // 42

// Relay will instantaneously delete its copy of `users:count`
shell_exec('redis-cli SET users:count 47');

// This call will retrieve the key from Redis (not Relay)
$users = $redis->get('users:count'); // 47
```

Furthermore, Relay offers [event listeners](/docs/1.x/events) to update your application runtime caches mid-request, or prevent data in long-running processes from going stale.

```php
$redis = new Relay('127.0.0.1', 6379);

App::setUserCount($redis->get('users:count'));

$relay->onInvalidated(function ($event) {
    if ($event->key === 'users:count') {
        $users = App::setUserCount(null);
    }
});
```

To use Relay as a faster alternative to PhpRedis/Predis, in-memory caching can of course be disabled globally or per instance.

Continue to the [installation instructions](/docs/1.x/installation).
