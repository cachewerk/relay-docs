---
title: Eviction
---

# Eviction

Every time PHP starts, Relay will allocate a fixed amount of memory as part of the master process. By default 32MB are allocated and when that limit is reached Relay will act just like PhpRedis without storing additional keys locally.

The allocated amount of memory can be altered using the `relay.maxmemory` [directive](/docs/1.x/configuration). Unlicensed installations will downsize to 16MB after an hour of use.

Similar to Redis, you may alter the eviction policy used when the memory limit is reached using the `relay.eviction_policy` directive.

## Eviction policies

| Policy       | Description |
| ------------ | ----------- |
| `noeviction` | Once the in-memory cache is full all uncached keys will be proxied to Redis |
| `random`     | Randomly evicts keys out of all keys when `relay.maxmemory_pct` is reached |
| `lru`        | Evicts the least recently used keys out of all keys when `relay.maxmemory_pct` is reached |
