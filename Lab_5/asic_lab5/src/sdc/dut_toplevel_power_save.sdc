set ClockName clk

set Period 10
set RiseTransition 0.6
set FallTransition 0.7
set Uncertainty 0.9

create_clock -period $Period -name $ClockName [get_ports $ClockName]
set_clock_uncertainty -setup $Uncertainty [get_clocks $ClockName]
set_clock_transition -rise $RiseTransition [get_clocks $ClockName]
set_clock_transition -fall $FallTransition [get_clocks $ClockName]

