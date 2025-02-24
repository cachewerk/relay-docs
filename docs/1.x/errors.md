---
title: Errors
---

# Common Errors

Some error messages from the kernel can be confusing. 

## `Connection refused`
The host is reachable, but nothing is listening on the specified port. Is the Redis server running? Is it accessible via `redis-cli`?

## `Connection timed out`
The server didn’t respond in time, either during connection establishment or data transmission. Try increasing timeouts if the error keeps occurring.

## `Resource temporarily unavailable` / `Read error on connection`
The server didn’t respond in time, while reading data. Try increasing timeouts if the error keeps occurring. Try [diagnosing latency issues](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency/).

## `Broken pipe` / `Connection reset by peer`
The server closed the connection abruptly, often due to a crash, network issues, or an application-level error. Check the Redis logs to see why the connection was closed.
