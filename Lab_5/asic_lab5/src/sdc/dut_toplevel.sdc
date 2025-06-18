set ClockName clk

set Period 2
set RiseTransition 0.3
set FallTransition 0.2
set Uncertainty 0.4

create_clock -period $Period -name $ClockName [get_ports $ClockName]
set_clock_uncertainty -setup $Uncertainty [get_clocks $ClockName]
set_clock_transition -rise $RiseTransition [get_clocks $ClockName]
set_clock_transition -fall $FallTransition [get_clocks $ClockName]

