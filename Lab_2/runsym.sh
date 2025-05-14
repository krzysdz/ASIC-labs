#!/usr/bin/env bash
set -ex

./clearsim.sh

vcs -f filelist.f
./simv
