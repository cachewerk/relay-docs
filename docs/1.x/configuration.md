---
title: Configuration
---

# Configuration

Relay provides several configuration directives and the `relay.ini` file is easily located by running:

```bash
php --ini
```

It’s strongly recommended to set the `relay.maxmemory`, `relay.eviction_policy` and `relay.databases` directives. If you're running a licensed binary, be sure to set the `relay.key` and `relay.environment` as well.

## Memory limits

Relay will allocate what `relay.maxmemory` is set to when PHP starts, even if no `relay.key`. However if no valid license was set, after 60 minutes of runtime, Relay will downsize the allocated memory to its hard limit of 16 MB.

## Disabling the cache

Sometimes you may wish to install the Relay extension, but not have it allocate memory, either because you want to only use it as a faster alternative to PhpRedis, or to keep it dormant for future use.

You may disable all in-memory caching and memory allocation by setting:

```ini
relay.maxmemory = 0
```

## Configuration directives

| Directive                         | Default          | Description                                                         |
| --------------------------------- | ---------------- | ------------------------------------------------------------------- |
| `relay.key`                       |                  | Relay license key. Without a license key Relay will throttle to 16MB memory one hour after startup. May also be set via `RELAY_KEY` environment variable. |
| `relay.environment`               | `development`    | The environment Relay is running in. Supported values: `production`, `staging`, `testing`, `development` |
| `relay.maxmemory`                 | `32M`            | How much memory Relay allocates on startup. This value can either be a number like `134217728` [or a unit](https://php.net/manual/faq.using.php#faq.using.shorthandbytes) (e.g. `128M`) like `memory_limit`. Relay will allocate at least 16M for overhead structures. Set to `0` to disable in-memory caching and use as client only. |
| `relay.maxmemory_pct`             | `95`             | At what percentage of used memory should Relay start evicting keys. |
| `relay.eviction_policy`           | `noeviction`     | How should relay evict keys. This has been designed to mirror Redis’ options. Supported values: `noeviction`, `lru`, and `random` |
| `relay.eviction_sample_keys`      | `128`            | How many keys should we scan each time we process evictions. |
| `relay.default_pconnect`          | `1`              | Default to using a persistent connection when calling `connect()`. |
| `relay.databases`                 | `16`             | The number of databases Relay will create per in-memory cache. This setting should match the `databases` setting in your `redis.conf`. |
| `relay.max_endpoint_dbs`          | `32`             | The maximum number of PHP workers that will have their own in-memory cache. While each PHP worker will have its own connection to Redis, not all workers need their own in-memory cache and can be read-only workers. This setting is per connection endpoint (distinct Redis connections), e.g. connecting to two separate instances will double the workers. |
| `relay.initial_readers`           | `128`            | The number of epoch readers allocated on startup. |
| `relay.invalidation_poll_freq`    | `5`              | How often (in microseconds) Relay should proactively check the connection for invalidation messages from Redis. |
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
