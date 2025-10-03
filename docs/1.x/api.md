---
title: API
---

# API

Relay's API is available in a searchable format at [docs.relay.so/api](https://docs.relay.so/api/develop/) and bundled with the extension [stubs of PhpStorm](https://github.com/JetBrains/phpstorm-stubs).

## Stubs

All [builds](/docs/1.x/builds) include a `relay.stub.php` file, which outlines that build’s classes and their APIs. Fetching a specific stub without downloading a build can be done as well:

```bash
wget "https://builds.r2.relay.so/dev/relay.stub.php"
curl -O "https://builds.r2.relay.so/v0.12.0/relay.stub.php"
```

## Attributes

All methods have PHP attributes to provide some metadata which can be inspected at runtime using the Reflection APIs.

- `Local` indicates the method _does not_ communicate with Redis/Valkey
- `Server` indicates the method that _may_ communicate with Redis/Valkey
- `RedisCommand` indicates the method represents a [command](https://redis.io/commands/)
- `ValkeyCommand` indicates the method represents a [command](https://valkey.io/commands/)
- `Cached` indicates the method _may_ use in-memory caching
