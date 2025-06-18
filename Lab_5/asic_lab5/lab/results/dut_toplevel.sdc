################################################################################
#
# Design name:  dut_toplevel
#
# Created by fc write_sdc on Wed Jun 18 15:05:54 2025
#
################################################################################

set sdc_version 2.1
set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA

################################################################################
#
# Units
# time_unit               : 1e-09
# resistance_unit         : 1000000
# capacitive_load_unit    : 1e-15
# voltage_unit            : 1
# current_unit            : 1e-06
# power_unit              : 1e-12
################################################################################


# Mode: PowerSave
# Corner: Slow
# Scenario: PowerSave_Slow

# /home/student/Documents/kdz/ASIC/labs/Lab_5/asic_lab5/src/sdc/dut_toplevel_power_save.sdc, \
#   line 8
create_clock -name clk -period 10 -waveform {0 5} [get_ports {clk}]
set_propagated_clock [get_clocks {clk}]
# /home/student/Documents/kdz/ASIC/labs/Lab_5/asic_lab5/lab/setup/mcmm_setup.tcl, \
#   line 63
set_operating_conditions -library \
    saed14rvt_ss0p72vm40c.db:saed14rvt_ss0p72vm40c -analysis_type \
    on_chip_variation ss0p72vm40c
# Warning: Libcell power domain derates are skipped!

# Set latency for io paths.
# -origin user
set_clock_latency 0.0558829 [get_clocks {clk}]
# Set propagated on clock sources to avoid removing latency for IO paths.
set_propagated_clock  [get_ports {clk}]
set_clock_uncertainty -setup 0.9 [get_clocks {clk}]
set_clock_transition -rise 0.6 [get_clocks {clk}]
set_clock_transition -fall 0.7 [get_clocks {clk}]
# /home/student/Documents/kdz/ASIC/labs/Lab_5/asic_lab5/lab/tasks/task3/scripts/task3.tcl, \
#   line 48
set_driving_cell -lib_cell SAEDRVT14_INV_20 -library \
    saed14rvt_ss0p72vm40c.db:saed14rvt_ss0p72vm40c [get_ports {clk}]
