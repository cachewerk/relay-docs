---
title: Telemetry
---

# Telemetry

Relay transmits anonymized, nonsensitive telemetry to help our team make well-informed development decisions.

## Fair Billing Policy

Relay uses a Fair Billing Policy and only bills for actively used production runtimes. No need to worry about bursts, short-lived CLI processes or staging environments.

// Fair Billing Policy (map it out...)
// full transparent report with daily breakdowns

- If the `relay.environment` is not `production` it will not be billed
- If the usage ...

## Telemetry sample

```json
{
  "binary": "00000000-0000-0000-0000-000000000000",
  "environment": "development",
  "heartbeat": 1,
  "key": "ILOO-KFOR-WARDTO-YOURREP-ORTMRBR-OCCOLI",
  "run": "00000000-0000-0000-0000-000000000000",
  "started_at": 1234567890,
  "uptime": 1800,
  "telemetry": {
    "config": {
      "relay.databases": 16,
      "relay.default_pconnect": 1,
      "relay.eviction_policy": "noeviction",
      "relay.eviction_sample_keys": 128,
      "relay.initial_readers": 128,
      "relay.max_endpoint_dbs": 16,
      "relay.maxmemory_pct": 75
    },
    "host": {
      "arch": "x86_64",
      "dockerenv": false,
      "hostname": "your-mom",
      "memory": 0,
      "os": "Linux",
      "processors": 16,
      "release": "5.15.0-56-generic", 
      "version": "#1337-Ubuntu SMP Tue Aug 15 00:00:00 UTC 1969"
    },
    "memory": {
      "active": 0,
      "limit": 0,
      "total": 0,
      "used": 0
    },
    "php": {
      "memory_limit": "4g",
      "sapi": "cli",
      "version": "8.2.0"
    },
    "redis": [
      {
        "maxmemory": 0,
        "maxmemory_policy": "allkeys-lru",
        "total_system_memory": 0,
        "tracked_keys": 0,
        "used_memory": 0,
        "used_memory_peak": 0,
        "version": "7.0.5"
      },
      {}, {}, {}
    ],
    "relay": {
      "version": "0.5.2-dev"
    },
    "stats": {
      "empty": 0,
      "errors": 0,
      "hits": 0,
      "misses": 0,
      "oom": 0,
      "requests": 0,
      "walltime": 0,
      "bytes": {
        "sent": 0,
        "received": 0
      }
    },
    "usage": [
      {
        "hits": 0,
        "misses": 0,
        "memory": 0,
        "interval": 3600,
        "samples": 0,
        "timestamp": 1234567890,
        "updated": 1234567890,
        "workers": 0,
        "walltime": 0,
        "bytes": {
          "sent": 0,
          "received": 0
        }
      },
      {}, {}, {}
    ]
  }
}
```
