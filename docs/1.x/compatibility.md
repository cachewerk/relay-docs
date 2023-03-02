---
title: Compatibility
---

# Compatibility

Relay is designed to be a drop-in replacement for [PhpRedis](https://github.com/phpredis/phpredis) and it's [API](/docs/1.x/api) is identical.

PhpRedis and Relay (by default) will return `false` in the event that a key doesn't exist, but also if a read error occurred. This makes it hard to distinguish the two return values.

```php
$redis = new Redis;
$redis->get('i-do-not-exist'); // false

$redis->set('name', 'Picard');
$redis->hgetall('name'); // false (actually a Redis WRONGTYPE error)
```

PhpRedis compatibility can be disabled, causing Relay to

1. Return `null` when a key doesn't exist, instead of `false`
2. Throw exceptions when an error occurs, instead of returning `false`

```php
$relay = new Relay;
$relay->setOption(Relay::OPT_PHPREDIS_COMPATIBILITY, false);

$relay->get('i-do-not-exist'); // null

$relay->set('name', 'Picard');
$relay->hgetall('name'); // Relay\Exception: WRONGTYPE Operation against a key holding the wrong kind of value
```

It is wise to not store [truthy/falsey values](https://www.php.net/manual/en/types.comparisons), such as `null`, `false`, `true`, `0`, `-1`, `[]` and so on in Redis. Your future self and others will thank you.
