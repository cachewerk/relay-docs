---
title: Configuration
---

# Configuration

Relay provides several configuration directives and the `relay.ini` file is easily located by running:

```bash
php --ini
```

It’s strongly recommended to set the `relay.maxmemory`, `relay.eviction_policy` and `relay.databases` directives. If you have a license, be sure to set the `relay.key` and `relay.environment` as well.

## Memory limits

Relay will allocate what `relay.maxmemory` is set to when PHP starts, even if no `relay.key`. However if no valid license was set, after 60 minutes of runtime, Relay will downsize the allocated memory to its hard limit of 32 MB.

## Disabling the cache

Sometimes you may wish to install the Relay extension, but not have it allocate memory, either because you want to only use it as a faster alternative to PhpRedis, or to keep it dormant for future use.

You may disable all in-memory caching and memory allocation by setting:

```ini
relay.maxmemory = 0
```

## Default configuration

```ini
{{git://github.com/cachewerk/relay-core/contents/relay.ini?ref=develop}}
```
