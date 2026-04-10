---
title: Tables
---

# Tables

Relay [Table](https://docs.relay.so/api/develop/Relay/Table.html) is a shared in-memory hash table that lives in PHP's shared memory pool. Unlike Relay's Redis cache, it doesn't require any connections and can be used to store arbitrary data that is accessible across all PHP workers.

```php
use Relay\Table;

Table::set('users:count', 42); // true
Table::get('users:count'); // 42
Table::exists('users:count'); // true
Table::ttl('users:count'); // false (no expiry)
```

## Expiration

Keys can be set with an optional TTL in seconds:

```php
Table::set('session:abc', $data, expire: 3600);
Table::ttl('session:abc'); // int
```

## Namespaces

Table supports namespaces to organize keys and allow scoped operations:

```php
Table::set('entry:1', 'log data...', namespace: 'log');
Table::get('entry:1', namespace: 'log'); // 'log data...'
Table::count(namespace: 'log'); // 1
Table::clear(namespace: 'log'); // true
```

To list all namespaces or clear everything:

```php
Table::namespaces(); // array
Table::clearAll(); // int
```

For a complete list of methods, see the [API documentation](https://docs.relay.so/api/develop/Relay/Table.html).
