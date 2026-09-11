---
title: Cluster
---

# Cluster

[TOC]

## Connections

Relay provides the [`Relay\Cluster`](https://docs.relay.so/api/develop/Relay/Cluster.html) class to establish connections to clusters.

In this dynamic topology, where the number of nodes can change over time and data may migrate between nodes, `Relay\Cluster` uses the provided configuration as an initial state. It retrieves the actual configuration from the cluster itself using the `CLUSTER SLOTS` command. To minimize the number of requests to the cluster and enhance performance, Relay stores the cluster topology in an in-memory cache. This cache is updated based on events from the cluster.

```php
$cluster = new Relay\Cluster(
    name: null,
    seeds: [
        'tls://...cache.amazonaws.com',
    ],
);
```

Alternatively clusters can be configured using the [`relay.cluster.*`](#cluster-directives) INI directives and passing the configured name to the class.

```php
$cluster1 = new Relay\Cluster('pleiades');
```

For example, configure a named cluster before constructing the client:

```ini
relay.cluster.seeds = "pleiades[]=tcp://127.0.0.1:7000&pleiades[]=tcp://127.0.0.1:7001"
relay.cluster.auth = "pleiades=secret"
relay.cluster.timeout = "pleiades=1.0"
relay.cluster.read_timeout = "pleiades=2.0"
```

## Options and constants

The cluster-specific constants below belong to `Relay\Cluster`. The examples use an existing `$cluster` connection and this import:

```php
use Relay\Cluster;
```

See [Options](/docs/1.x/options) for the shared Relay and PhpRedis options.

### `OPT_DISTRIBUTE`

Controls how readonly commands are distributed across cluster nodes. Defaults to `DISTRIBUTE_NONE`.

`OPT_DISTRIBUTE` and `OPT_FAILOVER` are the preferred way to configure cluster routing, rather than the legacy [`OPT_REPLICA_FAILOVER`](#optreplica_failover) compatibility option.

| Value | Description |
| --- | --- |
| `DISTRIBUTE_NONE` | Send readonly commands to the primary node only. |
| `DISTRIBUTE_RANDOM` | Distribute randomly between the primary and its replicas. Stops trying replicas after the first failed attempt. |
| `DISTRIBUTE_RANDOM_REPLICA` | Distribute randomly among replicas only, never the primary. Stops trying replicas after the first failed attempt. |
| `DISTRIBUTE_REPLICAS` | Distribute randomly among replicas only. Iterates through all replicas until it finds a working one. |
| `DISTRIBUTE_ALL` | Distribute between the primary and its replicas. Iterates through all replicas until it finds a working one. |

```php
$cluster->setOption(Cluster::OPT_DISTRIBUTE, Cluster::DISTRIBUTE_REPLICAS);
```

### `OPT_FAILOVER`

Controls the retry strategy when a command fails on a node. Defaults to `FAILOVER_NONE`.

`OPT_DISTRIBUTE` and `OPT_FAILOVER` are the preferred way to configure cluster routing, rather than the legacy [`OPT_REPLICA_FAILOVER`](#optreplica_failover) compatibility option.

| Value | Description |
| --- | --- |
| `FAILOVER_NONE` | Don't retry. |
| `FAILOVER_RANDOM_REPLICA` | Retry the readonly command on a randomly selected replica. |
| `FAILOVER_PRIMARY` | Retry the readonly command on the primary node. Only applicable when the failed node is a replica. |
| `FAILOVER_REPLICAS` | Retry the readonly command on all replicas, excluding the failed node. |
| `FAILOVER_ALL` | Retry the readonly command on all other nodes (replicas and primary), excluding the failed node. |

```php
$cluster->setOption(Cluster::OPT_FAILOVER, Cluster::FAILOVER_REPLICAS);
```

### `OPT_NODE_READ_TIMEOUT`

Available since Relay v0.50.0. Sets a per-node read timeout in **seconds** for distributed or failover readonly commands.

Using `OPT_NODE_READ_TIMEOUT` can shorten the wait for a slow node during distributed or failover reads. Pair it with the [distribution and failover options](#optdistribute) to allow another node to serve the read:

```php
use Relay\Cluster;

$cluster = new Cluster(
    name: null,
    seeds: ['127.0.0.1:7000'],
    connect_timeout: 1.0,
    command_timeout: 2.0,
);

$cluster->setOption(Cluster::OPT_FAILOVER, Cluster::FAILOVER_REPLICAS);
$cluster->setOption(Cluster::OPT_NODE_READ_TIMEOUT, 0.1);
```

With replicas available, this configuration allows a read that times out on the primary after 100 milliseconds to be retried on a replica. The per-node budget is clipped to the remaining command timeout. Several node attempts can contribute to the total time spent on a read. The connection timeout still governs establishing connections; the per-node option does not replace it.

The default per-node timeout is `0.0`, disabling the override. Values must be finite and nonnegative. It applies to individual readonly commands when distribution or failover is enabled, outside pipelines and transactions. Writes retain their normal timeout behavior. You can change the option on an existing cluster object before issuing further reads.

See [Cluster health checks](#cluster-health-checks) for how timed-out nodes return to service.

### `OPT_REPLICA_FAILOVER`

Legacy compatibility view for PhpRedis' coarse failover setting. It maps the modes below onto Relay's `OPT_DISTRIBUTE` and `OPT_FAILOVER` settings.

| Value | Description |
| --- | --- |
| `FAILOVER_NONE` | Send commands to primary nodes only. |
| `FAILOVER_ERROR` | Send readonly commands to replica nodes if primary is unreachable. |
| `FAILOVER_DISTRIBUTE` | Always distribute readonly commands between primary and replicas, at random. |
| `FAILOVER_DISTRIBUTE_REPLICAS` | Always distribute readonly commands to the replicas, at random. |

```php
$cluster->setOption(Cluster::OPT_REPLICA_FAILOVER, Cluster::FAILOVER_DISTRIBUTE_REPLICAS);
```

This is not a true alias: some `OPT_DISTRIBUTE` and `OPT_FAILOVER` combinations have no legacy representation, and `getOption(OPT_REPLICA_FAILOVER)` returns `false` for those states. Prefer `OPT_DISTRIBUTE` and `OPT_FAILOVER` for new code.

For PhpRedis compatibility, `OPT_SLAVE_FAILOVER` and `FAILOVER_DISTRIBUTE_SLAVES` remain available as aliases of `OPT_REPLICA_FAILOVER` and `FAILOVER_DISTRIBUTE_REPLICAS`.

### `OPT_AVAILABILITY_ZONE`

Sets a preferred availability zone so cluster reads can be routed to nodes in the same zone, reducing cross-AZ traffic.

```php
$cluster->setOption(Cluster::OPT_AVAILABILITY_ZONE, 'us-east-1a');
```

### `OPT_MULTIKEY_REORDERING`

Available in Relay v0.50.0. Controls whether supported multi-key commands may reorder nonadjacent keys to group them by hash slot. Defaults to `MULTIKEY_REORDER_NONE`, preserving PhpRedis' command ordering.

| Value | Description |
| --- | --- |
| `MULTIKEY_REORDER_NONE` | Preserve key order and group only adjacent keys in the same hash slot. |
| `MULTIKEY_REORDER_READS` | Allow readonly multi-key commands to group all keys by hash slot. Returned values retain the order of the supplied keys. |
| `MULTIKEY_REORDER_WRITES` | Allow mutating multi-key commands to group all keys by hash slot. This may change execution order relative to the supplied keys. |
| `MULTIKEY_REORDER_ALL` | Allow grouping by hash slot for both readonly and mutating multi-key commands. |

```php
$cluster->setOption(Cluster::OPT_MULTIKEY_REORDERING, Cluster::MULTIKEY_REORDER_READS);
```

Set this option before issuing the commands it should govern. Enable write reordering only when your application can tolerate changes to execution order.

## Cluster directives

These `relay.cluster.*` INI directives configure named connections, topology caching, and node health checks. Empty defaults mean no value is configured.

| Directive                              | Default          | Description                                                         |
| -------------------------------------- | ---------------- | ------------------------------------------------------------------- |
| `relay.cluster.seeds`                  |                  | The list of cluster nodes addresses grouped by cluster name, which will be used to initialize each cluster, encoded as URL query string, e.g. `cluster1[]=tcp://127.0.0.1:7000&cluster2[]=tcp://127.0.0.1:8000` |
| `relay.cluster.auth`                   |                  | The list of credentials for each cluster, encoded as URL query string. Password string or username/password pairs may be used, e.g. `cluster1=secret&cluster2[]=username&cluster2[]=secret` |
| `relay.cluster.timeout`                |                  | Connection timeout in seconds for each named cluster, encoded as a URL query string, e.g. `pleiades=1.0`. |
| `relay.cluster.read_timeout`           |                  | Read timeout in seconds for each named cluster, encoded as a URL query string, e.g. `pleiades=2.0`. |
| `relay.cluster.slot_cache_expiry`      |                  | The TTL of the cluster slot cache in seconds. Empty or nonpositive values disable time-based expiry. |
| `relay.cluster.shard_health_wait_base` | `1`              | Base delay in seconds for unhealthy-node health checks. Nonpositive values use `1`. |
| `relay.cluster.shard_health_wait_cap` | `60`              | Maximum health-check delay in seconds. Values below the base are raised to the base. |
| `relay.cluster.shard_health_wait_strategy` | `equal-jitter` | Health-check backoff algorithm. Supported values: `default`, `decorrelated-jitter`, `full-jitter`, `equal-jitter`, `exponential`, `uniform`, `constant`. |
| `relay.cluster.shard_health_wait_time` | `0`              | Legacy override: a positive value selects a fixed health-check delay in seconds, overriding the base, cap, and strategy. Zero or negative values use the backoff settings above. |

The `relay.cluster.shard_health_wait_base`, `relay.cluster.shard_health_wait_cap`, and `relay.cluster.shard_health_wait_strategy` directives are available since Relay v0.50.0. See [Cluster health checks](#cluster-health-checks) for their interaction with per-node read timeouts.

## Cluster health checks

Relay uses configurable backoff when checking unhealthy nodes. A node that exceeds its per-node read timeout is marked unhealthy. When selecting replicas for distribution or failover, Relay skips unhealthy nodes until they are eligible for another health check.

Checks happen as part of node selection after the delay has elapsed. A failed check schedules another attempt using the configured backoff; a successful check restores the node and resets its failure history. The per-node timeout also bounds health-check work, including reconnecting during a check, so probing an unhealthy replica can be cut short before trying another candidate.

The default configuration uses exponential backoff with equal jitter:

```ini
relay.cluster.shard_health_wait_base = 1
relay.cluster.shard_health_wait_cap = 60
relay.cluster.shard_health_wait_strategy = equal-jitter
relay.cluster.shard_health_wait_time = 0
```

The base and cap are in **seconds**. With these defaults, the delay is chosen randomly between half the current exponential ceiling and that ceiling: initially 0.5–1 seconds, then 1–2 seconds, then 2–4 seconds, up to 30–60 seconds. This spreads out repeated checks while allowing recovered nodes to return to service. The delay determines when another check is eligible; it is not a sleep added to every command or the time limit for the check itself.

| Strategy | Delay behavior |
| --- | --- |
| `equal-jitter` | Random delay between half the exponential ceiling and the ceiling, bounded by the cap. This is the default setting. |
| `full-jitter` | Random delay from zero to the exponential ceiling, bounded by the cap. |
| `exponential` | Exponentially increasing delay up to the cap, without jitter. |
| `decorrelated-jitter` | Random delay between the base and three times the previous delay, with the upper bound limited to the cap. |
| `constant` | Fixed delay equal to the base. |
| `uniform` | Random delay from zero to the base on every attempt. |
| `default` | Random delay from zero to the base initially, then the base on subsequent attempts. |

Use a positive base and a cap at least as large as the base. Relay substitutes `1` for a nonpositive base and raises a smaller cap to the base.

The existing `relay.cluster.shard_health_wait_time` setting remains as a compatibility override. A positive value forces a fixed delay in seconds and takes precedence over all three backoff settings. Leave it at `0` to use the new regime; `0` does not disable health checks. Negative values also select the backoff settings.

These INI settings can be changed at runtime and are read when Relay schedules the next health check. A change does not reschedule a check that is already pending. They are separate from the connection retry options `OPT_BACKOFF_BASE`, `OPT_BACKOFF_CAP`, and `OPT_BACKOFF_ALGORITHM`.

## Cluster databases

Cluster mode traditionally supports only a single database. Valkey 9.0 lifted that restriction, and `Relay\Cluster` supports it when the server does.

```php
$cluster->select(1);
$cluster->getDbNum(); // 1
```

`select()` is broadcast to every node in the cluster, so the whole connection moves to the new database at once. If it fails on any node, Relay reverts every node back to the previously selected database, leaving the connection in a consistent state rather than partially switched.
