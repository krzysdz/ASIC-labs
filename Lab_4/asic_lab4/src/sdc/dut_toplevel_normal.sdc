set ClockName clk

set Period 2
set RiseTransition 0.1
set FallTransition 0.2
set Uncertainty 0.3

source [file join [file dirname [info script]] "dut_toplevel_common.sdc"]
