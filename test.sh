#!/bin/sh

# Usage
# sudo ./test.sh 
# add -v for verbose mode (or type whatever you like !) :p

. test/config
. test/tools/run.sh

run_test tools/build-container.sh "Successfully built"
run_test simple.sh "loginform"
run_test link.sh "pma_navigation_tree"

. test/tools/end.sh
