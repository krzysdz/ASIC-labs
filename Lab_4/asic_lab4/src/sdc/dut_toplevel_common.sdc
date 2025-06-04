create_clock -period $Period -name $ClockName [get_ports $ClockName]
set_clock_uncertainty -setup $Uncertainty [get_clocks $ClockName]
set_clock_transition -rise $RiseTransition [get_clocks $ClockName]
set_clock_transition -fall $FallTransition [get_clocks $ClockName]
