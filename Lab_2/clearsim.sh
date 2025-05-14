#!/usr/bin/env bash
set -e

# Remove previous results
rm -rf csrc simv.daidir verdiLog ucli.key simv.vdb urgReport vdCovLog
rm -f simv ucli/key inter.fsdb* .inter.fsdb.* .vcs_checkpoint_* novas* verdi_config_file .fsm.sch.verilog.xml cm.log
