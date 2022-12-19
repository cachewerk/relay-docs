---
title: Compatibility
---

# Compatibility

Relay is designed to be a drop-in replacement for [PhpRedis](https://github.com/phpredis/phpredis) and it's [API](/docs/1.x/api) is identical.

## Compatibility mode

PhpRedis will return `false` in the event that a key doesn't exist, but also if there is an error.
This makes it hard to distinguish the two return values.

```php
$redis = new Redis;
$redis->get('i-do-not-exist'); // false
```

Relay however will return `null` if a key doesn't exist, and will throw an exception if there is an error.

```php
$relay = new Relay;
$relay->get('i-do-not-exist'); // null
```

To change Relay’s behavior, you may enable it’s compatibility mode.

```php
$relay = new Relay;
$relay->setOption(Relay::OPT_PHPREDIS_COMPATIBILITY, true);
$relay->get('i-do-not-exist'); // false
```

Also, don't store [truthy/falsey values](https://www.php.net/manual/en/types.comparisons) in Redis,
such as `null`, `false`, `true`, `0`, `-1`, `[]` and so on. Your future self will thank you.
