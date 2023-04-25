---
title: API
---

# API

Relay's API is available in a searchable format on [docs.relay.so/api](https://docs.relay.so/api/develop/).
Additionally, all [builds](https://relay.so/builds) include a `relay.stub.php` file, which outlines that build’s classes and their APIs.

## Stubs

Fetching a specific stub without downloading a build can be done as well:

```bash
wget "https://builds.r2.relay.so/dev/relay.stub.php"
curl -O "https://builds.r2.relay.so/v0.6.3/relay.stub.php"
```

## Groups

Similar to PHPUnit, we've included `@group` tags in the stubs to provide some metadata. 

- `local` indicates a method that _does not_ communicate with Redis
- `remote` indicates a method that _may_ communicate with Redis
- `redis` (implies `remote`) indicates a method that represents a [Redis command](https://redis.io/commands/)
- `enhanced` indicates a method that is a Redis command that _may_ be handled in-memory
