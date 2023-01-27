#!/bin/bash

set -e

mkdir -p stubs
rm -rf stubs/*

LATEST_VERSION=dev
# LATEST_VERSION=$(curl -sSL https://builds.r2.relay.so/meta/latest)

wget -q -P stubs "https://builds.r2.relay.so/${LATEST_VERSION}/relay.stub.php"

## Append curly brackets to functions
gsed -i -r --posix 's/);$/) {}/' stubs/relay.stub.php
gsed -i -r --posix 's/):(.*);$/):\1 {}/' stubs/relay.stub.php

## Inject `LanguageLevelTypeAware` attributes
# TODO: ...

# docker-compose -f docker-compose.yml run test_runner composer install --ignore-platform-reqs
# docker-compose -f docker-compose.yml run test_runner composer cs-fix
