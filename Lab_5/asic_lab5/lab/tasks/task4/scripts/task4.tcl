#####################################################################
###   Task 4 - Routing
#####################################################################

set TaskPrefix "task4_"

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

proc make_layout_screenshot {suffix {hidePower "-showPower"}} {
    variable TaskPrefix
    variable LabDir
    set ScreenshotsDir "${LabDir}/screenshots"

    gui_start
    set top [gui_create_window -type TopLevel]
    set layout [gui_create_window -type Layout -parent $top]
    gui_show_window -window $top -show_state {maximized}
    gui_show_window -window $layout -show_state {maximized}

	if {$hidePower eq "-hidePower"} {
		# Hide power network
		gui_set_setting -window $layout -setting showRoutedPower -value false
		gui_set_setting -window $layout -setting showRoutedGround -value false
		# # Hide cells for clearer screenshots
		# gui_set_setting -window $layout -setting showCell -value false
	}

    gui_write_window_image -window $layout -clip -file ${ScreenshotsDir}/${TaskPrefix}floorplan_layout_${suffix}.png
    gui_stop
}

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Copy and open block
copy_block -from ${DesignName}/clock_tree_synthesis -to ${DesignName}/routing
open_block ${DesignName}/routing

# Setup application options
set_app_options -name route.global.force_rerun_after_global_route_opt -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.detail.timing_driven -value true

# Improve routability
set_app_options    -name route.common.wire_on_grid_by_layer_name   -value {{M1 true } {M2 true} {M3 true}}
set_app_options    -name route.common.via_on_grid_by_layer_name    -value {{VIA1 false} {VIA2 true}}

# Routing constraint
set_ignored_layers \
	-min_routing_layer M1 \
	-max_routing_layer M7

#### Routing blockage example
create_routing_blockage -boundary {{22.9780 21.6000} {22.9780 27.4000} {31.8940 27.4000} {31.8940 21.6000}} -net_types {signal} -layers {M4} -name_prefix RB -zero_spacing
# create_routing_blockage -boundary {{? ?} {? ?} {? ?} {? ?}} -net_types {signal} -layers {M4} -name_prefix RB -zero_spacing

#### Routing flow
sizeof_collection [get_nets -hierarchical *]
report_ignored_layers
report_scenarios

# Check the design
check_routability

# Global routing
route_global

# Track assignment and net routing
route_track

# Detail routing and DRC fixing
route_detail

# route_auto command will run above 3 steps

#### Routing optimization
route_opt

#### Add redundant VIAs
add_redundant_vias

#### ECO routing fix
route_eco

#### Check the routing
check_routes
check_lvs

#### Connect PG nets
connect_pg_net -net VDD [get_pins -hierarchical  */VDD]
connect_pg_net -net VSS [get_pins -hierarchical  */VSS]

# Analyze the design
check_legality
report_congestion
report_utilization
generateReports routing_with_blockage

make_layout_screenshot routed
make_layout_screenshot routed_no_power -hidePower

get_blocks -all
list_blocks

save_block
save_lib

close_blocks
close_lib

exit

