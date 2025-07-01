#####################################################################
###    Task 2 - Placement and Optimization
#####################################################################

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

set TaskPrefix "task2_"

proc analyzeDesign {DesignStage} {
    variable ReportsDir

    redirect -file ${ReportsDir}/${DesignStage}_check_legality.rpt {check_legality}
    redirect -file ${ReportsDir}/${DesignStage}_report_congestion.rpt {report_congestion}
    redirect -file ${ReportsDir}/${DesignStage}_report_utilization.rpt {report_utilization}
}

proc make_layout_screenshot {suffix} {
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
    # Hide layers with power networks (this includes pins)
    gui_set_layout_layer_visibility {M6 M7} -window $layout -toggle

    gui_write_window_image -window $layout -clip -file ${ScreenshotsDir}/${TaskPrefix}floorplan_layout_${suffix}.png
    gui_stop
}

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Copy and open block
copy_block -from ${DesignName}/final_floorplan -to ${DesignName}/placement_and_optimization
open_block ${DesignName}/placement_and_optimization

source -echo ../scripts/set_placement_options.tcl

#### compile_fusion to initial_opto stage to get the design ready for placement and optimization
compile_fusion -to initial_opto


#### Classic placement and optimization flow

set DesignStage classic_placement

# create coarse placement
reset_placement

create_placement \
    -timing_driven \
    -congestion \
    -congestion_effort medium \
    -buffering_aware_timing_driven

legalize_placement

# place_opt
place_opt

# Analyze the design
make_layout_screenshot ${DesignStage}
analyzeDesign ${DesignStage}
generateReports ${DesignStage}

#### Unified placement and optimization flow

set DesignStage unified_placement

reset_placement

compile_fusion -to final_opto

# Analyze the design
make_layout_screenshot ${DesignStage}
analyzeDesign ${DesignStage}
generateReports ${DesignStage}

#### Placement blockages

set DesignStage create_placement_blockage

create_placement_blockage \
    -boundary {{22.9780 21.6000} {22.9780 27.4000} {31.8940 27.4000} {31.8940 21.6000}} \
    -type hard

check_legality
redirect -file ${ReportsDir}/${DesignStage}_check_legality.rpt {check_legality}
legalize_placement -incremental

#### Connect PG nets
connect_pg_net -net VDD [get_pins -hierarchical  */VDD]
connect_pg_net -net VSS [get_pins -hierarchical  */VSS]

set DesignStage placement_with_blockage

# Analyze the design
make_layout_screenshot ${DesignStage}
analyzeDesign ${DesignStage}
generateReports ${DesignStage}

get_blocks -all
list_blocks

save_block
save_lib

close_blocks
close_lib

exit
