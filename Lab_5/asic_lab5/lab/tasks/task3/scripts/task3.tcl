#####################################################################
###   Task 3 - Clock Tree Synthesis
#####################################################################

set TaskPrefix "task3_"
set DesignStage clock_tree_synthesis

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing project specific setup script
source -echo  ${SetupDir}/design_setup.tcl

set ScreenshotsDir "${LabDir}/screenshots"

# Reuse top level window
gui_start
set top [gui_create_window -type TopLevel -show_state maximized]

# https://docs.amd.com/r/en-US/ug894-vivado-tcl-scripting/Parsing-Command-Line-Arguments
proc lshift  {listVar} {
    upvar 1 $listVar L
    set r [lindex $L 0]
    set L [lreplace $L [set L 0] 0]
    return $r
}

proc make_layout_screenshot {suffix args} {
    variable TaskPrefix
    variable ScreenshotsDir
    variable top
    set hidePower 1
    set hideCells 0
    set hideNonShieldPower 0
    set hideClock 0
    set hideGlobalRouting 0

    while {[llength $args]} {
        set flag [lshift args]
        switch -exact -- $flag {
            -showPower {
                set hidePower 0
            }
            -hideNonShieldPower {
                set hideNonShieldPower 1
            }
            -hideCells {
                set hideCells 1
            }
            -hideClock {
                set hideClock 1
            }
            -hideGlobalRouting {
                set hideGlobalRouting 1
            }
        }
    }

    if {$hidePower && $hideNonShieldPower} {
        puts "-hideNonShieldPower without -showPower will hide shields too, because -showPower has higher priority"
    }

    # gui_start
    # set top [gui_create_window -type TopLevel]
    set layout [gui_create_window -type Layout -parent $top]
    gui_show_window -window $top -show_state {maximized}
    gui_show_window -window $layout -show_state {maximized}

    if {$hidePower} {
        # Hide power network
        gui_set_setting -window $layout -setting showRoutedPower -value false
        gui_set_setting -window $layout -setting showRoutedGround -value false
    }
    if {$hideNonShieldPower} {
        # Hide power and ground ring, straps and cell connections, but not shields
        # Should be used with showPower
        gui_set_setting -window $layout -setting showRoutedRing -value false
        gui_set_setting -window $layout -setting showRoutedStrap -value false
        gui_set_setting -window $layout -setting showRoutedPinConStd -value false
    }
	if {$hideCells} {
		# Hide cells for clearer screenshots
		gui_set_setting -window $layout -setting showCell -value false
	}
    if {$hideClock} {
        # Hide clock (to see only shields)
        gui_set_setting -window $layout -setting showRoutedClock -value false
    }
    if {$hideGlobalRouting} {
        gui_set_setting -window $layout -setting showRoutedGRoute -value false
    }

    gui_write_window_image -window $layout -clip -file ${ScreenshotsDir}/${TaskPrefix}floorplan_layout_${suffix}.png
    gui_close_window -window $layout
    # gui_stop
}

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Copy and open block
copy_block -from ${DesignName}/placement_and_optimization -to ${DesignName}/clock_tree_synthesis
open_block ${DesignName}/clock_tree_synthesis

# Setup application options
source -echo ../scripts/set_cts_options.tcl

#### Specify the driving cell
set_driving_cell -lib_cell ${CellPrefix}_INV_20 [get_ports ${ClockName}]

#### Define cell usage during CTS
source -echo ../scripts/cts_cell_usage.tcl

#### Create Shielding options and Non-Default Routing (NDR) rules

source -echo ../scripts/clock_ndr.tcl

#### Set target skew value
set_clock_tree_options -clocks [all_clocks] \
	-target_skew 0.05

#### clock_opt flow
get_clocks

# List the stages of clock_opt command
clock_opt -list_only

# Synthesize and optimize the clock tree
clock_opt -to build_clock
make_layout_screenshot build_clock -hideCells

# Detail routing of clock
clock_opt -from build_clock -to route_clock
make_layout_screenshot route_clock -hideCells

# Optimization and legalization
clock_opt -to final_opto
make_layout_screenshot final_opto_with_global_routing -hideCells
make_layout_screenshot final_opto -hideCells -hideGlobalRouting
make_layout_screenshot final_opto_wcells -hideGlobalRouting

# Remove global routes to review the clock tree
remove_routes -global_route
make_layout_screenshot final_opto_gr_removed -hideCells

#### Clock shielding with VSS
set clock_nets [get_nets -hierarchical -filter "net_type == clock"]
create_shields -nets ${clock_nets} -with_ground VSS -preferred_direction_only true -align_to_shape_end true

#### Connect PG nets
connect_pg_net -net VDD [get_pins -hierarchical  */VDD]
connect_pg_net -net VSS [get_pins -hierarchical  */VSS]

# Analyze the design
check_legality
report_congestion
report_utilization
redirect -file ${ReportsDir}/${DesignStage}_check_legality.rpt {check_legality}
redirect -file ${ReportsDir}/${DesignStage}_report_congestion.rpt {report_congestion}
redirect -file ${ReportsDir}/${DesignStage}_report_utilization.rpt {report_utilization}
generateReports ${DesignStage}

make_layout_screenshot shielded -hideCells -showPower -hideNonShieldPower
make_layout_screenshot shielded_wcells -showPower -hideNonShieldPower
make_layout_screenshot shield_only -hideCells -showPower -hideNonShieldPower -hideClock

# ~~Highlight by clock tree manually and make a screenshot~~
# I love undocumented options that don't appear in autocomplete lists, man page viewer or both...
# Grepping doc/ FTW
# gui_start
# set top [gui_create_window -type TopLevel -show_state maximized]
set layout [gui_create_window -type Layout -parent $top -show_state maximized]
# Well, it looks like it being missing in multiple places meant that it does not really exist (except for `man gui_set_layout_visual_mode` which works...)
# gui_set_layout_visual_mode -window $layout -mode "Clock Tree"
gui_show_map -map "Clock Tree" -show true -window $layout
gui_set_map_option -map "Clock Tree" -option clock -value "Normal:clk"
gui_write_window_image -window $layout -clip -file ${ScreenshotsDir}/${TaskPrefix}clock_tree_vm.png
gui_stop

get_blocks -all
list_blocks

save_block
save_lib

close_blocks
close_lib

exit
