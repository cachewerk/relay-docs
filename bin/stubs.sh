#!/bin/bash

set -e

rm -rf stubs

wget -q -P stubs/ "https://builds.r2.relay.so/meta/latest"

wget -q -P stubs/develop "https://builds.r2.relay.so/dev/relay.stub.php"

VERSION_LATEST=$(cat stubs/latest)
VERSION_BASE=${VERSION_LATEST:1:2}x
wget -q -P "stubs/${VERSION_BASE}" "https://builds.r2.relay.so/${VERSION_LATEST}/relay.stub.php"
