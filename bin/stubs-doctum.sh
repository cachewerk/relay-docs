#!/bin/bash

set -e

mkdir -p doctum/.stubs
rm -rf doctum/.stubs/*

wget -q -O doctum/.stubs/LATEST "https://builds.r2.relay.so/meta/latest"

wget -q -P doctum/.stubs/develop "https://builds.r2.relay.so/dev/relay.stub.php"

VERSION_LATEST=$(cat doctum/.stubs/LATEST)
VERSION_BASE=${VERSION_LATEST:1:2}x
wget -q -P "doctum/.stubs/${VERSION_BASE}" "https://builds.r2.relay.so/${VERSION_LATEST}/relay.stub.php"
