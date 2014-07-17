#!/bin/sh

dir=$(dirname $0)
runOptions="-e USE_EXTENDED_FEATURES=false"
. $dir/tools/run-container.sh

echo "curl $IP"
curl $IP

$dir/tools/delete-container.sh
