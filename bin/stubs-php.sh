#!/bin/bash

set -e

mkdir -p stubs
rm -rf stubs/*

LATEST_VERSION=$(curl -sSL https://builds.r2.relay.so/meta/latest)

wget -q -P stubs "https://builds.r2.relay.so/${LATEST_VERSION}/relay.stub.php"

# PHP 8.2 stubs
mv stubs/relay.stub.php stubs/relay-8.2.php

# Append curly brackets to functions
gsed -i --posix -r 's/):(.*);/):\1 { }/' stubs/relay-8.2.php

# PHP 8.1 stubs
cp stubs/relay-8.2.php stubs/relay-8.1.php

# PHP 8.0 stubs
cp stubs/relay-8.1.php stubs/relay-8.0.php

# PHP 7.4 stubs
cp stubs/relay-8.0.php stubs/relay-7.4.php
