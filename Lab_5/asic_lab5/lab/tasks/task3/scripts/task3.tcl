#####################################################################
###   Task 3 - Clock Tree Synthesis
#####################################################################

set TaskPrefix "task3_"
set DesignStage clock_tree_synthesis

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

proc make_layout_screenshot {suffix {hideCells "-showCells"}} {
    variable TaskPrefix
    variable LabDir
    set ScreenshotsDir "${LabDir}/screenshots"

    gui_start
    set top [gui_create_window -type TopLevel]
    set layout [gui_create_window -type Layout -parent $top]
    gui_show_window -window $top -show_state {maximized}
    gui_show_window -window $layout -show_state {maximized}

	# Hide power network
	gui_set_setting -window $layout -setting showRoutedPower -value false
	gui_set_setting -window $layout -setting showRoutedGround -value false
	if {$hideCells eq "-hideCells"} {
		# Hide cells for clearer screenshots
		gui_set_setting -window $layout -setting showCell -value false
	}

    gui_write_window_image -window $layout -clip -file ${ScreenshotsDir}/${TaskPrefix}floorplan_layout_${suffix}.png
    gui_stop
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

#### Set targer skew value
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
make_layout_screenshot final_opto -hideCells
make_layout_screenshot final_opto_wcells

# Remove global routes to review the clock tree
remove_routes -global_route

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

make_layout_screenshot shielded -hideCells
make_layout_screenshot shielded_wcells

# Highlight by clock tree manually and make a screenshot

get_blocks -all
list_blocks

save_block
save_lib

close_blocks
close_lib

exit

