#!/bin/bash

set -e

rm -rf stubs

wget -q -P stubs/ "https://builds.r2.relay.so/meta/latest"

wget -q -P stubs/develop "https://builds.r2.relay.so/dev/relay.stub.php"

LATEST=$(cat stubs/LATEST)
BASE_VERSION=${LATEST:1:2}x
wget -q -P "stubs/${BASE_VERSION}" "https://builds.r2.relay.so/${LATEST}/relay.stub.php"
