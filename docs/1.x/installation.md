---
title: Installation
---

# Installation

[TOC]

## Requirements

Before installing Relay, make sure the system meets the requirements:

- PHP 7.4+
- Redis Server 6.2.7+
- The `json`, `igbinary` and `msgpack` PHP extensions

## macOS

Relay can be installed on macOS using [Homebrew](https://brew.sh).

```bash
brew tap cachewerk/tap

brew install relay      # PHP 8.1
brew install relay@7.4  # PHP 7.4
```

Afterwards, be sure to restart PHP-FPM and the web server:

```bash
sudo brew services restart php
sudo brew services restart nginx
```

Next, ensure that Relay was installed by running:

```bash
php --ri relay
```

If necessary, adjust the [configuration](/docs/1.x/configuration) in `/opt/homebrew/etc/relay/relay.ini`.

_It is worth noting that macOS lacks a decent futex mechanism and Relay will be somewhat slower than running it on Linux._

## Linux

Relay can be installed on any Linux system. We have [packages](https://github.com/cachewerk/linux-repos) for popular PHP repositories, and for other common systems we have various [Docker examples](https://github.com/cachewerk/relay/tree/main/docker), as well as [manual installation instructions](#manual-installation) for highly customized system.

## Using Docker

We have various [Docker examples on GitHub](https://github.com/cachewerk/relay/tree/main/docker). If you're using the official PHP Docker images you can install Relay using the `php-extension-installer`:

```docker
FROM php:8.1-cli
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions relay
```

## Using APT

If the setup is using Ondřej’s wonderful `ppa:ondrej/php` repository ([deb.sury.org](https://deb.sury.org)) to manage PHP and extensions, simply add our key and repository:

```bash
curl -s https://repos.r2.relay.so/key.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://repos.r2.relay.so/deb $(lsb_release -cs) main"
sudo apt update
```

Then, depending on the setup, install either Relay for a specific PHP version, or for the default version.

```bash
sudo apt install php-relay     # default php version
sudo apt install php8.1-relay  # specific php version
```

Next, ensure that Relay was installed by running:

```bash
php --ri relay
```

Finally, restart PHP-FPM and the web server.

## Using YUM / DNF

If the setup is using Remi’s excellent repository ([rpms.remirepo.net](https://rpms.remirepo.net)) to manage PHP and extensions, simply add our key and repository:

```bash
curl -s -o /etc/yum.repos.d/cachewerk.repo "https://repos.r2.relay.so/rpm/el.repo"
```

Then, depending on the setup, install either Relay for a specific PHP version, or for the default version.

```bash
yum install relay-php        # single php version
yum install php81-php-relay  # multiple php versions
```

Next, ensure that Relay was installed by running:

```bash
php --ri relay
```

Finally, restart PHP-FPM and the web server.

## Heroku

To use Relay on Heroku, add the platform repository to the Heroku app:

```bash
heroku config:set HEROKU_PHP_PLATFORM_REPOSITORIES="https://relay.so/heroku/"
```

Then add the extensions to `composer.json` as usual:

```bash
composer require "ext-relay:*"
```

Deploy the app and ensure that Relay was installed by running:

```bash
heroku run "php --ri relay"
```

Learn more [on GitHub](https://github.com/cachewerk/heroku-php-extensions).

### Configuring Relay on Heroku

The Relay [configuration](/docs/1.x/configuration) can be changed by adding Heroku’s [compile step](https://devcenter.heroku.com/articles/php-support#custom-compile-step) to your `composer.json` file.

```json
{
  "require": {
    "ext-relay": "*"
  },
  "scripts": {
    "compile": [
      "./bin/compile.sh"
    ]
  }
}
```

This is how your `compile` script could look:

```bash
#!/bin/bash
set -e

RELAY_INI=`find $(php-config --ini-dir) -name "*-relay.ini"`

sed -i "s/^;\? \?relay.key =.*/relay.key = $RELAY_KEY/" $RELAY_INI
sed -i 's/^;\? \?relay.maxmemory =.*/relay.maxmemory = 128M/' $RELAY_INI
sed -i 's/^;\? \?relay.eviction_policy =.*/relay.eviction_policy = lru/' $RELAY_INI
```

Be sure to set your `RELAY_KEY` config variable:

```console
heroku config:set RELAY_KEY=...
```

## GitHub Actions

Installing Relay on GitHub Actions using `shivammathur/setup-php` is seamless.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: 8.2
          extensions: relay # or `relay-v0.6.0`

      - name: Dump Relay configuration
        run: |
          php --ri relay
```

## Manual installation

In some cases, Relay may need to be installed manually. Let's go over it step by step, or [skip to the TLDR](#tldr).

### 1. Preparation

First, you'll need to know the:

- OS name _(CentOS, Debian)_
- OS version
- OS architecture _(amd64, aarch64, etc.)_
- PHP version _(7.4, 8.1, etc.)_

If this is difficult or unclear, you may want to consider stopping and asking someone for help.

### 2. PHP installations

Second, identify the PHP binaries that should use Relay. Your system might be using separate PHP installations for CLI and FPM.

Let's go with a single binary for this guide:

```bash
which php
# /usr/bin/php
```

### 3. PHP extensions

Next, make sure the PHP installation you picked in step 2 have the `json`, `igbinary` and `msgpack` extensions installed.

```bash
/usr/bin/php -m | grep -e json -e igbinary -e msgpack
# igbinary
# json
# msgpack
```

If any of the extensions are missing, be sure to install them via `pecl` or the system's PHP package manager before continuing. _Do this for all PHP installations of step 2._

### 4. Relay artifact

Next, [grab the URL](/builds) for the build matching the system. We'll use Ubuntu 20.04 and PHP 8.1 as an example.

```bash
mkdir /tmp/relay
curl -sSL "https://builds.r2.relay.so/v0.5.1/relay-v0.5.1-php8.1-debian-x86-64.tar.gz" | tar -xz --strip-components=1 -C /tmp/relay
```

If we're missing a build for your particular system or architecture, please [open an issue](https://github.com/cachewerk/relay/issues).

### 5. System dependencies

Relay requires several system libraries (OpenSSL, hiredis, Concurrency Kit, Zstandard, LZ4).
All Relay builds come with a `relay.so` and `relay-pkg.so`. The `relay-pkg.so` comes with hiredis and ck bundled in, because:

1. Relay requires hiredis `>=1.1.0` (which hasn't been released)
2. Relay on Silicon requires ck `>=0.7.1` (which also hasn't been released)

The OpenSSL dependency can be ignored, because it's typically installed along with PHP.

While you _could_ use the `relay.so` today and have all libraries linked dynamically,
we recommend using `relay-pkg.so` for convenience.

Alright, now make sure the `relay-pkg.so` has all its dependencies using `ldd` (or `otool` on macOS):

```bash
ldd /tmp/relay/relay-pkg.so

# libpthread.so.0 => /lib/aarch64-linux-gnu/libpthread.so.0 (0x0000ffff9676d000)
# libssl.so.1.1 => /lib/aarch64-linux-gnu/libssl.so.1.1 (0x0000ffff966d3000)
# libcrypto.so.1.1 => /lib/aarch64-linux-gnu/libcrypto.so.1.1 (0x0000ffff96445000)
# libzstd.so.1 => not found
# liblz4.so.1 => /lib/aarch64-linux-gnu/liblz4.so.1 (0x0000ffff96203000)
```

_If you're seeing a `not a dynamic executable` error, then the downloaded build doesn't match the os/arch, or you're obscure distro is blocking `ldd` calls in `/tmp`._

If any dependency says `not found` the library missing needs to be installed:

```bash
apt-get install libzstd
```

### 6. Relay extension

Let's move the Relay binary. First, we'll inject the mandatory UUID into the binary:

```bash
sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" /tmp/relay/relay-pkg.so
```

Second, identify PHP's extension directory for all:

```bash
/usr/bin/php -i | grep '^extension_dir'
# extension_dir => /usr/lib/php/20210902 => /usr/lib/php/20210902

php-config --extension-dir
# /usr/lib/php/20210902
```

Then move and rename the `relay-pkg.so` to `relay.so` and move it to the extension directory:

```bash
cp /tmp/relay/relay-pkg.so /usr/lib/php/20210902/relay.so
```

_Do this for all PHP installations of step 2._

### 7. Relay configuration

Almost! Let's [configure](/docs/1.x/configuration) Relay.
In testing environments you can skip this step, but for production setups we recommend setting at least:

```ini
relay.maxmemory = 32M
relay.eviction_policy = noeviction
relay.environment = production
relay.key = 1L0O-KF0R-W4RDT0-Y0URR3P-0RTMRBR-OCC0L1
```

You can automate this using `sed`, or simply `vim` it — if you know how to exit.

```bash
sed -i 's/^;\? \?relay.maxmemory =.*/relay.maxmemory = 128M/' /tmp/relay/relay.ini
sed -i 's/^;\? \?relay.eviction_policy =.*/relay.eviction_policy = lru/' /tmp/relay/relay.ini
sed -i 's/^;\? \?relay.environment =.*/relay.environment = production/' /tmp/relay/relay.ini
sed -i "s/^;\? \?relay.key =.*/relay.key = $RELAY_KEY/" /tmp/relay/relay.ini
```

Like the extension directory the `ini-dir` varies greatly from system to system:

```bash
/usr/bin/php --ini | grep "Scan for additional"
# Scan for additional .ini files in: /etc/php/8.1/cli/conf.d

php-config --ini-dir
# /etc/php/8.1/cli/conf.d
```

Then move the `relay.ini`:

```bash
cp /tmp/relay/relay.ini /etc/php/8.1/cli/conf.d
```

### CLI test

Finally, let's make sure Relay works in your CLI environment and your configuration takes effect.

```bash
php --ri relay
```

### HTTP test

Now, let's restart your PHP and Web Server processes, whether it's Nginx, Apache, LiteSpeed, restart it all. Same goes for the PHP-FPM process.

Now either run our [benchmarks](https://github.com/cachewerk/relay#benchmarks), or simply try a little test script to make sure Relay can connect to Redis Server:

```php
<?php

$relay = new \Relay\Relay(host: '127.0.0.1');

var_dump($relay->ping('hello'));
```

That's it, enjoy!

### TLDR

First, ensure that the `json`, `igbinary` and `msgpack` PHP extensions are installed for all PHP installations (CLI, FPM, etc).

Then make sure `zstd` and `lz4` are installed, as well as other required system libraries.

```bash
RELAY_VERSION="v0.5.1"
RELAY_PHP=$(php-config --version | cut -c -3)  # 8.1
RELAY_INI_DIR=$(php-config --ini-dir)          # /etc/php/8.1/cli/conf.d/
RELAY_EXT_DIR=$(php-config --extension-dir)    # /usr/lib/php/20210902
RELAY_ARCH=$(arch | sed -e 's/arm64/aarch64/;s/amd64\|x86_64/x86-64/')

RELAY_ARTIFACT="https://builds.r2.relay.so/$RELAY_VERSION/relay-$RELAY_VERSION-php$RELAY_PHP-debian-$RELAY_ARCH.tar.gz"
RELAY_TMP_DIR=$(mktemp -dt relay)

## Download artifact
curl -sSL $RELAY_ARTIFACT | tar -xz --strip-components=1 -C $RELAY_TMP_DIR

## Inject UUID
sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" $RELAY_TMP_DIR/relay-pkg.so

## Move + rename `relay-pkg.so`
cp $RELAY_TMP_DIR/relay-pkg.so $RELAY_EXT_DIR/relay.so

# Modify `relay.ini`
sed -i 's/^;\? \?relay.maxmemory =.*/relay.maxmemory = 128M/' $RELAY_TMP_DIR/relay.ini
sed -i 's/^;\? \?relay.eviction_policy =.*/relay.eviction_policy = lru/' $RELAY_TMP_DIR/relay.ini
sed -i 's/^;\? \?relay.environment =.*/relay.environment = production/' $RELAY_TMP_DIR/relay.ini
# sed -i "s/^;\? \?relay.key =.*/relay.key = 1L0O-KF0R-W4RDT0-Y0URR3P-0RTMRBR-OCC0L1/" $RELAY_TMP_DIR/relay.ini

## Move `relay.ini`
cp $RELAY_TMP_DIR/relay.ini $RELAY_INI_DIR
```

Finally, restart the web server and PHP-FPM process.
