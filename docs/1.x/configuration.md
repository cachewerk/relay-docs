---
title: Configuration
---

# Configuration

Relay provides many configuration directives and the `relay.ini` file can be located by running:

```bash
php --ini
```

It’s recommended to at least adjust the `relay.maxmemory` and `relay.eviction_policy` directives. For performance tuning in production, see [Performance](/docs/1.x/performance) for the cache lock and writer settings.

If you're running a licensed binary, be sure to set the `relay.key` and `relay.environment` as well.

## Memory limits

Relay will allocate what `relay.maxmemory` is set to when PHP starts, even if no `relay.key` is set. After 60 minutes of runtime (if no valid license was set), Relay will downsize the allocated memory to 16 MB.

## Disabling the cache

Sometimes you may wish to install the Relay extension, but not have it allocate memory, either because you want to only use it as a faster alternative to PhpRedis, or to keep it dormant for future use.

To disable all in-memory caching and memory allocation `relay.maxmemory` can be set to `0`.

## Configuration directives

| Directive                         | Default          | Description                                                         |
| --------------------------------- | ---------------- | ------------------------------------------------------------------- |
| `relay.key`                       |                  | Relay license key. Without a license key Relay will throttle to 16MB memory one hour after startup. May also be set via `RELAY_KEY` environment variable. |
| `relay.environment`               | `development`    | The environment Relay is running in. Supported values: `production`, `staging`, `testing`, `development` |
| `relay.maxmemory`                 | `16MB`           | How much memory Relay allocates on startup. This value can either be a number like `134217728` [or a unit](https://php.net/manual/faq.using.php#faq.using.shorthandbytes) (e.g. `128M`) like `memory_limit`. Relay will allocate at least 16M for overhead structures. Set to `0` to disable in-memory caching and use as client only. |
| `relay.maxmemory_pct`             | `95`             | At what percentage of used memory should Relay start evicting keys. |
| `relay.eviction_policy`           | `noeviction`     | How should Relay evict keys. This has been designed to mirror Redis’ options. Supported values: `noeviction`, `lru`, and `random`. See [Eviction policies](/docs/1.x/eviction#eviction-policies). |
| `relay.eviction_sample_keys`      | `128`            | How many keys should we scan each time we process evictions. |
| `relay.flush_batch_size`          | `1024`           | Maximum cached entries reclaimed per cleanup callback for a flushed database map. Minimum `1`. Smaller batches reduce work per callback but retain retired cache memory longer. See [Performance](/docs/1.x/performance#relayflushbatchsize). |
| `relay.databases`                 | `16`             | The number of databases Relay will create per in-memory cache. This setting should match the `databases` setting in your `redis.conf`. |
| `relay.max_db_writers`            | `4`              | As of `v0.60.x`, the maximum number of admitted tracking connections per endpoint. Supported values: integers from `1` to `1024`. Any number of workers can read from the cache. See [Performance](/docs/1.x/performance#relaymaxdbwriters). |
| `relay.key_leases`                | `32`             | Shared pool of tracking-connection leases across all endpoints. Supported values: positive integers; effective capacity is rounded to a power of two, with a minimum of `16` and a maximum of `32768`. See [Performance](/docs/1.x/performance#relaykeyleases). |
| `relay.locks.allocator`           | `adaptive-mutex` | Locking mechanism used for the allocator. Supported values: `spinlock`, `mutex`, `adaptive-mutex`. See [Performance](/docs/1.x/performance). |
| `relay.locks.cache`               | `adaptive-mutex` | Locking mechanism used for the in-memory cache (databases). Supported values: `spinlock`, `mutex`, `adaptive-mutex`. See [Performance](/docs/1.x/performance). |
| `relay.default_pconnect`          | `1`              | Default to using a persistent connection when calling `connect()`. |
| `relay.initial_readers`           | `128`            | The number of epoch readers allocated on startup. |
| `relay.invalidation_poll_freq`    | `5`              | How often (in microseconds) Relay should proactively check the connection for invalidation messages from Redis/Valkey. |
| `relay.loglevel`                  | `off`            | Whether Relay should log debug information. Supported levels: `debug`, `verbose`, `notice`, `error`, `off` |
| `relay.logfile`                   |                  | The log destination. Supports `stderr` or an absolute path. |
| `relay.prefault`                  | `off`            | How Relay faults in the shared memory segment during startup. Supported values: `off`, `populate`, `touch`. See [Performance](/docs/1.x/performance#relayprefault). |
| `relay.huge_pages`                | `1`              | Development builds only. Request transparent huge pages for the shared cache on Linux at startup. Supported values: `0` (disabled), `1` (enabled). Has no effect on other platforms. See [Performance](/docs/1.x/performance#relayhugepages). |
| `relay.cap_endpoint_dbs`          | —                | Ignored as of `v0.60.x`. |
| `relay.max_endpoint_dbs`          | —                | Ignored as of `v0.60.x`. |

## Cluster directives

See [Cluster directives](/docs/1.x/cluster#cluster-directives) for all `relay.cluster.*` settings, defaults, and examples.

## Session directives

| Directive                              | Default          | Description                                                         |
| -------------------------------------- | ---------------- | ------------------------------------------------------------------- |
| `relay.session.locking_enabled`        | `0`              | Whether to enable session locking to avoid race conditions and keep session data consistent across requests. |
| `relay.session.lock_expire`            | `0`              | The number of seconds Relay will try to acquire lock. When value is zero or negative `max_execution_time` will be used. |
| `relay.session.lock_retries`           | `0`              | The number of attempts Relay will try to acquire lock. If value is zero or negative `100` will be used to be compatible with PhpRedis. |
| `relay.session.lock_wait_time`         | `0`              | The number of microseconds Relay will wait between each attempt to acquire lock. If value is zero or negative `20000` will be used to be compatible with PhpRedis. |
| `relay.session.compression`            | `none`           | Compression algorithm used for session data. Supported values: `lzf`, `lz4`, `zstd` and `none` |
| `relay.session.compression_level`      | `0`              | The used compression level. A value of `0` means the algorithm default compression level will be used. |
