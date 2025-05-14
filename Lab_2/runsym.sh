#!/usr/bin/env bash
set -ex

./clearsim.sh

if [ $1 == "--gui" ]; then
    vcs -kdb -debug_access+all -f filelist.f
    ./simv -gui
else
    vcs -f filelist.f
    ./simv
fi
