---
title: Adaptive Caching
---

# Adaptive Caching

Relay supports an adaptive caching mechanism to only cache keys that meet a read-write ratio to aid applications that suffer from cache thrashing, e.g. WordPress sites.

The configuration for the adaptive cache is highly individual to an application and should ideally be benchmarked. At the very least match the `width` of the cache to the unique number of keys that exist in the cache.

```php
$relay = new Relay(
    host: 'localhost',
    port: 6379,
    context: [
        'adaptive-cache' => [
            // Number of horizontal cells. Ideally this should scale with the number of unique keys in the database. Supported values: 512 - 2^31.
            'width' => 100_000,

            // Number of vertical cells. Supported values: 1 - 8.
            'depth' => 6,

            // Minimum number of events (reads + writes) before Relay
            // will use the ratio to determine if a key should remain cached.
            // Using a negative number will invert this and Relay won't cache
            // a key until its seen at least that many events for the key.
            'minEvents' => 10,

            // Minimum ratio of reads to writes of a key to remain
            // cached (positive events) or be cached (negative events).
            'minRatio' => 5.0,
        ],
    ],
);
```
