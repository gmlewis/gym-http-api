#!/bin/bash -e
# -*- compile-command: "./run-all.sh"; -*-
runs=$(find . -name run.sh)
for i in ${runs}; do
    pushd ${i%/*}
    ./run.sh
    popd
done
