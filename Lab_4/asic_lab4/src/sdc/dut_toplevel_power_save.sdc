set ClockName clk

set Period 10
set RiseTransition 0.3
set FallTransition 0.5
set Uncertainty 0.7

source [file join [file dirname [info script]] "dut_toplevel_common.sdc"]
