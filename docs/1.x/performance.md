---
title: Performance
---

# Performance

For Relay to perform at its peak, some configuration directives might need to be adjusted to match your system.

## `relay.max_endpoint_dbs`

This directive determines the maximum number of PHP workers that will have their own in-memory cache. Not all workers need their own cache — workers without one become read-only workers that read from the shared memory pool. Giving too many workers an in-memory cache can negatively impact performance.

The default of `32` should be tuned to the number of CPU cores or maximum workers, whichever is lower:

```
max_endpoint_dbs = min(vCPUs, pm.max_children)
```

This setting is per connection endpoint (distinct Redis connections), meaning connecting to two separate Redis instances will double the number of workers that have their own cache. See also [`relay.cap_endpoint_dbs`](#relaycap_endpoint_dbs).

## `relay.max_db_writers`

This directive determines the maximum number of writers for a given cache. Writers are PHP workers with a persistent connection to Redis that can write to the cache and manage their own invalidations. Any number of workers can read from any cache.

The default of `4` is a good starting point for most setups. This value should not be larger than the number of cores on the machine.

## `relay.locks.*`

The default locking mechanism used for the in-memory cache and allocator is `adaptive-mutex` with a fallback to `mutex` if glibc is not available on the system. 

- `spinlock`: The lowest latency lock which will busy-wait until the lock is available. This is likely the right choice on machines with only a few cores.
- `mutex`: When contention is detected, this lock will sleep until it is available. It has higher latency than a spinlock but uses far less CPU. On machines with many cores it is likely the right choice.
- `adaptive-mutex`: This lock is a hybrid of the two above. When contention is detected it will first spin waiting for the lock to free and then sleep if the lock is still not available. Each time it spins it will update its strategy depending on how long it took. Requires glibc and will fallback to `mutex` if glibc is not available.

## `relay.cap_endpoint_dbs`

When enabled (the default), Relay will cap `max_endpoint_dbs` to the number of detected CPU cores. This is a sensible safeguard that prevents over-allocation on systems where `pm.max_children` exceeds the core count.

When using `spinlock` on a machine with few cores, a lower `max_endpoint_dbs` value like `4` will likely perform well.
