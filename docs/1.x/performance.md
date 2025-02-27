---
title: Performance
---

# Performance

For Relay to perform at it's peak, some configuration directives might need to be adjusted to match your system.

## `relay.locks.*`

The default locking mechanism used for the in-memory cache and allocator is `adaptive-mutex` with a fallback to `mutex` if glibc is not available on the system. 

- `spinlock`: The lowest latency lock which will busy-wait until the lock is available. This is likely the right choice on machines with only a few cores.
- `mutex`: When contention is detected, this lock will sleep until it is available. It has higher latency than a spinlock but uses far less CPU. On machines with many cores it is likely the right choice.
- `adaptive-mutex`: This lock is a hybrid of the two above. When contention is detected it will first spin waiting for the lock to free and then sleep if the lock is still not available. Each time it spins it will update its strategy depending on how long it took. Requires glibc and will fallback to `mutex` if glibc is not available.

## `relay.max_endpoint_dbs`

This directive determines the maximum number of PHP workers with their own in-memory cache. While each PHP worker will have its own connection to Redis, not all workers need their own in-memory cache, and can be read-only workers that read from the shared memory pool. Giving too many workers an in-memory cache can negatively impact performance.

The default of `32` should be adjusted the number of cores or maximum workers, whichever is lower.

```
max_endpoint_dbs = min(cores, pm.max_children)
```

By default `cap_endpoint_dbs` is enabled which will cap `max_endpoint_dbs` to the number of detected CPU cores. When using `spinlock` on a machine with few cores a lower number like `4` will likely perform well.
