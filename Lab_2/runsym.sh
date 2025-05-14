#!/usr/bin/env bash
set -ex

./clearsim.sh

if ! command -v vcs; then
    echo "vsc command not found. Did you forget to run alias add-synopsys-FEV-all?"
    exit 1
fi

if [ $1 == "--gui" ]; then
    vcs -kdb -debug_access+all -f filelist.f
    ./simv -gui
elif [ $1 == "--cov" ]; then
    vcs -cm line+tgl+cond+fsm+branch -f filelist.f
    ./simv -cm line+tgl+cond+fsm+branch
    urg -dir simv.vdb
    verdi -cov -covdir simv.vdb
else
    vcs -f filelist.f
    ./simv
fi
