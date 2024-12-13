---
title: Tables
---

# Tables

Relay [Table](https://docs.relay.so/api/develop/Relay/Table.html) is a persistent per-worker hash table that can store arbitrary data.

```php
$table = new Redis\Table('log');
$table->set('entry:1', 'Personal Log, Seven of Nine, Stardate 51932.4...'); // true
$table->get('entry:1'); // string
$table->exists('entry:1'); // true
$table->clear(); // true
```
