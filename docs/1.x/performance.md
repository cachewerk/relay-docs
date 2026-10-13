---
title: Performance
---

# Performance

Relay keeps its shared cache in the PHP master process. PHP workers read it concurrently through a lock-free path, allowing throughput to scale with CPU cores. The directives below tune writes, allocation, and memory cleanup for your system.

Set `relay.flush_batch_size`, `relay.prefault`, and `relay.huge_pages` in your INI configuration before PHP starts, then restart PHP workers to apply changes. These settings cannot be changed with `ini_set()`.

## `relay.max_db_writers`

As of `v0.60.x`, this limits admitted tracking connections per endpoint. It defaults to `4` and is clamped to `1`–`1024`. Each connection has an independent lease, including multiple connections in one PHP worker. Writers share one map and writer lock per Redis database. Connections without admission can read the cache and fall back to Redis, but cannot populate it.

Start with the default and keep this limit at or below the number of CPU cores.

Before `v0.60.x`, this limit applied to writers per cache. When upgrading from multiple endpoint caches, explicitly increase it if needed to preserve total writer capacity, subject to the range and available leases. The old replica limit is not multiplied in automatically.

## `relay.key_leases`

The shared pool of tracking-connection leases across all endpoints defaults to `32`. Size it for the total admitted connections across Redis servers and cluster nodes.

Relay clamps the configured value to `relay.max_db_writers`–`65535`, then rounds the allocated pool up to a power of two, with a minimum of `16` and a maximum of `32768` slots. Higher values do not increase capacity.

For example, four endpoints admitting up to eight tracking connections each need at least 32 slots:

```ini
relay.max_db_writers = 8
relay.key_leases = 32
```

## `relay.locks.*`

`relay.locks.allocator` and `relay.locks.cache` default to `adaptive-mutex`:

- `spinlock`: Busy-waits for the lock. Offers the lowest latency and may suit machines with few cores.
- `mutex`: Blocks without Relay's adaptive spinning. Uses less CPU under contention but has higher latency; may suit machines with many cores.
- `adaptive-mutex`: Spins before blocking, adjusting its spin budget based on contention.

Released versions require glibc for adaptive mutexes and fall back to `mutex` elsewhere. Development builds implement bounded adaptive spinning within Relay without requiring glibc. Both mutex types detect owner death on Linux using robust pthread mutexes in development builds.

## `relay.flush_batch_size`

Flushing immediately removes affected entries from the active cache. Once existing readers can no longer reference them, Relay reclaims their memory in batches. This setting limits cached entries reclaimed per cleanup callback; the default is `1024`, and values below `1` become `1`.

```ini
relay.flush_batch_size = 1024
```

- Smaller batches reduce callback work but retain retired memory longer.
- Larger batches reclaim memory sooner at the cost of more work per callback.

Start with the default and measure latency and memory usage during flushes and repopulation. The limit counts entries, not bytes or time, so it does not guarantee a maximum latency. Reclaimed space is reused within shared memory; flushing does not shrink `relay.maxmemory` or return that allocation to the operating system.

Batching does not delay invalidation. [`Relay\Relay::flushMemory()`](https://docs.relay.so/api/develop/Relay/Relay.html#method_flushMemory) flushes the local cache without deleting Redis data. It covers all existing databases in the requested scope, including those without active writers, and cleanup can continue after it returns.

## `relay.prefault`

Controls how shared memory is faulted in at startup. Defaults to `off`:

- `off`: Fault pages in lazily on first use.
- `populate`: Request kernel prefaulting on Linux. Released versions use `MAP_POPULATE`; development builds use `MADV_POPULATE_WRITE` for writable prefaulting, falling back to `touch` when unavailable or unsuccessful.
- `touch`: Write to every page during startup.

```ini
relay.prefault = populate
```

## `relay.huge_pages`

Available in development builds. Requests transparent huge pages for the shared cache arena on Linux. Defaults to `1` (enabled); set `0` to use ordinary pages for benchmarking or troubleshooting. Has no effect on other platforms.

The host's shared-memory huge-page policy determines whether huge pages are used, so page sizes may vary. Relay applies this setting before prefaulting.

```ini
relay.huge_pages = 1
```

## `relay.max_endpoint_dbs`

Ignored as of `v0.60.x`. Previously limited workers with their own in-memory cache per endpoint. Relay now uses one shared cache per endpoint; see [`relay.max_db_writers`](#relaymaxdbwriters) for writer admission and migration guidance.

## `relay.cap_endpoint_dbs`

Ignored as of `v0.60.x`. Previously capped `relay.max_endpoint_dbs` to the detected CPU core count. See [`relay.max_db_writers`](#relaymaxdbwriters) for current writer admission settings.
