---
title: Builds
---

# Builds

Relay's builds are available in a searchable format at [relay.so/builds](https://relay.so/builds).

## Latest version

Fetching a the latest stable version is easy.

```bash
curl "https://builds.r2.relay.so/meta/latest"

wget -q -O- "https://builds.r2.relay.so/meta/latest"

curl -s "https://api.github.com/repos/cachewerk/relay/releases/latest" \
  | grep '"tag_name":' \
  | sed -E 's/.*"([^"]+)".*/\1/'
```

## Releases

A complete list of all releases is available too.

```bash
curl "https://builds.r2.relay.so/meta/builds"
```

## Release artifacts

Each release has a `artifacts.json` that contains the various build artifacts.

```bash
curl "https://builds.r2.relay.so/v0.9.1/artifacts.json"
```
