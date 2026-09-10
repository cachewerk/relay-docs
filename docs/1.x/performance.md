---
title: Performance
---

# Performance

For Relay to perform at its peak, some configuration directives might need to be adjusted to match your system.

Relay keeps its in-memory replica in the PHP master process and is built around a multi-threaded, lock-free read path: every PHP worker reads from the shared cache concurrently, without blocking on a global lock. This sidesteps the single-threaded bottleneck that often pushes Redis deployments into extra replication or clustering, and lets throughput scale with the number of CPU cores. The directives below tune how that shared memory is sized and partitioned, and which locking primitives Relay uses for writes and allocation.

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
- `adaptive-mutex`: This lock is a hybrid of the two above. When contention is detected it will first spin waiting for the lock to free and then sleep if the lock is still not available. Each time it spins it will update its strategy depending on how long it took. Requires glibc and will fall back to `mutex` if glibc is not available.

## `relay.flush_batch_size`

Relay reclaims flushed cache memory incrementally. Flushing removes the affected data from the active cache, so new reads cannot use those entries. Once existing readers can no longer reference the retired data, Relay frees its entries in batches. This spreads cleanup work across callbacks instead of processing a large cache all at once.

The `relay.flush_batch_size` directive sets the maximum number of cached entries reclaimed per cleanup callback for a flushed database map. It defaults to `1024`; values below `1` are treated as `1`.

```ini
relay.flush_batch_size = 1024
```

Set this directive in your INI configuration before PHP starts and restart PHP workers after changing it. It cannot be changed with `ini_set()`.

- Smaller batches reduce work per callback and can help limit cleanup pauses, but keep retired cache memory allocated for longer.
- Larger batches reclaim more entries per callback, making memory available for reuse sooner at the cost of longer cleanup pauses.

Start with the default and measure application latency and memory usage during cache flushes and repopulation. The batch size counts entries, not bytes or milliseconds, so it does not impose a fixed latency limit. Reclaimed space becomes available within Relay's shared memory allocation; flushing does not shrink `relay.maxmemory` or return that allocation to the operating system.

This setting controls memory cleanup after a flush; it does not delay cache invalidation. For example, [`Relay\Relay::flushMemory()`](https://docs.relay.so/api/develop/Relay/Relay.html#method_flushMemory) flushes Relay's local cache without deleting data from Redis. It covers all existing databases in the requested scope, including those without active writers, while memory reclamation can continue after the call returns.

## `relay.cap_endpoint_dbs`

When enabled (the default), Relay will cap `max_endpoint_dbs` to the number of detected CPU cores. This is a sensible safeguard that prevents over-allocation on systems where `pm.max_children` exceeds the core count.

When using `spinlock` on a machine with few cores, a lower `max_endpoint_dbs` value like `4` will likely perform well.
