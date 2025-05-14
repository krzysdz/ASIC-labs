#!/usr/bin/env bash
set -ex

# Remove previous results
if [ -d csrc ]; then
    rm -rf csrc
fi
if [ -d simv.daidir ]; then
    rm -rf simv.daidir
fi
if [ -f simv ]; then
    rm simv
fi
if [ -f ucli.key ]; then
    rm ucli.key
fi
