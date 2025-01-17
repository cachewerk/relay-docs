---
title: Configuration
---

# Configuration

Relay provides many configuration directives and the `relay.ini` file can be located by running:

```bash
php --ini
```

It’s recommend to at least adjust the `relay.maxmemory` and `relay.eviction_policy` directives. If you're running a licensed binary, be sure to set the `relay.key` and `relay.environment` as well.

For peak performance the `relay.locks.cache` and `relay.max_endpoint_dbs` values should be benchmarked.

## Memory limits

Relay will allocate what `relay.maxmemory` is set to when PHP starts, even if no `relay.key`. However if no valid license was set, after 60 minutes of runtime, Relay will downsize the allocated memory to its hard limit of 16 MB.

## Disabling the cache

Sometimes you may wish to install the Relay extension, but not have it allocate memory, either because you want to only use it as a faster alternative to PhpRedis, or to keep it dormant for future use.

To disable all in-memory caching and memory allocation `relay.maxmemory` can be set to `0`.

## Configuration directives

| Directive                         | Default          | Description                                                         |
| --------------------------------- | ---------------- | ------------------------------------------------------------------- |
| `relay.key`                       |                  | Relay license key. Without a license key Relay will throttle to 16MB memory one hour after startup. May also be set via `RELAY_KEY` environment variable. |
| `relay.environment`               | `development`    | The environment Relay is running in. Supported values: `production`, `staging`, `testing`, `development` |
| `relay.maxmemory`                 | `16M`            | How much memory Relay allocates on startup. This value can either be a number like `134217728` [or a unit](https://php.net/manual/faq.using.php#faq.using.shorthandbytes) (e.g. `128M`) like `memory_limit`. Relay will allocate at least 16M for overhead structures. Set to `0` to disable in-memory caching and use as client only. |
| `relay.maxmemory_pct`             | `95`             | At what percentage of used memory should Relay start evicting keys. |
| `relay.eviction_policy`           | `noeviction`     | How should relay evict keys. This has been designed to mirror Redis’ options. Supported values: `noeviction`, `lru`, and `random` |
| `relay.eviction_sample_keys`      | `128`            | How many keys should we scan each time we process evictions. |
| `relay.default_pconnect`          | `1`              | Default to using a persistent connection when calling `connect()`. |
| `relay.databases`                 | `16`             | The number of databases Relay will create per in-memory cache. This setting should match the `databases` setting in your `redis.conf`. |
| `relay.max_endpoint_dbs`          | `4`              | The maximum number of PHP workers that will have their own in-memory cache. This setting is per connection endpoint (distinct Redis connections), e.g. connecting to two separate instances will double the workers. |
| `relay.initial_readers`           | `128`            | The number of epoch readers allocated on startup. |
| `relay.invalidation_poll_freq`    | `5`              | How often (in microseconds) Relay should proactively check the connection for invalidation messages from Redis. |
| `relay.locks.allocator`           | `mutex`          | Locking mechanism used for the allocator. Supported values: `spinlock`, `mutex`, `adaptive-mutex` |
| `relay.locks.cache`               | `mutex`          | Locking mechanism used for the cache (databases). Supported values: `spinlock`, `mutex`, `adaptive-mutex` |
| `relay.loglevel`                  | `off`            | Whether Relay should log debug information. Supported levels: `debug`, `verbose`, `error`, `off` |
| `relay.logfile`                   |                  | The path to the file in which information should be logged, if logging is enabled. |
| `relay.cluster.seeds`             |                  | The list of cluster nodes addresses grouped by cluster name, which will be used to initialize each cluster, encoded as URL query string, e.g. `cluster1[]=127.0.0.1:7000&cluster2[]=127.0.0.1:8000` |
| `relay.cluster.auth`              |                  | The list of credentials for each cluster, encoded as URL query string. Password string or username/password pairs may be used, e.g. `cluster1=secret&cluster2[]=username&cluster2[]=secret` |
| `relay.cluster.timeout`           |                  | The maximum number of seconds Relay will wait while establishing connection to a single cluster node. |
| `relay.cluster.read_timeout`      |                  | The maximum number of seconds Relay will wait while reading from a cluster node. |
| `relay.session.locking_enabled`   | `0`              | Whether to enable session locking to avoid race conditions and keep session data consistent across requests. |
| `relay.session.lock_expire`       | `0`              | The number of seconds while Relay will try to acquire lock. When value is zero or negative `max_execution_time` will be used. |
| `relay.session.lock_retries`      | `0`              | The number of attempts Relay will try to acquire lock. If value is zero or negative `100` will be used to be compatible with PhpRedis. |
| `relay.session.lock_wait_time`    | `0`              | The number of microseconds Relay will wait between each attempt to acquire lock. If value is zero or negative `20000` will be used to be compatible with PhpRedis. |
| `relay.session.compression`       | `none`           | Compression algorithm used for session data. Supported values: `lzf`, `lz4`, `zstd` and `none` |
| `relay.session.compression_level` |                  | The used compression level. An empty value means the algorithm default compression level will be used. |

## `relay.locks.cache`

The lock used for the cache (and allocator) 

The following settings determine which kind of lock is used for Relay's
; allocator and our in-memory databases. These locks can be one of two or
; three types, depending on the system.
;
; * spinlock
;   The lowest latency lock which will busywait until the lock is
;   available. This is likely the right choice on systems with only
;   a few cores.
;
; * mutex
;   When contention is detected, this lock will sleep until it is available.
;   It has higher latency than a spinlock but uses far less CPU. On very large
;   instances, it is likely the right choice.
;
; * adaptive-mutex (Only on on glibc Linux systems)
;   This lock is a hybrid of the two above. When contention is detected it will
;   first spin waiting for the lock to free and then sleep if the lock is still
;   not available. Each time it spins it will update its strategy depending on
;   how long it took.

## `relay.max_endpoint_dbs`

This directive determines the maximum number of PHP workers with their own in-memory cache. While each PHP worker will have its own connection to Redis, not all workers need their own in-memory cache, and can be read-only workers that read from the shared memory pool.

This setting is per connection endpoint (distinct Redis connections); for example, connecting to two separate instances will double the number of workers.

It's worth benchmarking this setting for each application's workload; however, most workloads, especially heavy workloads, fare well with the default of `4` endpoints, and using more workers can negatively impact performance.
