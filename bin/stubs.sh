#!/bin/bash

set -e

rm -rf stubs

wget -q -P stubs/ "https://cachewerk.s3.amazonaws.com/relay/LATEST"

wget -q -P stubs/develop "https://cachewerk.s3.amazonaws.com/relay/dev/relay.stub.php"

LATEST=$(cat stubs/LATEST)
BASE_VERSION=${VERSION:1:2}x
wget -q -P "stubs/${BASE_VERSION}" "https://cachewerk.s3.amazonaws.com/relay/${LATEST}/relay.stub.php"
