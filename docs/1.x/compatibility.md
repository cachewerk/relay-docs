---
title: Compatibility
---

# Compatibility

Relay is designed to be a drop-in replacement for [PhpRedis](https://github.com/phpredis/phpredis) and it's [API](/docs/1.x/api) is identical.

## Compatibility mode

PhpRedis and (be default) Relay will return `false` in the event that a key doesn't exist, but also if a read-error occurred. This makes it hard to distinguish the two return values.

```php
$redis = new Redis;
$redis->get('i-do-not-exist'); // false

$redis->set('name', 'Picard');
$redis->hgetall('name'); // false
```

Relay however can be configured to return `null` if a key doesn't exist, and to throw an exception if a read-error occurred.

```php
$relay = new Relay;
$relay->setOption(Relay::OPT_PHPREDIS_COMPATIBILITY, false);

$relay->get('i-do-not-exist'); // null

$redis->set('name', 'Picard');
$redis->hgetall('name'); // throws \Relay\Exception
```

To change Relay’s behavior, you may enable it’s compatibility mode.

```php
$relay = new Relay;
$relay->setOption(Relay::OPT_PHPREDIS_COMPATIBILITY, true);
$relay->get('i-do-not-exist'); // false
```

Also, please don't store [truthy/falsey values](https://www.php.net/manual/en/types.comparisons), such as `null`, `false`, `true`, `0`, `-1`, `[]` and so on in Redis. Your future self and others will thank you.
